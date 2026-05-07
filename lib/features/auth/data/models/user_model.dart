import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    required super.fullName,
    required super.email,
    required super.passwordHash,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'password_hash': passwordHash,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
    );
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? passwordHash,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}
