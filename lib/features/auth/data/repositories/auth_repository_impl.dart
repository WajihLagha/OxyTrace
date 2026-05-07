import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/failures.dart' as core_errors;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;

  const AuthRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<core_errors.Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final passwordHash = _hashPassword(password.trim());
      final storedUser = await localDatasource.getUserByEmail(normalizedEmail);

      if (storedUser == null) {
        return Left(
          const core_errors.AuthFailure(
            'Aucun compte ne correspond à cette adresse e-mail.',
          ),
        );
      }

      if (storedUser.passwordHash != passwordHash) {
        return Left(
          const core_errors.AuthFailure(
            'Adresse e-mail ou mot de passe incorrect.',
          ),
        );
      }

      return Right(storedUser);
    } on DatabaseException {
      return Left(
        const core_errors.DatabaseFailure(
          'Une erreur de base de données est survenue lors de la connexion.',
        ),
      );
    } catch (_) {
      return Left(
        const core_errors.AuthFailure(
          'Une erreur inattendue est survenue lors de la connexion.',
        ),
      );
    }
  }

  @override
  Future<Either<core_errors.Failure, UserEntity>> register(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final trimmedFullName = fullName.trim();
      final existingUser = await localDatasource.getUserByEmail(
        normalizedEmail,
      );

      if (existingUser != null) {
        return Left(
          const core_errors.AuthFailure(
            'Cette adresse e-mail est déjà utilisée.',
          ),
        );
      }

      final userModel = UserModel(
        fullName: trimmedFullName,
        email: normalizedEmail,
        passwordHash: _hashPassword(password.trim()),
      );

      final insertedId = await localDatasource.insertUser(userModel);
      return Right(userModel.copyWith(id: insertedId));
    } on DatabaseException {
      return Left(
        const core_errors.DatabaseFailure(
          'Une erreur de base de données est survenue lors de la création du compte.',
        ),
      );
    } catch (_) {
      return Left(
        const core_errors.AuthFailure(
          'Une erreur inattendue est survenue lors de la création du compte.',
        ),
      );
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
