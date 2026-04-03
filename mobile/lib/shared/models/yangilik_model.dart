import 'dart:convert';

class YangilikModel {
  final String id;
  final String title;
  final String? body;
  final String? coverImageUrl;
  final String category;
  final bool isPublished;
  final String? publishedAt;
  final Map<String, dynamic> translations;
  final String updatedAt;

  const YangilikModel({
    required this.id,
    required this.title,
    this.body,
    this.coverImageUrl,
    this.category = 'general',
    this.isPublished = true,
    this.publishedAt,
    this.translations = const {},
    required this.updatedAt,
  });

  factory YangilikModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> trans = {};
    if (map['translations'] is String) {
      trans = jsonDecode(map['translations'] as String) as Map<String, dynamic>? ?? {};
    } else if (map['translations'] is Map) {
      trans = Map<String, dynamic>.from(map['translations'] as Map);
    }
    return YangilikModel(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String?,
      coverImageUrl: map['cover_image_url'] as String?,
      category: map['category'] as String? ?? 'general',
      isPublished: (map['is_published'] as num?)?.toInt() != 0,
      publishedAt: map['published_at'] as String?,
      translations: trans,
      updatedAt: map['updated_at'] as String,
    );
  }

  String localizedTitle(String locale) {
    if (locale == 'uz') return title;
    return (translations[locale] as Map<String, dynamic>?)?['title'] as String? ?? title;
  }

  String? localizedBody(String locale) {
    if (locale == 'uz') return body;
    return (translations[locale] as Map<String, dynamic>?)?['body'] as String? ?? body;
  }
}
