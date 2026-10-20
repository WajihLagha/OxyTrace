import '../../../../shared/network/local/database_helper.dart';
import '../models/patient_model.dart';

class PatientLocalDatasource {
  final DatabaseHelper databaseHelper;

  const PatientLocalDatasource(this.databaseHelper);

  Future<int> insertPatient(PatientModel patient) async {
    final db = await databaseHelper.database;
    return db.insert('patients', patient.toMap());
  }

  Future<int> updatePatient(PatientModel patient) async {
    final db = await databaseHelper.database;
    return db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await databaseHelper.database;
    return db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PatientModel>> getAllPatients() async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'patients',
      orderBy: 'created_at DESC',
    );

    return result.map(PatientModel.fromMap).toList();
  }

  Future<List<PatientModel>> getPendingSyncPatients() async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'patients',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    return result.map(PatientModel.fromMap).toList();
  }

  Future<void> markPatientSynced(int id) async {
    final db = await databaseHelper.database;
    await db.update(
      'patients',
      {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PatientModel>> searchPatients(String query) async {
    final db = await databaseHelper.database;
    final normalizedQuery = '%${query.trim().toLowerCase()}%';
    final result = await db.query(
      'patients',
      where: 'LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?',
      whereArgs: [normalizedQuery, normalizedQuery],
      orderBy: 'created_at DESC',
    );

    return result.map(PatientModel.fromMap).toList();
  }

  Future<PatientModel?> getPatientById(int id) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return PatientModel.fromMap(result.first);
  }

  Future<int> getPatientsCount() async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM patients');
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getIntubationsCount() async {
    final db = await databaseHelper.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) AS count FROM intubations');
    return (result.first['count'] as int?) ?? 0;
  }
}
