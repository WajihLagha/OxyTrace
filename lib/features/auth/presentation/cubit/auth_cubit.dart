import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final result = await loginUseCase(
        LoginParams(email: email, password: password),
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (_) {
      emit(
        const AuthFailure(
          'Une erreur inattendue est survenue lors de la connexion.',
        ),
      );
    }
  }

  Future<void> register(
    String fullName,
    String email,
    String password,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await registerUseCase(
        RegisterParams(
          fullName: fullName,
          email: email,
          password: password,
        ),
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (_) {
      emit(
        const AuthFailure(
          'Une erreur inattendue est survenue lors de la création du compte.',
        ),
      );
    }
  }

  void reset() {
    emit(const AuthInitial());
  }
}
