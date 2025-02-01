import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('game_history.db');
    return _database!;
  }
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result TEXT NOT NULL
      )
    ''');
  }
  Future<int> insertHistory(String result) async {
    final db = await instance.database;
    return await db.insert('history', {'result': result});
  }
  Future<List<String>> getHistory() async {
    final db = await instance.database;
    final result = await db.query('history', orderBy: 'id DESC');
    return result.map((row) => row['result'] as String).toList();
  }
}
