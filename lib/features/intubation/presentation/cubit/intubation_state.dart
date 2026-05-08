import 'package:equatable/equatable.dart';

import '../../domain/entities/intubation_entity.dart';

abstract class IntubationState extends Equatable {
  const IntubationState();

  @override
  List<Object?> get props => [];
}

class IntubationInitial extends IntubationState {
  const IntubationInitial();
}

class IntubationLoading extends IntubationState {
  const IntubationLoading();
}

class IntubationListLoaded extends IntubationState {
  final List<IntubationEntity> intubations;

  const IntubationListLoaded(this.intubations);

  @override
  List<Object?> get props => [intubations];
}

class IntubationOperationSuccess extends IntubationState {
  final IntubationEntity intubation;
  final String message;

  const IntubationOperationSuccess(this.intubation, this.message);

  @override
  List<Object?> get props => [intubation, message];
}

class IntubationDeleted extends IntubationState {
  const IntubationDeleted();
}

class IntubationError extends IntubationState {
  final String message;

  const IntubationError(this.message);

  @override
  List<Object?> get props => [message];
}
