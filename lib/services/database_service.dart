import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/qr_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'qr_items.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id TEXT PRIMARY KEY,
            isGenerated INTEGER,
            type TEXT,
            category TEXT,
            content TEXT,
            label TEXT,
            isFavorite INTEGER,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertItem(QrItem item) async {
    final db = await database;
    await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(QrItem item) async {
    final db = await database;
    await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<QrItem>> getItems({bool? isFavorite}) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (isFavorite != null) {
      where = 'isFavorite = ?';
      whereArgs = [isFavorite ? 1 : 0];
    }

    final maps = await db.query('items', where: where, whereArgs: whereArgs, orderBy: 'timestamp DESC');
    return maps.map((map) => QrItem.fromMap(map)).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('items', where: 'isFavorite = ?', whereArgs: [0]); // keep favorites
  }
}
