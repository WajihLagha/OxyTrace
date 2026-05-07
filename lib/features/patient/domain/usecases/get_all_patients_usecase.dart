import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class GetAllPatientsUseCase
    implements UseCase<List<PatientEntity>, NoParams> {
  final PatientRepository repository;

  const GetAllPatientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PatientEntity>>> call(NoParams params) async {
    try {
      return await repository.getAllPatients();
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
