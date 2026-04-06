import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_turakurgan/core/db/local_database.dart';

const _lastSyncKey = 'last_sync_at';
const _firstInstallKey = 'first_install_done';

typedef SyncProgressCallback = void Function(double progress, String message);

class SyncEngine {
  final Dio _dio;

  SyncEngine(this._dio);

  Future<void> runSync({SyncProgressCallback? onProgress}) async {
    final prefs = await SharedPreferences.getInstance();
    final firstDone = prefs.getBool(_firstInstallKey) ?? false;

    onProgress?.call(0.1, 'Ma\'lumotlar tekshirilmoqda...');

    if (!firstDone || kDebugMode) {
      onProgress?.call(0.2, 'Birinchi marta yuklash...');
      await _fullSync();
      await prefs.setBool(_firstInstallKey, true);
    } else {
      final shouldSync = _shouldSync(prefs);
      if (shouldSync) {
        onProgress?.call(0.2, 'Ma\'lumotlar yangilanmoqda...');
        await _deltaSync(prefs);
      }
    }
    onProgress?.call(0.75, 'Yangiliklar yuklanmoqda...');
    await _newsSync();
    onProgress?.call(1.0, 'Tayyor!');
  }

  bool _shouldSync(SharedPreferences prefs) {
    if (kDebugMode) return true; // Always sync in debug mode
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
    } catch (e) {
      debugPrint('[SyncEngine] fullSync error: $e');
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
    } catch (e) {
      debugPrint('[SyncEngine] deltaSync error: $e');
    }
  }

  Future<void> _newsSync() async {
    try {
      final resp = await _dio.get('/sync-news');
      final news = (resp.data['yangiliklar'] as List?) ?? [];
      final images = (resp.data['yangilik_images'] as List?) ?? [];
      final db = await LocalDatabase.instance;
      await _upsertRows(db, 'yangiliklar', news);
      await _upsertRows(db, 'yangilik_images', images);
    } catch (e) {
      debugPrint('[SyncEngine] newsSync error: $e');
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
      'yangilik_images': data['yangilik_images'],
    };

    for (final entry in tables.entries) {
      final rows = (entry.value as List?) ?? [];
      await _upsertRows(db, entry.key, rows);
    }
  }

  // Cache of table columns to avoid repeated PRAGMA queries
  final Map<String, Set<String>> _tableColumns = {};

  Future<Set<String>> _getTableColumns(Database db, String table) async {
    if (_tableColumns.containsKey(table)) return _tableColumns[table]!;
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final cols = info.map((r) => r['name'] as String).toSet();
    _tableColumns[table] = cols;
    return cols;
  }

  Future<void> _upsertRows(Database db, String table, List rows) async {
    if (rows.isEmpty) return;
    final cols = await _getTableColumns(db, table);
    final batch = db.batch();
    for (final row in rows) {
      final r = Map<String, dynamic>.from(row as Map);
      // Serialize jsonb fields
      if (r.containsKey('translations') && r['translations'] is Map) {
        r['translations'] = jsonEncode(r['translations']);
      }
      // Convert all booleans to 0/1 (sqflite doesn't support bool)
      for (final key in r.keys.toList()) {
        if (r[key] is bool) {
          r[key] = (r[key] as bool) ? 1 : 0;
        }
      }
      // Remove columns that don't exist in local schema (e.g. created_at)
      r.removeWhere((key, _) => !cols.contains(key));
      batch.insert(table, r, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  throw UnimplementedError('Must be overridden with a Dio instance');
});
