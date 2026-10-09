import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase(this.db);
  final Database db;

  static Future<LocalDatabase> open() async {
    final db = await openDatabase(
      path.join(await getDatabasesPath(), 'routine.db'),
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: createSchema,
    );
    return LocalDatabase(db);
  }

  // Also used by the repository tests with a real in-memory SQLite database.
  static Future<void> createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0 CHECK(is_done IN (0, 1)),
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX exercises_user ON exercises(user_id)');
  }
}
