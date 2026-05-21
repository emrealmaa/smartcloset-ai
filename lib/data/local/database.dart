import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static AppDatabase? _instance;
  static Database? _db;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'style_edu_v1.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE character_profiles (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id         TEXT NOT NULL UNIQUE,
        height_cm       INTEGER NOT NULL,
        weight_kg       REAL NOT NULL,
        body_type       TEXT NOT NULL,
        shoulder_width  TEXT NOT NULL,
        torso_length    TEXT NOT NULL,
        leg_length      TEXT NOT NULL,
        skin_depth      TEXT NOT NULL,
        skin_undertone  TEXT NOT NULL,
        face_shape      TEXT NOT NULL,
        eye_color       TEXT NOT NULL,
        hair_color      TEXT NOT NULL,
        hair_length     TEXT NOT NULL,
        hair_texture    TEXT NOT NULL,
        beard_style     TEXT NOT NULL,
        style_goals     TEXT NOT NULL DEFAULT '',
        created_at      TEXT NOT NULL,
        updated_at      TEXT NOT NULL
      )
    ''');

    // Phase 2 — Kıyafet envanteri
    await db.execute('''
      CREATE TABLE clothing_items (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id             TEXT NOT NULL,
        name                TEXT NOT NULL,
        brand               TEXT,
        category            TEXT NOT NULL,
        subcategory         TEXT NOT NULL,
        primary_color_hex   TEXT NOT NULL,
        primary_color_name  TEXT NOT NULL,
        color_family        TEXT NOT NULL,
        color_saturation    TEXT NOT NULL,
        color_value         TEXT NOT NULL,
        secondary_color_hex TEXT,
        fit_type            TEXT NOT NULL,
        length_type         TEXT,
        fabric_type         TEXT NOT NULL,
        fabric_weight       TEXT NOT NULL,
        pattern_type        TEXT NOT NULL,
        pattern_scale       TEXT,
        occasion_tags       TEXT NOT NULL DEFAULT '[]',
        season_tags         TEXT NOT NULL DEFAULT '[]',
        condition           TEXT NOT NULL DEFAULT 'good',
        image_path          TEXT,
        notes               TEXT,
        is_active           INTEGER NOT NULL DEFAULT 1,
        created_at          TEXT NOT NULL,
        updated_at          TEXT NOT NULL
      )
    ''');

    // Phase 3 — Kombinler
    await db.execute('''
      CREATE TABLE outfits (
        id                   INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id              TEXT NOT NULL,
        name                 TEXT,
        occasion             TEXT,
        season               TEXT,
        harmony_score        INTEGER,
        versatility_score    INTEGER,
        primary_rule_applied TEXT,
        explanation_json     TEXT,
        is_favorite          INTEGER DEFAULT 0,
        created_at           TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE outfit_items (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        outfit_id        INTEGER NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
        clothing_item_id INTEGER NOT NULL REFERENCES clothing_items(id),
        layer_order      INTEGER NOT NULL
      )
    ''');

    // Phase 3 — Eksik parça analizi
    await db.execute('''
      CREATE TABLE wardrobe_gaps (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id          TEXT NOT NULL,
        subcategory      TEXT NOT NULL,
        color_suggestion TEXT NOT NULL,
        priority         INTEGER NOT NULL,
        reason           TEXT NOT NULL,
        is_dismissed     INTEGER DEFAULT 0,
        created_at       TEXT NOT NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_clothing_user ON clothing_items(user_id, is_active)');
    await db.execute(
        'CREATE INDEX idx_outfits_user ON outfits(user_id)');
  }
}
