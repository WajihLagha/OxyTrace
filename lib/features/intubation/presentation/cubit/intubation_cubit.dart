import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/intubation_entity.dart';
import '../../domain/usecases/create_intubation_usecase.dart';
import '../../domain/usecases/delete_intubation_usecase.dart';
import '../../domain/usecases/get_intubations_by_patient_usecase.dart';
import '../../domain/usecases/update_intubation_usecase.dart';
import 'intubation_state.dart';

class IntubationCubit extends Cubit<IntubationState> {
  final CreateIntubationUseCase createIntubationUseCase;
  final UpdateIntubationUseCase updateIntubationUseCase;
  final DeleteIntubationUseCase deleteIntubationUseCase;
  final GetIntubationsByPatientUseCase getIntubationsByPatientUseCase;

  int? _currentPatientId;

  IntubationCubit({
    required CreateIntubationUseCase createIntubation,
    required UpdateIntubationUseCase updateIntubation,
    required DeleteIntubationUseCase deleteIntubation,
    required GetIntubationsByPatientUseCase getIntubationsByPatient,
  })  : createIntubationUseCase = createIntubation,
        updateIntubationUseCase = updateIntubation,
        deleteIntubationUseCase = deleteIntubation,
        getIntubationsByPatientUseCase = getIntubationsByPatient,
        super(const IntubationInitial());

  Future<void> loadIntubationsByPatient(int patientId) async {
    emit(const IntubationLoading());
    _currentPatientId = patientId;

    try {
      final result = await getIntubationsByPatientUseCase(
        GetIntubationsByPatientParams(patientId),
      );

      result.fold(
        (failure) => emit(IntubationError(failure.message)),
        (intubations) => emit(IntubationListLoaded(intubations)),
      );
    } catch (_) {
      emit(
        const IntubationError(
          'Une erreur inattendue est survenue lors du chargement des dossiers.',
        ),
      );
    }
  }

  Future<void> createIntubation(IntubationEntity intubation) async {
    emit(const IntubationLoading());
    _currentPatientId = intubation.patientId;

    try {
      final result = await createIntubationUseCase(
        CreateIntubationParams(intubation),
      );

      await result.fold(
        (failure) async => emit(IntubationError(failure.message)),
        (createdIntubation) async {
          emit(
            IntubationOperationSuccess(
              createdIntubation,
              "Dossier d'intubation enregistre avec succes.",
            ),
          );
          await loadIntubationsByPatient(createdIntubation.patientId);
        },
      );
    } catch (_) {
      emit(
        const IntubationError(
          "Une erreur inattendue est survenue lors de l'enregistrement.",
        ),
      );
    }
  }

  Future<void> updateIntubation(IntubationEntity intubation) async {
    emit(const IntubationLoading());
    _currentPatientId = intubation.patientId;

    try {
      final result = await updateIntubationUseCase(
        UpdateIntubationParams(intubation),
      );

      await result.fold(
        (failure) async => emit(IntubationError(failure.message)),
        (updatedIntubation) async {
          emit(
            IntubationOperationSuccess(
              updatedIntubation,
              "Dossier d'intubation mis a jour avec succes.",
            ),
          );
          await loadIntubationsByPatient(updatedIntubation.patientId);
        },
      );
    } catch (_) {
      emit(
        const IntubationError(
          'Une erreur inattendue est survenue lors de la mise a jour.',
        ),
      );
    }
  }

  Future<void> deleteIntubation(int id) async {
    emit(const IntubationLoading());

    try {
      final result = await deleteIntubationUseCase(DeleteIntubationParams(id));
      await result.fold(
        (failure) async => emit(IntubationError(failure.message)),
        (_) async {
          emit(const IntubationDeleted());
          if (_currentPatientId != null) {
            await loadIntubationsByPatient(_currentPatientId!);
          }
        },
      );
    } catch (_) {
      emit(
        const IntubationError(
          'Une erreur inattendue est survenue lors de la suppression.',
        ),
      );
    }
  }

  void reset() {
    _currentPatientId = null;
    emit(const IntubationInitial());
  }
}
