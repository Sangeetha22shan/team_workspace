import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_workspace/core/network/dio_client.dart';
import 'package:team_workspace/core/config/app_config.dart';
import 'package:team_workspace/core/network/network_info.dart';

import '../features/auth/data/datasource/firebase_auth_datasource.dart';
import '../features/auth/data/datasource/local_auth_datasource.dart';
import '../features/auth/data/repository/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecase.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';




final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerSingleton<Logger>(Logger());
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  // App configuration (read from --dart-define)
  getIt.registerSingleton<AppConfig>(AppConfig.fromEnvironment());

  // Network client uses configured base URL
  getIt.registerSingleton<DioClient>(
    DioClient(baseUrl: getIt<AppConfig>().apiBaseUrl),
  );

  // Network Info
  getIt.registerSingleton<NetworkInfo>(
    NetworkInfoImpl(getIt<Connectivity>()),
  );

  // Auth Data Sources
  getIt.registerSingleton<FirebaseAuthDataSource>(
    FirebaseAuthDataSourceImpl(getIt<FirebaseAuth>()),
  );

  getIt.registerSingleton<LocalAuthDataSource>(
    LocalAuthDataSourceImpl(getIt<SharedPreferences>()),
  );

  // Auth Repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      firebaseAuthDataSource: getIt<FirebaseAuthDataSource>(),
      localAuthDataSource: getIt<LocalAuthDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Auth Use Case (consolidated)
  getIt.registerSingleton<AuthUseCase>(AuthUseCase(getIt<AuthRepository>()));

  // Auth BLoC
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      authUseCase: getIt<AuthUseCase>(),
    ),
  );


}