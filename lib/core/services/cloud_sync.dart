import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'cycle_settings.dart';
import 'tracker_store.dart';

/// applied = data cloud dipakai, none = memang belum ada data di cloud,
/// failed = gagal/timeout (jangan timpa apa pun).
enum CloudPull { applied, none, failed }

class CloudSync {
  CloudSync._();

  static const Duration _timeout = Duration(seconds: 4);

  /// Data profil terakhir dari/ke cloud (dibaca ProfileScreen).
  static Map<String, dynamic>? profile;

  static DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parse(String s) {
    final p = s.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  static TrackerType? _typeForKey(String key) {
    for (final i in TrackerInfo.all) {
      if (i.key == key) return i.type;
    }
    return null;
  }

  static void clear() => profile = null;

  // ---------------- Kirim ke cloud (tidak menunggu, aman saat offline) -----

  static void pushSettings() => unawaited(_pushSettings());

  static Future<void> _pushSettings() async {
    final doc = _userDoc;
    if (doc == null || !CycleSettings.isAccountActive) return; // tamu: lewati
    try {
      final settings = await CycleSettings.toCloudMap();
      unawaited(doc
          .set({'settings': settings, 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true))
          .catchError((_) {}));
    } catch (_) {}
  }

  static void pushProfile(Map<String, dynamic> data) {
    final doc = _userDoc;
    if (doc == null) return;
    profile = {...?profile, ...data};
    unawaited(doc
        .set({'profile': profile, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true))
        .catchError((_) {}));
  }

  static void pushTracker(String account, TrackerType type, Map<DateTime, double> data) {
    if (account.toLowerCase() == 'guest') return; // tamu: lewati
    final doc = _userDoc;
    if (doc == null) return;
    final entries = {for (final e in data.entries) _fmt(e.key): e.value};
    unawaited(doc
        .collection('trackers')
        .doc(TrackerInfo.of(type).key)
        .set({'entries': entries})
        .catchError((_) {}));
  }

  /// Unggah semua data lokal akun ini (dipakai saat akun belum punya data cloud).
  static Future<void> pushAll(String email) async {
    await _pushSettings();
    for (final info in TrackerInfo.all) {
      final data = await TrackerStore.load(email, info.type);
      if (data.isNotEmpty) pushTracker(email, info.type, data);
    }
  }

  // ---------------- Ambil dari cloud ----------------

  /// Cloud menang: kalau ada data di cloud, data lokal akun ini diganti.
  static Future<CloudPull> pullAll(String email) async {
    final doc = _userDoc;
    if (doc == null) return CloudPull.failed;

    try {
      final snap = await doc.get().timeout(_timeout);
      if (!snap.exists) {
        profile = null;
        return CloudPull.none;
      }
      final data = snap.data() ?? {};

      final settings = data['settings'];
      if (settings is Map) {
        await CycleSettings.applyCloudMap(email, Map<String, dynamic>.from(settings));
      }

      final p = data['profile'];
      profile = p is Map ? Map<String, dynamic>.from(p) : null;

      final trackers = await doc.collection('trackers').get().timeout(_timeout);
      for (final d in trackers.docs) {
        final type = _typeForKey(d.id);
        if (type == null) continue;
        final raw = d.data()['entries'];
        final entries = <DateTime, double>{};
        if (raw is Map) {
          raw.forEach((k, v) {
            final date = _parse(k.toString());
            if (date != null && v is num) entries[date] = v.toDouble();
          });
        }
        await TrackerStore.importFromCloud(email, type, entries);
      }
      return CloudPull.applied;
    } catch (_) {
      return CloudPull.failed;
    }
  }

  // ---------------- Hapus data (saat hapus akun) ----------------

  static Future<void> deleteMyData() async {
    final doc = _userDoc;
    if (doc == null) return;
    try {
      final trackers = await doc.collection('trackers').get();
      for (final d in trackers.docs) {
        await d.reference.delete();
      }
      await doc.delete();
      profile = null;
    } catch (_) {
      throw AuthException('Gagal menghapus data di cloud. Periksa koneksi lalu coba lagi.');
    }
  }
}
