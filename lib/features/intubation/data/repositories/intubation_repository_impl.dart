import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/intubation_entity.dart';
import '../../domain/repositories/intubation_repository.dart';
import '../datasources/intubation_local_datasource.dart';
import '../models/intubation_model.dart';

class IntubationRepositoryImpl implements IntubationRepository {
  final IntubationLocalDatasource localDatasource;

  const IntubationRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, IntubationEntity>> createIntubation(
    IntubationEntity intubation,
  ) async {
    try {
      final model = IntubationModel.fromEntity(intubation);
      final insertedId = await localDatasource.insertIntubation(model);
      return Right(model.copyWith(id: insertedId));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, IntubationEntity>> updateIntubation(
    IntubationEntity intubation,
  ) async {
    try {
      final model = IntubationModel.fromEntity(intubation);
      await localDatasource.updateIntubation(model);
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteIntubation(int id) async {
    try {
      await localDatasource.deleteIntubation(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<IntubationEntity>>> getIntubationsByPatient(
    int patientId,
  ) async {
    try {
      final intubations = await localDatasource.getIntubationsByPatient(
        patientId,
      );
      return Right(intubations);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
