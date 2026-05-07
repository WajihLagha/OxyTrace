import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath${Platform.pathSeparator}intubation_app.db';

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone TEXT,
        sex TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        bmi REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE patients(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          first_name TEXT NOT NULL,
          last_name TEXT NOT NULL,
          phone TEXT,
          sex TEXT NOT NULL,
          birth_date TEXT NOT NULL,
          bmi REAL NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }
  }
}

class AuthLocalDatasource {
  final DatabaseHelper databaseHelper;

  const AuthLocalDatasource({required this.databaseHelper});

  Future<int> insertUser(UserModel user) async {
    final db = await databaseHelper.database;

    return db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(result.first);
  }
}
