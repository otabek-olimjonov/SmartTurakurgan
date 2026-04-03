import 'dart:convert';

class RahbariyatModel {
  final String id;
  final String fullName;
  final int? birthYear;
  final String position;
  final String category;
  final String? phone;
  final String? biography;
  final String? receptionDays;
  final String? photoUrl;
  final int sortOrder;
  final Map<String, dynamic> translations;
  final String updatedAt;

  const RahbariyatModel({
    required this.id,
    required this.fullName,
    required this.position,
    required this.category,
    this.birthYear,
    this.phone,
    this.biography,
    this.receptionDays,
    this.photoUrl,
    this.sortOrder = 0,
    this.translations = const {},
    required this.updatedAt,
  });

  factory RahbariyatModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> trans = {};
    if (map['translations'] is String) {
      trans = jsonDecode(map['translations'] as String) as Map<String, dynamic>? ?? {};
    } else if (map['translations'] is Map) {
      trans = Map<String, dynamic>.from(map['translations'] as Map);
    }
    return RahbariyatModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      birthYear: map['birth_year'] as int?,
      position: map['position'] as String,
      category: map['category'] as String,
      phone: map['phone'] as String?,
      biography: map['biography'] as String?,
      receptionDays: map['reception_days'] as String?,
      photoUrl: map['photo_url'] as String?,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      translations: trans,
      updatedAt: map['updated_at'] as String,
    );
  }

  String localizedName(String locale) {
    if (locale == 'uz') return fullName;
    return (translations[locale] as Map<String, dynamic>?)?['full_name'] as String? ?? fullName;
  }

  String localizedPosition(String locale) {
    if (locale == 'uz') return position;
    return (translations[locale] as Map<String, dynamic>?)?['position'] as String? ?? position;
  }
}
