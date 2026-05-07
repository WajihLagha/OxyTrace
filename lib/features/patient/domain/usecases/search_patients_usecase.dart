import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class SearchPatientsUseCase
    implements UseCase<List<PatientEntity>, SearchPatientsParams> {
  final PatientRepository repository;

  const SearchPatientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PatientEntity>>> call(
    SearchPatientsParams params,
  ) async {
    try {
      return await repository.searchPatients(params.query);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class SearchPatientsParams extends Equatable {
  final String query;

  const SearchPatientsParams(this.query);

  @override
  List<Object?> get props => [query];
}
