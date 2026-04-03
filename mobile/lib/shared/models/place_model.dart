import 'dart:convert';

class PlaceModel {
  final String id;
  final String category;
  final String name;
  final String? director;
  final String? phone;
  final String? description;
  final double? locationLat;
  final double? locationLng;
  final double rating;
  final int commentCount;
  final bool isPublished;
  final Map<String, dynamic> translations;
  final String updatedAt;
  List<String> imageUrls;

  PlaceModel({
    required this.id,
    required this.category,
    required this.name,
    this.director,
    this.phone,
    this.description,
    this.locationLat,
    this.locationLng,
    this.rating = 0,
    this.commentCount = 0,
    this.isPublished = true,
    this.translations = const {},
    required this.updatedAt,
    this.imageUrls = const [],
  });

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> trans = {};
    if (map['translations'] is String) {
      trans = jsonDecode(map['translations'] as String) as Map<String, dynamic>? ?? {};
    } else if (map['translations'] is Map) {
      trans = Map<String, dynamic>.from(map['translations'] as Map);
    }
    return PlaceModel(
      id: map['id'] as String,
      category: map['category'] as String,
      name: map['name'] as String,
      director: map['director'] as String?,
      phone: map['phone'] as String?,
      description: map['description'] as String?,
      locationLat: (map['location_lat'] as num?)?.toDouble(),
      locationLng: (map['location_lng'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      commentCount: (map['comment_count'] as num?)?.toInt() ?? 0,
      isPublished: (map['is_published'] as num?)?.toInt() != 0,
      translations: trans,
      updatedAt: map['updated_at'] as String,
    );
  }

  String localizedName(String locale) {
    if (locale == 'uz') return name;
    return (translations[locale] as Map<String, dynamic>?)?['name'] as String? ?? name;
  }

  String? localizedDescription(String locale) {
    if (locale == 'uz') return description;
    return (translations[locale] as Map<String, dynamic>?)?['description'] as String? ?? description;
  }
}
