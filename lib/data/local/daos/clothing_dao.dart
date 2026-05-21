import '../database.dart';
import '../../../models/clothing_item.dart';
import '../../../core/enums/clothing_enums.dart';

class ClothingDao {
  final AppDatabase _db = AppDatabase.instance;

  Future<int> insert(ClothingItem item) async {
    final db = await _db.database;
    return db.insert('clothing_items', item.toMap());
  }

  Future<List<ClothingItem>> getAllByUser(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'clothing_items',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(ClothingItem.fromMap).toList();
  }

  Future<List<ClothingItem>> getByCategory(
      String userId, ClothingCategory category) async {
    final db = await _db.database;
    final rows = await db.query(
      'clothing_items',
      where: 'user_id = ? AND category = ? AND is_active = 1',
      whereArgs: [userId, category.name],
      orderBy: 'created_at DESC',
    );
    return rows.map(ClothingItem.fromMap).toList();
  }

  Future<ClothingItem?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ClothingItem.fromMap(rows.first);
  }

  Future<int> update(ClothingItem item) async {
    final db = await _db.database;
    return db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> softDelete(int id) async {
    final db = await _db.database;
    return db.update(
      'clothing_items',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countByUser(String userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM clothing_items WHERE user_id = ? AND is_active = 1',
      [userId],
    );
    return result.first['cnt'] as int;
  }
}
