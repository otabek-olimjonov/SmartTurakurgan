import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_turakurgan.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rahbariyat (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        birth_year INTEGER,
        position TEXT NOT NULL,
        category TEXT NOT NULL,
        phone TEXT,
        biography TEXT,
        reception_days TEXT,
        photo_url TEXT,
        sort_order INTEGER DEFAULT 0,
        is_published INTEGER DEFAULT 1,
        translations TEXT DEFAULT '{}',
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mahallalar (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        location_lat REAL,
        location_lng REAL,
        building_photo_url TEXT,
        is_published INTEGER DEFAULT 1,
        translations TEXT DEFAULT '{}',
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mahalla_xodimlari (
        id TEXT PRIMARY KEY,
        mahalla_id TEXT NOT NULL,
        full_name TEXT NOT NULL,
        birth_year INTEGER,
        position TEXT NOT NULL,
        phone TEXT,
        biography TEXT,
        photo_url TEXT,
        sort_order INTEGER DEFAULT 0,
        translations TEXT DEFAULT '{}',
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS yer_maydonlari (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        area_hectares REAL,
        location_lat REAL,
        location_lng REAL,
        status TEXT DEFAULT 'active',
        auction_url TEXT,
        description TEXT,
        is_published INTEGER DEFAULT 1,
        translations TEXT DEFAULT '{}',
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS places (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        director TEXT,
        phone TEXT,
        description TEXT,
        location_lat REAL,
        location_lng REAL,
        rating REAL DEFAULT 0,
        comment_count INTEGER DEFAULT 0,
        is_published INTEGER DEFAULT 1,
        translations TEXT DEFAULT '{}',
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS place_images (
        id TEXT PRIMARY KEY,
        place_id TEXT NOT NULL,
        image_url TEXT NOT NULL,
        is_main INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS yangilik_images (
        id TEXT PRIMARY KEY,
        yangilik_id TEXT NOT NULL,
        image_url TEXT NOT NULL,
        is_main INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS yangiliklar (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT,
        cover_image_url TEXT,
        category TEXT DEFAULT 'general',
        is_published INTEGER DEFAULT 1,
        published_at TEXT,
        translations TEXT DEFAULT '{}',
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS murojaatlar (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ai_chat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_rahbariyat_category ON rahbariyat(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_rahbariyat_updated ON rahbariyat(updated_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_places_category ON places(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_places_updated ON places(updated_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_yangiliklar_published ON yangiliklar(published_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_mahalla_xodimlari_mahalla ON mahalla_xodimlari(mahalla_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_place_images_place ON place_images(place_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_yangilik_images_yangilik ON yangilik_images(yangilik_id)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE place_images ADD COLUMN is_main INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS yangilik_images (
          id TEXT PRIMARY KEY,
          yangilik_id TEXT NOT NULL,
          image_url TEXT NOT NULL,
          is_main INTEGER DEFAULT 0,
          sort_order INTEGER DEFAULT 0,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_yangilik_images_yangilik ON yangilik_images(yangilik_id)');
    }
  }
}
