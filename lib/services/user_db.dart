import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserDB {
  static final UserDB _instance = UserDB._internal();
  factory UserDB() => _instance;
  UserDB._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'user_cache.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveUid(String uid) async {
    final db = await database;
    await db.delete('user'); // เก็บ uid เดียว
    await db.insert('user', {'uid': uid});
  }

  Future<String?> getUid() async {
    final db = await database;
    final result = await db.query('user', limit: 1);
    if (result.isNotEmpty) {
      return result.first['uid'] as String;
    }
    return null;
  }

  Future<void> clearUid() async {
    final db = await database;
    await db.delete('user');
  }
}
