import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/patient/data/datasources/patient_local_datasource.dart';
import 'features/patient/data/repositories/patient_repository_impl.dart';
import 'features/patient/domain/repositories/patient_repository.dart';
import 'features/patient/domain/usecases/create_patient_usecase.dart';
import 'features/patient/domain/usecases/delete_patient_usecase.dart';
import 'features/patient/domain/usecases/get_all_patients_usecase.dart';
import 'features/patient/domain/usecases/search_patients_usecase.dart';
import 'features/patient/domain/usecases/update_patient_usecase.dart';
import 'features/patient/presentation/cubit/patient_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  if (!sl.isRegistered<DatabaseHelper>()) {
    sl.registerLazySingleton<DatabaseHelper>(DatabaseHelper.new);
  }

  if (!sl.isRegistered<AuthLocalDatasource>()) {
    sl.registerLazySingleton<AuthLocalDatasource>(
      () => AuthLocalDatasource(databaseHelper: sl<DatabaseHelper>()),
    );
  }

  if (!sl.isRegistered<AuthRepositoryImpl>()) {
    sl.registerLazySingleton<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(localDatasource: sl<AuthLocalDatasource>()),
    );
  }

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(() => sl<AuthRepositoryImpl>());
  }

  if (!sl.isRegistered<LoginUseCase>()) {
    sl.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(repository: sl<AuthRepository>()),
    );
  }

  if (!sl.isRegistered<RegisterUseCase>()) {
    sl.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(repository: sl<AuthRepository>()),
    );
  }

  if (!sl.isRegistered<AuthCubit>()) {
    sl.registerFactory<AuthCubit>(
      () => AuthCubit(
        loginUseCase: sl<LoginUseCase>(),
        registerUseCase: sl<RegisterUseCase>(),
      ),
    );
  }

  if (!sl.isRegistered<PatientLocalDatasource>()) {
    sl.registerLazySingleton<PatientLocalDatasource>(
      () => PatientLocalDatasource(sl<DatabaseHelper>()),
    );
  }

  if (!sl.isRegistered<PatientRepositoryImpl>()) {
    sl.registerLazySingleton<PatientRepositoryImpl>(
      () => PatientRepositoryImpl(sl<PatientLocalDatasource>()),
    );
  }

  if (!sl.isRegistered<PatientRepository>()) {
    sl.registerLazySingleton<PatientRepository>(
      () => sl<PatientRepositoryImpl>(),
    );
  }

  if (!sl.isRegistered<CreatePatientUseCase>()) {
    sl.registerLazySingleton<CreatePatientUseCase>(
      () => CreatePatientUseCase(sl<PatientRepository>()),
    );
  }

  if (!sl.isRegistered<UpdatePatientUseCase>()) {
    sl.registerLazySingleton<UpdatePatientUseCase>(
      () => UpdatePatientUseCase(sl<PatientRepository>()),
    );
  }

  if (!sl.isRegistered<DeletePatientUseCase>()) {
    sl.registerLazySingleton<DeletePatientUseCase>(
      () => DeletePatientUseCase(sl<PatientRepository>()),
    );
  }

  if (!sl.isRegistered<GetAllPatientsUseCase>()) {
    sl.registerLazySingleton<GetAllPatientsUseCase>(
      () => GetAllPatientsUseCase(sl<PatientRepository>()),
    );
  }

  if (!sl.isRegistered<SearchPatientsUseCase>()) {
    sl.registerLazySingleton<SearchPatientsUseCase>(
      () => SearchPatientsUseCase(sl<PatientRepository>()),
    );
  }

  if (!sl.isRegistered<PatientCubit>()) {
    sl.registerFactory<PatientCubit>(
      () => PatientCubit(
        createPatient: sl<CreatePatientUseCase>(),
        updatePatient: sl<UpdatePatientUseCase>(),
        deletePatient: sl<DeletePatientUseCase>(),
        getAllPatients: sl<GetAllPatientsUseCase>(),
        searchPatients: sl<SearchPatientsUseCase>(),
      ),
    );
  }
}
