import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/patient_repository.dart';

class DeletePatientUseCase implements UseCase<void, DeletePatientParams> {
  final PatientRepository repository;

  const DeletePatientUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePatientParams params) async {
    try {
      return await repository.deletePatient(params.id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class DeletePatientParams extends Equatable {
  final int id;

  const DeletePatientParams(this.id);

  @override
  List<Object?> get props => [id];
}
