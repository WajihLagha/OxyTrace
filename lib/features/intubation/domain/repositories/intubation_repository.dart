import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/intubation_entity.dart';

abstract class IntubationRepository {
  Future<Either<Failure, IntubationEntity>> createIntubation(
    IntubationEntity intubation,
  );

  Future<Either<Failure, IntubationEntity>> updateIntubation(
    IntubationEntity intubation,
  );

  Future<Either<Failure, void>> deleteIntubation(int id);

  Future<Either<Failure, List<IntubationEntity>>> getIntubationsByPatient(
    int patientId,
  );
}
