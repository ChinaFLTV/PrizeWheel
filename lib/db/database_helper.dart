import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/wheel_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'prize_wheel.db');
    return openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wheels (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        style INTEGER NOT NULL DEFAULT 0,
        size INTEGER NOT NULL DEFAULT 1,
        form INTEGER NOT NULL DEFAULT 0,
        spinDuration REAL NOT NULL DEFAULT 5.0,
        spinSpeed INTEGER NOT NULL DEFAULT 1,
        pointerPosition INTEGER NOT NULL DEFAULT 0,
        pointerStyle INTEGER NOT NULL DEFAULT 0,
        showResult INTEGER NOT NULL DEFAULT 1,
        enableSound INTEGER NOT NULL DEFAULT 1,
        is3D INTEGER NOT NULL DEFAULT 0,
        backgroundImagePath TEXT,
        bgBlurEnabled INTEGER NOT NULL DEFAULT 0,
        bgBlurIntensity REAL NOT NULL DEFAULT 10.0,
        bgOpacity REAL NOT NULL DEFAULT 1.0,
        bgOverlayColor INTEGER NOT NULL DEFAULT 0,
        segments TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE spin_records (
        id TEXT PRIMARY KEY,
        wheelId TEXT NOT NULL,
        wheelTitle TEXT NOT NULL,
        prizeName TEXT NOT NULL,
        prizeColor INTEGER NOT NULL,
        spinTime TEXT NOT NULL,
        batchId TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS spin_records (
          id TEXT PRIMARY KEY,
          wheelId TEXT NOT NULL,
          wheelTitle TEXT NOT NULL,
          prizeName TEXT NOT NULL,
          prizeColor INTEGER NOT NULL,
          spinTime TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await _addColumnIfNotExists(db, 'wheels', 'is3D', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfNotExists(db, 'wheels', 'backgroundImagePath', 'TEXT');
    }
    if (oldVersion < 4) {
      await _addColumnIfNotExists(db, 'wheels', 'bgBlurEnabled', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfNotExists(db, 'wheels', 'bgBlurIntensity', 'REAL NOT NULL DEFAULT 10.0');
      await _addColumnIfNotExists(db, 'wheels', 'bgOpacity', 'REAL NOT NULL DEFAULT 1.0');
      await _addColumnIfNotExists(db, 'wheels', 'bgOverlayColor', 'INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 5) {
      await _addColumnIfNotExists(db, 'wheels', 'pointerStyle', 'INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 6) {
      await _addColumnIfNotExists(db, 'spin_records', 'batchId', 'TEXT');
    }
  }

  Future<void> _addColumnIfNotExists(Database db, String table, String column, String type) async {
    final cols = await db.rawQuery('PRAGMA table_info($table)');
    final exists = cols.any((c) => c['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  // Wheels
  Future<List<WheelModel>> getAllWheels() async {
    final db = await database;
    final maps = await db.query('wheels', orderBy: 'createdAt DESC');
    final wheels = <WheelModel>[];
    for (final m in maps) {
      try {
        wheels.add(WheelModel.fromMap(m));
      } catch (e) {
        debugPrint('Error parsing wheel: $e');
      }
    }
    return wheels;
  }

  Future<void> insertWheel(WheelModel wheel) async {
    final db = await database;
    await db.insert('wheels', wheel.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateWheel(WheelModel wheel) async {
    final db = await database;
    await db.update('wheels', wheel.toMap(), where: 'id = ?', whereArgs: [wheel.id]);
  }

  Future<void> deleteWheel(String id) async {
    final db = await database;
    await db.delete('wheels', where: 'id = ?', whereArgs: [id]);
    await db.delete('spin_records', where: 'wheelId = ?', whereArgs: [id]);
  }

  Future<void> deleteWheels(List<String> ids) async {
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.delete('wheels', where: 'id IN ($placeholders)', whereArgs: ids);
    await db.delete('spin_records', where: 'wheelId IN ($placeholders)', whereArgs: ids);
  }

  // Spin Records
  Future<void> insertSpinRecord(SpinRecord record) async {
    final db = await database;
    await db.insert('spin_records', record.toMap());
  }

  Future<List<SpinRecord>> getSpinRecords(String wheelId) async {
    final db = await database;
    final maps = await db.query('spin_records', where: 'wheelId = ?', whereArgs: [wheelId], orderBy: 'spinTime DESC');
    return maps.map((m) => SpinRecord.fromMap(m)).toList();
  }

  Future<void> deleteSpinRecord(String id) async {
    final db = await database;
    await db.delete('spin_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSpinRecords(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.delete('spin_records', where: 'id IN ($placeholders)', whereArgs: ids);
  }

  Future<void> deleteAllSpinRecords(String wheelId) async {
    final db = await database;
    await db.delete('spin_records', where: 'wheelId = ?', whereArgs: [wheelId]);
  }

  Future<void> deleteSpinRecordsByBatchId(String batchId) async {
    final db = await database;
    await db.delete('spin_records', where: 'batchId = ?', whereArgs: [batchId]);
  }
}
