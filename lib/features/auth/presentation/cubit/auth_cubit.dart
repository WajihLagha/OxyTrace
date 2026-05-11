import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  static const String isLoggedInKey = 'is_logged_in';
  static const String loggedInUserIdKey = 'logged_in_user_id';
  static const String loggedInUserEmailKey = 'logged_in_user_email';
  static const String loggedInUserNameKey = 'logged_in_user_name';

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
          await prefs.setBool(isLoggedInKey, true);
          await prefs.setInt(loggedInUserIdKey, user.id!);
          await prefs.setString(loggedInUserEmailKey, user.email);
          await prefs.setString(loggedInUserNameKey, user.fullName);
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
    await prefs.setBool(isLoggedInKey, false);
    await prefs.remove(loggedInUserIdKey);
    await prefs.remove(loggedInUserEmailKey);
    await prefs.remove(loggedInUserNameKey);
    emit(const AuthInitial());
  }

  Future<UserEntity?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(loggedInUserIdKey);
    final email = prefs.getString(loggedInUserEmailKey) ?? '';
    final name = prefs.getString(loggedInUserNameKey) ?? '';

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
