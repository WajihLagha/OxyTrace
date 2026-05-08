import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/intubation_entity.dart';
import '../repositories/intubation_repository.dart';

class CreateIntubationUseCase
    implements UseCase<IntubationEntity, CreateIntubationParams> {
  final IntubationRepository repository;

  const CreateIntubationUseCase(this.repository);

  @override
  Future<Either<Failure, IntubationEntity>> call(
    CreateIntubationParams params,
  ) async {
    try {
      return await repository.createIntubation(params.intubation);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class CreateIntubationParams extends Equatable {
  final IntubationEntity intubation;

  const CreateIntubationParams(this.intubation);

  @override
  List<Object?> get props => [intubation];
}
