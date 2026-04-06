import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/core/db/local_database.dart';
import 'package:smart_turakurgan/shared/models/rahbariyat_model.dart';
import 'dart:convert';

class MahallalarModel {
  final String id;
  final String name;
  final String? description;
  final double? locationLat;
  final double? locationLng;
  final String? buildingPhotoUrl;
  final Map<String, dynamic> translations;
  final String updatedAt;

  const MahallalarModel({
    required this.id,
    required this.name,
    this.description,
    this.locationLat,
    this.locationLng,
    this.buildingPhotoUrl,
    this.translations = const {},
    required this.updatedAt,
  });

  factory MahallalarModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> trans = {};
    if (map['translations'] is String) {
      trans = jsonDecode(map['translations'] as String) as Map<String, dynamic>? ?? {};
    } else if (map['translations'] is Map) {
      trans = Map<String, dynamic>.from(map['translations'] as Map);
    }
    return MahallalarModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      locationLat: (map['location_lat'] as num?)?.toDouble(),
      locationLng: (map['location_lng'] as num?)?.toDouble(),
      buildingPhotoUrl: map['building_photo_url'] as String?,
      translations: trans,
      updatedAt: map['updated_at'] as String,
    );
  }

  String localizedName(String languageCode) {
    final t = translations[languageCode];
    if (t is Map && (t['name'] as String?)?.isNotEmpty == true) {
      return t['name'] as String;
    }
    return name;
  }

  String? localizedDescription(String languageCode) {
    final t = translations[languageCode];
    if (t is Map && (t['description'] as String?)?.isNotEmpty == true) {
      return t['description'] as String;
    }
    return description;
  }
}

class YerMaydonModel {
  final String id;
  final String title;
  final double? areaHectares;
  final double? locationLat;
  final double? locationLng;
  final String status;
  final String? auctionUrl;
  final String? description;
  final Map<String, dynamic> translations;

  const YerMaydonModel({
    required this.id,
    required this.title,
    this.areaHectares,
    this.locationLat,
    this.locationLng,
    this.status = 'active',
    this.auctionUrl,
    this.description,
    this.translations = const {},
  });

  factory YerMaydonModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> trans = {};
    if (map['translations'] is String) {
      trans = jsonDecode(map['translations'] as String) as Map<String, dynamic>? ?? {};
    } else if (map['translations'] is Map) {
      trans = Map<String, dynamic>.from(map['translations'] as Map);
    }
    return YerMaydonModel(
      id: map['id'] as String,
      title: map['title'] as String,
      areaHectares: (map['area_hectares'] as num?)?.toDouble(),
      locationLat: (map['location_lat'] as num?)?.toDouble(),
      locationLng: (map['location_lng'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'active',
      auctionUrl: map['auction_url'] as String?,
      description: map['description'] as String?,
      translations: trans,
    );
  }

  String localizedTitle(String languageCode) {
    final t = translations[languageCode];
    if (t is Map && (t['title'] as String?)?.isNotEmpty == true) {
      return t['title'] as String;
    }
    return title;
  }

  String? localizedDescription(String languageCode) {
    final t = translations[languageCode];
    if (t is Map && (t['description'] as String?)?.isNotEmpty == true) {
      return t['description'] as String;
    }
    return description;
  }
}

class HokimiyatRepository {
  Future<List<RahbariyatModel>> getByCategory(String category) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'rahbariyat',
      where: 'category = ? AND is_published = 1',
      whereArgs: [category],
      orderBy: 'sort_order ASC',
    );
    return rows.map(RahbariyatModel.fromMap).toList();
  }

  Future<List<MahallalarModel>> getMahallalar() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'mahallalar',
      where: 'is_published = 1',
      orderBy: 'name ASC',
    );
    return rows.map(MahallalarModel.fromMap).toList();
  }

  Future<List<RahbariyatModel>> getMahallaxodimlari(String mahallalId) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'mahalla_xodimlari',
      where: 'mahalla_id = ?',
      whereArgs: [mahallalId],
      orderBy: 'sort_order ASC',
    );
    return rows.map(RahbariyatModel.fromMap).toList();
  }

  Future<List<YerMaydonModel>> getYerMaydonlari() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'yer_maydonlari',
      where: 'is_published = 1',
      orderBy: 'rowid DESC',
    );
    return rows.map(YerMaydonModel.fromMap).toList();
  }
}

final hokimiyatRepositoryProvider = Provider<HokimiyatRepository>((ref) => HokimiyatRepository());

final rahbariyatByCategoryProvider =
    FutureProvider.family<List<RahbariyatModel>, String>((ref, category) async {
  return ref.read(hokimiyatRepositoryProvider).getByCategory(category);
});

final mahallalarProvider = FutureProvider<List<MahallalarModel>>((ref) async {
  return ref.read(hokimiyatRepositoryProvider).getMahallalar();
});

final yerMaydonlariProvider = FutureProvider<List<YerMaydonModel>>((ref) async {
  return ref.read(hokimiyatRepositoryProvider).getYerMaydonlari();
});
