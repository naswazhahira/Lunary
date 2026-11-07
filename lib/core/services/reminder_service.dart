import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

enum ReminderPermissionResult { granted, notificationsDenied, needsAlarmPermission }

class ReminderService {
  ReminderService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Jangan ganti id channel setelah rilis: Android tidak mengizinkan
  // suara/audio channel yang sudah dibuat diubah. Kalau mau ganti, buat id baru.
  static const String _channelId = 'lunary_reminder_alarm';
  static const String _channelName = 'Lunary reminders';
  static const int _testId = 9999;

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  static IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Alarm reminders from Lunary',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );

    _initialized = true;
  }

  static NotificationDetails _details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Alarm reminders from Lunary',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        // FLAG_INSISTENT (4): suara berulang sampai notifikasi diketuk / digeser
        additionalFlags: Int32List.fromList(<int>[4]),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Permission
  // ---------------------------------------------------------------------------

  /// True kalau notifikasi dan (di Android) exact alarm sudah diizinkan.
  static Future<bool> hasPermission() async {
    await init();

    final android = _android;
    if (android != null) {
      final notif = await android.areNotificationsEnabled() ?? false;
      final exact = await android.canScheduleExactNotifications() ?? false;
      return notif && exact;
    }

    final ios = _ios;
    if (ios != null) {
      final p = await ios.checkPermissions();
      return p?.isEnabled ?? false;
    }
    return false;
  }

  /// Minta izin ke sistem. Di Android, izin "Alarms & reminders" membuka
  /// layar pengaturan, jadi hasilnya perlu dicek ulang saat user kembali.
  static Future<ReminderPermissionResult> requestPermission() async {
    await init();

    final android = _android;
    if (android != null) {
      final notif = await android.requestNotificationsPermission() ?? false;
      if (!notif) return ReminderPermissionResult.notificationsDenied;

      final canExact = await android.canScheduleExactNotifications() ?? false;
      if (!canExact) {
        await android.requestExactAlarmsPermission();
        return ReminderPermissionResult.needsAlarmPermission;
      }
      return ReminderPermissionResult.granted;
    }

    final ios = _ios;
    if (ios != null) {
      final ok = await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      return ok ? ReminderPermissionResult.granted : ReminderPermissionResult.notificationsDenied;
    }
    return ReminderPermissionResult.notificationsDenied;
  }

  // ---------------------------------------------------------------------------
  // Simpan pengaturan
  // ---------------------------------------------------------------------------

  static Future<bool> isEnabled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reminder_${key}_on') ?? false;
  }

  static Future<TimeOfDay> getTime(String key, TimeOfDay fallback) async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('reminder_${key}_time');
    if (minutes == null) return fallback;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  // ---------------------------------------------------------------------------
  // Jadwal alarm
  // ---------------------------------------------------------------------------

  /// Alarm harian berulang setiap hari pada jam [time].
  static Future<void> enableDaily({
    required String key,
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await init();

    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: first,
      notificationDetails: _details(),
      // alarmClock: paling andal, tetap bunyi di mode hemat daya (Doze).
      // Kalau bermasalah, ganti ke AndroidScheduleMode.exactAllowWhileIdle.
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_${key}_on', true);
    await prefs.setInt('reminder_${key}_time', time.hour * 60 + time.minute);
  }

  static Future<void> disable({required String key, required int id}) async {
    await init();
    await _plugin.cancel(id: id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_${key}_on', false);
  }

  /// Alarm uji coba 10 detik dari sekarang.
  static Future<void> scheduleTest() async {
    await init();
    final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    await _plugin.zonedSchedule(
      id: _testId,
      title: 'Lunary test alarm',
      body: 'If you can hear this, your reminders are working.',
      scheduledDate: when,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  /// Batalkan semua alarm dan hapus pengaturannya (dipakai saat hapus akun).
  static Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith('reminder_')).toList()) {
      await prefs.remove(k);
    }
  }
}