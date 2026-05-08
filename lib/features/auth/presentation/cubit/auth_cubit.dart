import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_entity.dart';
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

      await result.fold(
        (failure) async => emit(AuthFailure(failure.message)),
        (user) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('logged_in_user_id', user.id!);
          await prefs.setString('logged_in_user_email', user.email);
          await prefs.setString('logged_in_user_name', user.fullName);
          emit(AuthSuccess(user));
        },
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user_id');
    await prefs.remove('logged_in_user_email');
    await prefs.remove('logged_in_user_name');
    emit(const AuthInitial());
  }

  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('logged_in_user_id');
    final email = prefs.getString('logged_in_user_email') ?? '';
    final name = prefs.getString('logged_in_user_name') ?? '';

    if (id == null) {
      return null;
    }

    return UserEntity(
      id: id,
      fullName: name,
      email: email,
      passwordHash: '',
    );
  }

  void reset() {
    emit(const AuthInitial());
  }
}
