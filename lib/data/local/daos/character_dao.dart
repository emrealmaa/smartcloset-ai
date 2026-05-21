import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../../../models/character_profile.dart';

class CharacterDao {
  final AppDatabase _db = AppDatabase.instance;

  Future<int> insert(CharacterProfile profile) async {
    final db = await _db.database;
    return db.insert(
      'character_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CharacterProfile?> getByUserId(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'character_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CharacterProfile.fromMap(rows.first);
  }

  Future<int> update(CharacterProfile profile) async {
    final db = await _db.database;
    return db.update(
      'character_profiles',
      profile.toMap(),
      where: 'user_id = ?',
      whereArgs: [profile.userId],
    );
  }

  Future<int> delete(String userId) async {
    final db = await _db.database;
    return db.delete(
      'character_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
