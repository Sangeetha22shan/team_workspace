import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_workspace/core/analytics/analytics_service.dart';
import 'package:team_workspace/core/network/connectivity_bloc.dart';
import 'package:team_workspace/core/theme/theme_cubit.dart';
import 'package:team_workspace/core/network/dio_client.dart';
import 'package:team_workspace/core/config/app_config.dart';
import 'package:team_workspace/core/network/network_info.dart';
import 'package:team_workspace/core/database/database_helper.dart';

import '../features/auth/data/datasource/firebase_auth_datasource.dart';
import '../features/auth/data/datasource/local_auth_datasource.dart';
import '../features/auth/data/repository/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecase.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';

import '../features/dashboard/data/datasource/local_task_datasource.dart';
import '../features/dashboard/data/datasource/remote_task_datasource.dart';
import '../features/dashboard/data/repository/task_repositories_impl.dart';
import '../features/dashboard/domain/repositories/task_repository.dart';
import '../features/dashboard/domain/usecases/dashboard_usecase.dart';
import '../features/dashboard/presentation/bloc/task_bloc.dart';




final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Configure Logger with a PrettyPrinter for consistent structured logs
  getIt.registerSingleton<Logger>(
    Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
      ),
    ),
  );

  // Connectivity instance used by the ConnectivityBloc and NetworkInfo
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  getIt.registerSingleton<AnalyticsService>(AnalyticsService(getIt<Logger>()));

  // Database Helper for task storage
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());

  // App configuration (read from --dart-define)
  getIt.registerSingleton<AppConfig>(AppConfig.fromEnvironment());

  // Network client uses configured base URL
  getIt.registerSingleton<DioClient>(
    DioClient(baseUrl: getIt<AppConfig>().apiBaseUrl),
  );

  // Network Info
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl(getIt<Connectivity>()));

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
  getIt.registerSingleton<AuthBloc>(AuthBloc(authUseCase: getIt<AuthUseCase>()));

  // Dashboard Data Sources
  getIt.registerSingleton<RemoteTaskDataSource>(
    RemoteTaskDataSourceImpl(
      dioClient: getIt<DioClient>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerSingleton<LocalTaskDataSource>(
    LocalTaskDataSourceImpl(getIt<DatabaseHelper>()),
  );

  // Dashboard Repository
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(
      remoteDataSource: getIt<RemoteTaskDataSource>(),
      localDataSource: getIt<LocalTaskDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Dashboard UseCase (consolidated)
  getIt.registerSingleton<DashboardUseCase>(
    DashboardUseCase(getIt<TaskRepository>()),
  );

  // Dashboard BLoC
  // Theme Cubit (reads persisted preference)
  getIt.registerSingleton<ThemeCubit>(ThemeCubit(prefs: getIt<SharedPreferences>()));

  // ConnectivityBloc (global connectivity state)
  getIt.registerSingleton<ConnectivityBloc>(
    ConnectivityBloc(connectivity: getIt<Connectivity>()),
  );

  // Dashboard BLoC (TaskBloc no longer listens to connectivity directly)
  getIt.registerSingleton<TaskBloc>(
    TaskBloc(
      dashboardUseCase: getIt<DashboardUseCase>(),
    ),
  );
}