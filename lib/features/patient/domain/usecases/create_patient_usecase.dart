import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class CreatePatientUseCase
    implements UseCase<PatientEntity, CreatePatientParams> {
  final PatientRepository repository;

  const CreatePatientUseCase(this.repository);

  @override
  Future<Either<Failure, PatientEntity>> call(
    CreatePatientParams params,
  ) async {
    try {
      return await repository.createPatient(params.patient);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class CreatePatientParams extends Equatable {
  final PatientEntity patient;

  const CreatePatientParams(this.patient);

  @override
  List<Object?> get props => [patient];
}
