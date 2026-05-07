import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/patient_entity.dart';

abstract class PatientRepository {
  Future<Either<Failure, PatientEntity>> createPatient(PatientEntity patient);

  Future<Either<Failure, PatientEntity>> updatePatient(PatientEntity patient);

  Future<Either<Failure, void>> deletePatient(int id);

  Future<Either<Failure, List<PatientEntity>>> getAllPatients();

  Future<Either<Failure, List<PatientEntity>>> searchPatients(String query);
}
