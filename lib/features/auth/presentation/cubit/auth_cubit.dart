import 'package:email_otp/email_otp.dart';
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

  _PendingRegistration? _pendingRegistration;

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
          await _persistSession(user);
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
    await sendRegistrationOtp(fullName, email, password);
  }

  Future<void> sendRegistrationOtp(
    String fullName,
    String email,
    String password,
  ) async {
    emit(const AuthLoading());

    try {
      final normalizedEmail = email.trim().toLowerCase();
      _pendingRegistration = _PendingRegistration(
        fullName: fullName.trim(),
        email: normalizedEmail,
        password: password.trim(),
      );

      final sent = await EmailOTP.sendOTP(email: normalizedEmail);
      if (!sent) {
        emit(
          const AuthFailure(
            "Impossible d'envoyer le code de vérification. Vérifiez la configuration SMTP.",
          ),
        );
        return;
      }

      emit(
        AuthOtpSent(
          email: normalizedEmail,
          message: 'Code de vérification envoyé par e-mail.',
        ),
      );
    } catch (_) {
      emit(
        const AuthFailure(
          "Impossible d'envoyer le code de vérification. Vérifiez la configuration SMTP.",
        ),
      );
    }
  }

  Future<void> resendRegistrationOtp() async {
    final pending = _pendingRegistration;
    if (pending == null) {
      emit(
        const AuthFailure(
          'Aucune inscription en attente. Veuillez recommencer.',
        ),
      );
      return;
    }

    await sendRegistrationOtp(
      pending.fullName,
      pending.email,
      pending.password,
    );
  }

  Future<void> verifyRegistrationOtp(String otp) async {
    final pending = _pendingRegistration;
    if (pending == null) {
      emit(
        const AuthFailure(
          'Aucune inscription en attente. Veuillez recommencer.',
        ),
      );
      return;
    }

    emit(AuthOtpSent(email: pending.email, isVerifying: true));

    try {
      if (EmailOTP.isOtpExpired()) {
        emit(
          AuthOtpSent(
            email: pending.email,
            errorMessage: 'Le code a expiré. Demandez un nouveau code.',
          ),
        );
        return;
      }

      final isVerified = EmailOTP.verifyOTP(otp: otp.trim());
      if (!isVerified) {
        emit(
          AuthOtpSent(
            email: pending.email,
            errorMessage: 'Code incorrect. Veuillez réessayer.',
          ),
        );
        return;
      }

      final result = await registerUseCase(
        RegisterParams(
          fullName: pending.fullName,
          email: pending.email,
          password: pending.password,
        ),
      );

      await result.fold(
        (failure) async => emit(AuthFailure(failure.message)),
        (user) async {
          _pendingRegistration = null;
          await _persistSession(user);
          emit(AuthSuccess(user));
        },
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
    _pendingRegistration = null;
    emit(const AuthInitial());
  }

  Future<void> _persistSession(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, true);
    await prefs.setInt(loggedInUserIdKey, user.id!);
    await prefs.setString(loggedInUserEmailKey, user.email);
    await prefs.setString(loggedInUserNameKey, user.fullName);
  }
}

class _PendingRegistration {
  final String fullName;
  final String email;
  final String password;

  const _PendingRegistration({
    required this.fullName,
    required this.email,
    required this.password,
  });
}
