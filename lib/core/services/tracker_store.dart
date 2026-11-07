import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TrackerType { temperature, weight, water, sleep }

/// Info tiap tracker. Nilai disimpan dalam satuan dasar:
/// suhu °C, berat kg, air ml, tidur jam.
class TrackerInfo {
  final TrackerType type;
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isBar;
  final bool accumulate; // true = input baru ditambahkan ke total hari itu
  final double minValid;
  final double maxValid;
  final int decimals;

  const TrackerInfo({
    required this.type,
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isBar,
    required this.accumulate,
    required this.minValid,
    required this.maxValid,
    required this.decimals,
  });

  static const List<TrackerInfo> all = [
    TrackerInfo(
      type: TrackerType.temperature,
      key: 'temperature',
      title: 'Temperature (BBT)',
      subtitle: 'Your basal body temperature over time',
      icon: Icons.thermostat_outlined,
      color: Color(0xFFFF8A65),
      isBar: false,
      accumulate: false,
      minValid: 34,
      maxValid: 42,
      decimals: 1,
    ),
    TrackerInfo(
      type: TrackerType.weight,
      key: 'weight',
      title: 'Weight',
      subtitle: 'Your weight over time',
      icon: Icons.monitor_weight_outlined,
      color: Color(0xFF26C6DA),
      isBar: false,
      accumulate: false,
      minValid: 20,
      maxValid: 300,
      decimals: 1,
    ),
    TrackerInfo(
      type: TrackerType.water,
      key: 'water',
      title: 'Water',
      subtitle: 'How much you drink each day',
      icon: Icons.local_drink_outlined,
      color: Color(0xFF4FC3F7),
      isBar: true,
      accumulate: true,
      minValid: 1,
      maxValid: 5000,
      decimals: 0,
    ),
    TrackerInfo(
      type: TrackerType.sleep,
      key: 'sleep',
      title: 'Sleep',
      subtitle: 'Hours of sleep each night',
      icon: Icons.bedtime_outlined,
      color: Color(0xFF7E57C2),
      isBar: true,
      accumulate: false,
      minValid: 0.5,
      maxValid: 24,
      decimals: 1,
    ),
  ];

  static TrackerInfo of(TrackerType t) => all.firstWhere((i) => i.type == t);

  String unit(bool isMetric) {
    switch (type) {
      case TrackerType.temperature:
        return '°C';
      case TrackerType.weight:
        return isMetric ? 'kg' : 'lb';
      case TrackerType.water:
        return 'ml';
      case TrackerType.sleep:
        return 'h';
    }
  }

  double toDisplay(double stored, bool isMetric) =>
      (type == TrackerType.weight && !isMetric) ? stored * 2.2046226 : stored;

  double toStored(double display, bool isMetric) =>
      (type == TrackerType.weight && !isMetric) ? display / 2.2046226 : display;

  String format(double stored, bool isMetric) {
    final v = toDisplay(stored, isMetric);
    return '${v.toStringAsFixed(decimals)} ${unit(isMetric)}';
  }
}

/// Penyimpanan catatan tracker per akun (sementara di shared_preferences).
class TrackerStore {
  TrackerStore._();

  static String _prefsKey(String account, TrackerType t) =>
      'tracker_${account.toLowerCase()}_${TrackerInfo.of(t).key}';

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parseDate(String s) {
    final p = s.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  static Future<Map<DateTime, double>> load(String account, TrackerType type) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey(account, type)) ?? const <String>[];
    final result = <DateTime, double>{};
    for (final item in list) {
      final parts = item.split('|');
      if (parts.length != 2) continue;
      final date = _parseDate(parts[0]);
      final value = double.tryParse(parts[1]);
      if (date != null && value != null) result[date] = value;
    }
    return result;
  }

  static Future<void> _save(String account, TrackerType type, Map<DateTime, double> data) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = data.entries.map((e) => '${_dateKey(e.key)}|${e.value}').toList();
    await prefs.setStringList(_prefsKey(account, type), entries);
  }

  static Future<void> setValue(String account, TrackerType type, DateTime date, double value) async {
    final data = await load(account, type);
    data[DateTime(date.year, date.month, date.day)] = value;
    await _save(account, type, data);
  }

  static Future<void> remove(String account, TrackerType type, DateTime date) async {
    final data = await load(account, type);
    data.remove(DateTime(date.year, date.month, date.day));
    await _save(account, type, data);
  }

  /// Hapus semua catatan akun ini (dipakai saat hapus akun).
  static Future<void> clearAccount(String account) async {
    final prefs = await SharedPreferences.getInstance();
    for (final info in TrackerInfo.all) {
      await prefs.remove(_prefsKey(account, info.type));
    }
  }
}