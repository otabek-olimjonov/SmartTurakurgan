import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smart_turakurgan/core/db/local_database.dart';
import 'package:smart_turakurgan/shared/models/place_model.dart';

class PlacesRepository {
  Future<List<PlaceModel>> getByCategory(String category) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'places',
      where: 'category = ? AND is_published = 1',
      whereArgs: [category],
      orderBy: 'name ASC',
    );

    final places = rows.map(PlaceModel.fromMap).toList();

    // Attach images
    for (final place in places) {
      final imgRows = await db.query(
        'place_images',
        where: 'place_id = ?',
        whereArgs: [place.id],
        orderBy: 'is_main DESC, sort_order ASC',
      );
      place.imageUrls = imgRows.map((r) => r['image_url'] as String).toList();
    }

    return places;
  }

  Future<PlaceModel?> getById(String id) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('places', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final place = PlaceModel.fromMap(rows.first);
    final imgRows = await db.query('place_images', where: 'place_id = ?', whereArgs: [id], orderBy: 'is_main DESC, sort_order ASC');
    place.imageUrls = imgRows.map((r) => r['image_url'] as String).toList();
    return place;
  }

  Future<List<PlaceModel>> search(String query, {String? category}) async {
    final db = await LocalDatabase.instance;
    final likeQuery = '%${query.toLowerCase()}%';
    String where = '(LOWER(name) LIKE ? OR LOWER(description) LIKE ?) AND is_published = 1';
    final args = [likeQuery, likeQuery];
    if (category != null) {
      where += ' AND category = ?';
      args.add(category);
    }
    final rows = await db.query('places', where: where, whereArgs: args, orderBy: 'name ASC');
    return rows.map(PlaceModel.fromMap).toList();
  }
}

final placesRepositoryProvider = Provider<PlacesRepository>((ref) => PlacesRepository());

final placesByCategoryProvider =
    FutureProvider.family<List<PlaceModel>, String>((ref, category) async {
  return ref.read(placesRepositoryProvider).getByCategory(category);
});

final placeByIdProvider =
    FutureProvider.family<PlaceModel?, String>((ref, id) async {
  return ref.read(placesRepositoryProvider).getById(id);
});
