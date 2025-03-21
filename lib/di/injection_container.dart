import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mood_tracker/core/network/dio_client.dart';
import 'package:mood_tracker/core/network/network_info.dart';
import 'package:mood_tracker/data/datasources/local/auth_local_datasource.dart';
import 'package:mood_tracker/data/datasources/local/local_storage.dart';
import 'package:mood_tracker/data/datasources/remote/auth_remote_datasource.dart';
import 'package:mood_tracker/data/repositories/auth_repository_impl.dart';
import 'package:mood_tracker/domain/repositories/auth_repository.dart';
import 'package:mood_tracker/domain/usecases/auth/get_current_user.dart';
import 'package:mood_tracker/domain/usecases/auth/login_user.dart';
import 'package:mood_tracker/domain/usecases/auth/register_user.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/bloc/scale/formula_bloc.dart';

import '../presentation/bloc/ai/ai_assessment_bloc.dart';
import '../presentation/bloc/mood/mood_entries_bloc.dart';
import '../presentation/bloc/scale/scales_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerSingleton<Dio>(Dio());
  sl.registerSingleton<InternetConnectionChecker>(InternetConnectionChecker());

  //! Core
  sl.registerSingleton<NetworkInfo>(NetworkInfoImpl(sl()));
  sl.registerSingleton<DioClient>(DioClient(sl()));
  sl.registerSingleton<LocalStorage>(LocalStorageImpl(sl()));

  //! Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(sl()),
  );

  //! Repositories
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  //! Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  //! Bloc
  sl.registerFactory(
        () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      getCurrentUser: sl(),
      authRepository: sl(),
    ),
  );

  // Add this to your existing injection_container.dart file

// BLoCs
  sl.registerFactory(
        () => MoodEntriesBloc(
      getMoodEntries: sl(),
      deleteMoodEntry: sl(),
      moodEntryRepository: sl(),
    ),
  );

  sl.registerFactory(
        () => ScalesBloc(
      getScales: sl(),
      createScale: sl(),
      updateScale: sl(),
      deleteScale: sl(),
    ),
  );

  // Replace this segment in your injection_container.dart:
  sl.registerFactory(
        () => FormulaBloc(
      getFormulas: sl(),
      getActiveFormula: sl(),
      createFormula: sl(),
      updateFormula: sl(),
    ),
  );

  sl.registerFactory(
        () => AiAssessmentBloc(
      chatWithAi: sl(),
      generateAssessment: sl(),
      saveAssessment: sl(),
    ),
  );


}