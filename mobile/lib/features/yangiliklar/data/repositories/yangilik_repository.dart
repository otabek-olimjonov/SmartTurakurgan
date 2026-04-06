import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/core/db/local_database.dart';
import 'package:smart_turakurgan/shared/models/yangilik_model.dart';

class YangilikRepository {
  Future<List<YangilikModel>> getNews({int limit = 20, int offset = 0}) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'yangiliklar',
      where: 'is_published = 1',
      orderBy: 'published_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(YangilikModel.fromMap).toList();
  }

  Future<YangilikModel?> getById(String id) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('yangiliklar', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return YangilikModel.fromMap(rows.first);
  }
}

final yangilikRepositoryProvider = Provider<YangilikRepository>((ref) => YangilikRepository());

final newsProvider = FutureProvider<List<YangilikModel>>((ref) async {
  return ref.read(yangilikRepositoryProvider).getNews();
});

final yangilikByIdProvider =
    FutureProvider.family<YangilikModel?, String>((ref, id) async {
  return ref.read(yangilikRepositoryProvider).getById(id);
});
