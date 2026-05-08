import 'package:sqflite/sqflite.dart';

import '../../../../shared/network/local/database_helper.dart';
import '../models/user_model.dart';

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
