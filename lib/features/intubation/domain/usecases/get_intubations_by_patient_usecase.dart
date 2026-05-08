import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/intubation_entity.dart';
import '../repositories/intubation_repository.dart';

class GetIntubationsByPatientUseCase
    implements UseCase<List<IntubationEntity>, GetIntubationsByPatientParams> {
  final IntubationRepository repository;

  const GetIntubationsByPatientUseCase(this.repository);

  @override
  Future<Either<Failure, List<IntubationEntity>>> call(
    GetIntubationsByPatientParams params,
  ) async {
    try {
      return await repository.getIntubationsByPatient(params.patientId);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class GetIntubationsByPatientParams extends Equatable {
  final int patientId;

  const GetIntubationsByPatientParams(this.patientId);

  @override
  List<Object?> get props => [patientId];
}
