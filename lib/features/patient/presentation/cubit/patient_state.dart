import 'package:equatable/equatable.dart';

import '../../domain/entities/patient_entity.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {
  const PatientInitial();
}

class PatientLoading extends PatientState {
  const PatientLoading();
}

class PatientListLoaded extends PatientState {
  final List<PatientEntity> patients;

  const PatientListLoaded(this.patients);

  @override
  List<Object?> get props => [patients];
}

class PatientOperationSuccess extends PatientState {
  final PatientEntity patient;
  final String message;

  const PatientOperationSuccess(this.patient, this.message);

  @override
  List<Object?> get props => [patient, message];
}

class PatientDeleted extends PatientState {
  const PatientDeleted();
}

class PatientError extends PatientState {
  final String message;

  const PatientError(this.message);

  @override
  List<Object?> get props => [message];
}
