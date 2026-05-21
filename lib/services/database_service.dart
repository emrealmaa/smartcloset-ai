import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/clothing_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'smartcloset.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clothes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        price REAL,
        category TEXT NOT NULL,
        color TEXT,
        season TEXT,
        image_path TEXT,
        weather_tag TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE outfits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        occasion TEXT,
        weather_tag TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE outfit_clothes (
        outfit_id TEXT NOT NULL,
        clothes_id TEXT NOT NULL,
        layer_order INTEGER DEFAULT 0,
        PRIMARY KEY (outfit_id, clothes_id)
      )
    ''');
  }

  // ── CRUD: Clothes ─────────────────────────────────────────────

  Future<void> insertClothing(ClothingModel item) async {
    final db = await database;
    await db.insert(
      'clothes',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClothingModel>> getAllClothes() async {
    final db = await database;
    final maps = await db.query('clothes', orderBy: 'created_at DESC');
    return maps.map((m) => ClothingModel.fromMap(m)).toList();
  }

  Future<List<ClothingModel>> getClothesByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'clothes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => ClothingModel.fromMap(m)).toList();
  }

  Future<void> deleteClothing(String id) async {
    final db = await database;
    await db.delete('clothes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateClothing(ClothingModel item) async {
    final db = await database;
    await db.update(
      'clothes',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> getClothingCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM clothes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
