import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart' as core_errors;
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  const RegisterUseCase({required this.repository});

  @override
  Future<Either<core_errors.Failure, UserEntity>> call(
    RegisterParams params,
  ) async {
    try {
      return await repository.register(
        params.fullName,
        params.email,
        params.password,
      );
    } catch (_) {
      return Left(
        const core_errors.AuthFailure(
          'Une erreur inattendue est survenue lors de la création du compte.',
        ),
      );
    }
  }
}

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String password;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, password];
}
