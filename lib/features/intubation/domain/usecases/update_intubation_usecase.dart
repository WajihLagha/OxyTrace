import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/intubation_entity.dart';
import '../repositories/intubation_repository.dart';

class UpdateIntubationUseCase
    implements UseCase<IntubationEntity, UpdateIntubationParams> {
  final IntubationRepository repository;

  const UpdateIntubationUseCase(this.repository);

  @override
  Future<Either<Failure, IntubationEntity>> call(
    UpdateIntubationParams params,
  ) async {
    try {
      return await repository.updateIntubation(params.intubation);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class UpdateIntubationParams extends Equatable {
  final IntubationEntity intubation;

  const UpdateIntubationParams(this.intubation);

  @override
  List<Object?> get props => [intubation];
}
