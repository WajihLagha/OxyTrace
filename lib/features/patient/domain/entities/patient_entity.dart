import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final int? id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String sex;
  final DateTime birthDate;
  final double bmi;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientEntity({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.sex,
    required this.birthDate,
    required this.bmi,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int get age => DateTime.now().difference(birthDate).inDays ~/ 365;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phone,
        sex,
        birthDate,
        bmi,
        isSynced,
        createdAt,
        updatedAt,
      ];
}
