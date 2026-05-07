import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart' as core_errors;
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase({required this.repository});

  @override
  Future<Either<core_errors.Failure, UserEntity>> call(
    LoginParams params,
  ) async {
    try {
      return await repository.login(params.email, params.password);
    } catch (_) {
      return Left(
        const core_errors.AuthFailure(
          'Une erreur inattendue est survenue lors de la connexion.',
        ),
      );
    }
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
