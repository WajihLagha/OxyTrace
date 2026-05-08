import '../../../../shared/network/local/database_helper.dart';
import '../models/intubation_model.dart';

class IntubationLocalDatasource {
  final DatabaseHelper databaseHelper;

  const IntubationLocalDatasource(this.databaseHelper);

  Future<int> insertIntubation(IntubationModel intubation) async {
    final db = await databaseHelper.database;
    return db.insert('intubations', intubation.toMap());
  }

  Future<int> updateIntubation(IntubationModel intubation) async {
    final db = await databaseHelper.database;
    return db.update(
      'intubations',
      intubation.toMap(),
      where: 'id = ?',
      whereArgs: [intubation.id],
    );
  }

  Future<int> deleteIntubation(int id) async {
    final db = await databaseHelper.database;
    return db.delete(
      'intubations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<IntubationModel>> getIntubationsByPatient(int patientId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'intubations',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );

    return result.map(IntubationModel.fromMap).toList();
  }

  Future<IntubationModel?> getIntubationById(int id) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'intubations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return IntubationModel.fromMap(result.first);
  }
}
