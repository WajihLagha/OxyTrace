import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class UpdatePatientUseCase
    implements UseCase<PatientEntity, UpdatePatientParams> {
  final PatientRepository repository;

  const UpdatePatientUseCase(this.repository);

  @override
  Future<Either<Failure, PatientEntity>> call(
    UpdatePatientParams params,
  ) async {
    try {
      return await repository.updatePatient(params.patient);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class UpdatePatientParams extends Equatable {
  final PatientEntity patient;

  const UpdatePatientParams(this.patient);

  @override
  List<Object?> get props => [patient];
}
