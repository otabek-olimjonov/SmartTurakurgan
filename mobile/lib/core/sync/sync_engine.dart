import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_turakurgan/core/db/local_database.dart';

const _lastSyncKey = 'last_sync_at';
const _firstInstallKey = 'first_install_done';

class SyncEngine {
  final Dio _dio;

  SyncEngine(this._dio);

  Future<void> runSync() async {
    final prefs = await SharedPreferences.getInstance();
    final firstDone = prefs.getBool(_firstInstallKey) ?? false;

    if (!firstDone) {
      await _fullSync();
      await prefs.setBool(_firstInstallKey, true);
    } else {
      final shouldSync = _shouldSync(prefs);
      if (shouldSync) {
        await _deltaSync(prefs);
      }
    }
    await _newsSync();
  }

  bool _shouldSync(SharedPreferences prefs) {
    final lastSyncStr = prefs.getString(_lastSyncKey);
    if (lastSyncStr == null) return true;
    final lastSync = DateTime.tryParse(lastSyncStr);
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync).inHours >= 24;
  }

  Future<void> _fullSync() async {
    try {
      final resp = await _dio.get('/sync-full');
      final data = resp.data as Map<String, dynamic>;
      final db = await LocalDatabase.instance;
      await _writeSyncData(db, data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (_) {
      // Offline — skip, will retry next time
    }
  }

  Future<void> _deltaSync(SharedPreferences prefs) async {
    try {
      final lastSync = prefs.getString(_lastSyncKey) ?? '1970-01-01T00:00:00Z';
      final resp = await _dio.post('/sync-delta', data: {'last_sync_at': lastSync});
      final data = resp.data as Map<String, dynamic>;
      final db = await LocalDatabase.instance;
      await _writeSyncData(db, data);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (_) {
      // Offline — skip
    }
  }

  Future<void> _newsSync() async {
    try {
      final resp = await _dio.get('/sync-news');
      final news = (resp.data['yangiliklar'] as List?) ?? [];
      final db = await LocalDatabase.instance;
      await _upsertRows(db, 'yangiliklar', news);
    } catch (_) {
      // Offline — use cached news
    }
  }

  Future<void> _writeSyncData(Database db, Map<String, dynamic> data) async {
    final tables = {
      'rahbariyat': data['rahbariyat'],
      'mahallalar': data['mahallalar'],
      'mahalla_xodimlari': data['mahalla_xodimlari'],
      'yer_maydonlari': data['yer_maydonlari'],
      'places': data['places'],
      'place_images': data['place_images'],
      'yangiliklar': data['yangiliklar'],
    };

    for (final entry in tables.entries) {
      final rows = (entry.value as List?) ?? [];
      await _upsertRows(db, entry.key, rows);
    }
  }

  Future<void> _upsertRows(Database db, String table, List rows) async {
    if (rows.isEmpty) return;
    final batch = db.batch();
    for (final row in rows) {
      final r = Map<String, dynamic>.from(row as Map);
      // Serialize jsonb fields
      if (r.containsKey('translations') && r['translations'] is Map) {
        r['translations'] = jsonEncode(r['translations']);
      }
      // Convert booleans
      if (r.containsKey('is_published')) {
        r['is_published'] = (r['is_published'] == true) ? 1 : 0;
      }
      batch.insert(table, r, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  throw UnimplementedError('Must be overridden with a Dio instance');
});
