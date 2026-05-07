import '../../../auth/data/datasources/auth_local_datasource.dart';
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
}
