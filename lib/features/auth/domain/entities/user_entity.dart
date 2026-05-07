import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int? id;
  final String fullName;
  final String email;
  final String passwordHash;

  const UserEntity({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
  });

  @override
  List<Object?> get props => [id, fullName, email, passwordHash];
}
