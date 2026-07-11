import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/core/network/connectivity_bloc.dart';
import 'package:team_workspace/core/theme/theme_cubit.dart';
import 'package:team_workspace/core/analytics/analytics_service.dart';

import 'package:team_workspace/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:team_workspace/features/auth/presentation/pages/login_page.dart';

import 'package:team_workspace/injection/service_locator.dart';

import 'features/dashboard/presentation/bloc/task_bloc.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await setupServiceLocator();

  runApp(const TeamWorkspaceApp());
}

class TeamWorkspaceApp extends StatefulWidget {
  const TeamWorkspaceApp({super.key});

  @override
  State<TeamWorkspaceApp> createState() => _TeamWorkspaceAppState();
}

class _TeamWorkspaceAppState extends State<TeamWorkspaceApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(const AuthCheckStatusEvent()),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => getIt<TaskBloc>(),
        ),
        BlocProvider<ConnectivityBloc>(
          create: (context) => getIt<ConnectivityBloc>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => getIt<ThemeCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Team Workspace',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark().copyWith(
              useMaterial3: true,
            ),
            themeMode: themeMode,
            home: MultiBlocListener(
              listeners: [
                // Listen to connectivity changes and dispatch to interested blocs
                BlocListener<ConnectivityBloc, ConnectivityState>(
                  listener: (context, state) {
                    final isOnline = state is ConnectivityConnected;
                    // Inform TaskBloc about connectivity changes
                    context.read<TaskBloc>().add(ConnectivityChangedEvent(isOnline));
                    // Log connectivity change to analytics if available
                    final analytics = getIt.isRegistered<AnalyticsService>() ? getIt<AnalyticsService>() : null;
                    analytics?.logEvent('connectivity_change', parameters: {'is_online': isOnline});
                  },
                ),
              ],
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticatedState) {
                    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
                      builder: (context, connState) {
                        final isOnline = connState is ConnectivityConnected;
                        return DashboardPage(isOnline: isOnline);
                      },
                    );
                  }
                  return const LoginPage();
                },
              ),
            ),
            routes: {
              '/login': (context) => const LoginPage(),
              '/dashboard': (context) => BlocBuilder<ConnectivityBloc, ConnectivityState>(
                builder: (context, connState) {
                  final isOnline = connState is ConnectivityConnected;
                  return DashboardPage(isOnline: isOnline);
                },
              ),
            },
          );
        },
      ),
    );
  }
}