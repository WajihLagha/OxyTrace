import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/usecases/create_patient_usecase.dart';
import '../../domain/usecases/delete_patient_usecase.dart';
import '../../domain/usecases/get_all_patients_usecase.dart';
import '../../domain/usecases/search_patients_usecase.dart';
import '../../domain/usecases/update_patient_usecase.dart';
import 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  final CreatePatientUseCase createPatientUseCase;
  final UpdatePatientUseCase updatePatientUseCase;
  final DeletePatientUseCase deletePatientUseCase;
  final GetAllPatientsUseCase getAllPatientsUseCase;
  final SearchPatientsUseCase searchPatientsUseCase;

  PatientCubit({
    required CreatePatientUseCase createPatient,
    required UpdatePatientUseCase updatePatient,
    required DeletePatientUseCase deletePatient,
    required GetAllPatientsUseCase getAllPatients,
    required SearchPatientsUseCase searchPatients,
  })  : createPatientUseCase = createPatient,
        updatePatientUseCase = updatePatient,
        deletePatientUseCase = deletePatient,
        getAllPatientsUseCase = getAllPatients,
        searchPatientsUseCase = searchPatients,
        super(const PatientInitial());

  Future<void> loadPatients() async {
    emit(const PatientLoading());

    try {
      final result = await getAllPatientsUseCase(const NoParams());
      result.fold(
        (failure) => emit(PatientError(failure.message)),
        (patients) => emit(PatientListLoaded(patients)),
      );
    } catch (_) {
      emit(
        const PatientError(
          'Une erreur inattendue est survenue lors du chargement des patients.',
        ),
      );
    }
  }

  Future<void> searchPatients(String query) async {
    emit(const PatientLoading());

    try {
      final result = await searchPatientsUseCase(SearchPatientsParams(query));
      result.fold(
        (failure) => emit(PatientError(failure.message)),
        (patients) => emit(PatientListLoaded(patients)),
      );
    } catch (_) {
      emit(
        const PatientError(
          'Une erreur inattendue est survenue lors de la recherche.',
        ),
      );
    }
  }

  Future<void> createPatient(PatientEntity patient) async {
    emit(const PatientLoading());

    try {
      final result = await createPatientUseCase(CreatePatientParams(patient));
      await result.fold(
        (failure) async => emit(PatientError(failure.message)),
        (createdPatient) async {
          emit(
            PatientOperationSuccess(
              createdPatient,
              'Patient enregistré avec succès.',
            ),
          );
          await loadPatients();
        },
      );
    } catch (_) {
      emit(
        const PatientError(
          'Une erreur inattendue est survenue lors de la création du patient.',
        ),
      );
    }
  }

  Future<void> updatePatient(PatientEntity patient) async {
    emit(const PatientLoading());

    try {
      final result = await updatePatientUseCase(UpdatePatientParams(patient));
      await result.fold(
        (failure) async => emit(PatientError(failure.message)),
        (updatedPatient) async {
          emit(
            PatientOperationSuccess(
              updatedPatient,
              'Patient mis à jour avec succès.',
            ),
          );
          await loadPatients();
        },
      );
    } catch (_) {
      emit(
        const PatientError(
          'Une erreur inattendue est survenue lors de la mise à jour du patient.',
        ),
      );
    }
  }

  Future<void> deletePatient(int id) async {
    emit(const PatientLoading());

    try {
      final result = await deletePatientUseCase(DeletePatientParams(id));
      await result.fold(
        (failure) async => emit(PatientError(failure.message)),
        (_) async {
          emit(const PatientDeleted());
          await loadPatients();
        },
      );
    } catch (_) {
      emit(
        const PatientError(
          'Une erreur inattendue est survenue lors de la suppression du patient.',
        ),
      );
    }
  }

  void reset() {
    emit(const PatientInitial());
  }
}
