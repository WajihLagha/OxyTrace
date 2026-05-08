import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/intubation_repository.dart';

class DeleteIntubationUseCase
    implements UseCase<void, DeleteIntubationParams> {
  final IntubationRepository repository;

  const DeleteIntubationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteIntubationParams params) async {
    try {
      return await repository.deleteIntubation(params.id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class DeleteIntubationParams extends Equatable {
  final int id;

  const DeleteIntubationParams(this.id);

  @override
  List<Object?> get props => [id];
}
