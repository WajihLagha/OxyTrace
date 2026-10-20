import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthOtpSent extends AuthState {
  final String email;
  final String? message;
  final String? errorMessage;
  final bool isVerifying;

  const AuthOtpSent({
    required this.email,
    this.message,
    this.errorMessage,
    this.isVerifying = false,
  });

  @override
  List<Object?> get props => [email, message, errorMessage, isVerifying];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
