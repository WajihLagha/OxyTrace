import 'dart:io';

import 'package:sqflite/sqflite.dart';

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
      version: 6,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
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
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE intubations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        antecedent_intubation_difficile INTEGER NOT NULL DEFAULT 0,
        saos INTEGER NOT NULL DEFAULT 0,
        diabete INTEGER NOT NULL DEFAULT 0,
        goitre INTEGER NOT NULL DEFAULT 0,
        maladie_rhumatismale INTEGER NOT NULL DEFAULT 0,
        traumatisme_cervical INTEGER NOT NULL DEFAULT 0,
        brulure_cervico_faciale INTEGER NOT NULL DEFAULT 0,
        brulure_localisation TEXT,
        dysmorphie_cranio_faciale INTEGER NOT NULL DEFAULT 0,
        dysmorphie_localisation TEXT,
        tumeur_cervicofaciale INTEGER NOT NULL DEFAULT 0,
        tumeur_localisation TEXT,
        ronflement INTEGER NOT NULL DEFAULT 0,
        dysphonie INTEGER NOT NULL DEFAULT 0,
        dysphagie INTEGER NOT NULL DEFAULT 0,
        acte_operatoire TEXT,
        score_stopbang INTEGER,
        mallampati TEXT,
        dtm TEXT,
        ouverture_buccale TEXT,
        tour_de_cou TEXT,
        mobilite_cervicale TEXT,
        macroglossie INTEGER NOT NULL DEFAULT 0,
        score_asa TEXT,
        intubation_prevue TEXT,
        type_intubation TEXT,
        nombre_tentatives INTEGER,
        videolaryngoscope INTEGER NOT NULL DEFAULT 0,
        guide_eichmann INTEGER NOT NULL DEFAULT 0,
        score_cormack TEXT,
        intubation_difficile_reelle INTEGER NOT NULL DEFAULT 0,
        complications TEXT,
        photo_paths TEXT,
        audio_path TEXT
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

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE intubations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          patient_id INTEGER NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          antecedent_intubation_difficile INTEGER NOT NULL DEFAULT 0,
          saos INTEGER NOT NULL DEFAULT 0,
          diabete INTEGER NOT NULL DEFAULT 0,
          goitre INTEGER NOT NULL DEFAULT 0,
          maladie_rhumatismale INTEGER NOT NULL DEFAULT 0,
          traumatisme_cervical INTEGER NOT NULL DEFAULT 0,
          brulure_cervico_faciale INTEGER NOT NULL DEFAULT 0,
          brulure_localisation TEXT,
          dysmorphie_cranio_faciale INTEGER NOT NULL DEFAULT 0,
          dysmorphie_localisation TEXT,
          tumeur_cervicofaciale INTEGER NOT NULL DEFAULT 0,
          tumeur_localisation TEXT,
          ronflement INTEGER NOT NULL DEFAULT 0,
          dysphonie INTEGER NOT NULL DEFAULT 0,
          dysphagie INTEGER NOT NULL DEFAULT 0,
          acte_operatoire TEXT,
          score_stopbang INTEGER,
          mallampati TEXT,
          dtm TEXT,
          ouverture_buccale TEXT,
          tour_de_cou TEXT,
          mobilite_cervicale TEXT,
          macroglossie INTEGER NOT NULL DEFAULT 0,
          score_asa TEXT,
          intubation_prevue TEXT,
          type_intubation TEXT,
          nombre_tentatives INTEGER,
          videolaryngoscope INTEGER NOT NULL DEFAULT 0,
          guide_eichmann INTEGER NOT NULL DEFAULT 0,
          score_cormack TEXT,
          intubation_difficile_reelle INTEGER NOT NULL DEFAULT 0,
          complications TEXT,
          photo_paths TEXT
        )
      ''');
    }

    if (oldVersion < 4) {
      await _addColumnIfMissing(
        db,
        table: 'intubations',
        column: 'ronflement',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: 'intubations',
        column: 'dysphonie',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: 'intubations',
        column: 'dysphagie',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: 'intubations',
        column: 'tumeur_cervicofaciale',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        table: 'intubations',
        column: 'tumeur_localisation',
        definition: 'TEXT',
      );
      await _addColumnIfMissing(
        db,
        table: 'intubations',
        column: 'acte_operatoire',
        definition: 'TEXT',
      );
    }

    if (oldVersion < 5) {
      await _addColumnIfMissing(
        db,
        table: 'intubations',
        column: 'audio_path',
        definition: 'TEXT',
      );
    }

    if (oldVersion < 6) {
      await _addColumnIfMissing(
        db,
        table: 'patients',
        column: 'is_synced',
        definition: 'INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((entry) => entry['name'] == column);
    if (!exists) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $definition',
      );
    }
  }
}
