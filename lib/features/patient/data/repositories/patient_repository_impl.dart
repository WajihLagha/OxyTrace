import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_local_datasource.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDatasource localDatasource;

  const PatientRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, PatientEntity>> createPatient(
    PatientEntity patient,
  ) async {
    try {
      final model = PatientModel.fromEntity(patient);
      final id = await localDatasource.insertPatient(model);
      return Right(model.copyWith(id: id));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> updatePatient(
    PatientEntity patient,
  ) async {
    try {
      final model = PatientModel.fromEntity(patient);
      await localDatasource.updatePatient(model);
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePatient(int id) async {
    try {
      await localDatasource.deletePatient(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PatientEntity>>> getAllPatients() async {
    try {
      final patients = await localDatasource.getAllPatients();
      return Right(patients);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PatientEntity>>> searchPatients(
    String query,
  ) async {
    try {
      final patients = await localDatasource.searchPatients(query);
      return Right(patients);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
