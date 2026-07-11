import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/core/network/network_info.dart';

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
  bool _isOnline = true;
  late final StreamSubscription<bool> _connectivitySub;

  @override
  void initState() {
    super.initState();
    // Listen globally to connectivity changes and expose as state to children
    _connectivitySub = getIt<NetworkInfo>().onConnectivityChanged.listen((connected) {
      if (mounted) setState(() => _isOnline = connected);
    });
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

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
      ],
      child: MaterialApp(
        title: 'Team Workspace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticatedState) {
              return DashboardPage(isOnline: _isOnline);
            }
            return const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => DashboardPage(isOnline: _isOnline),
        },
      ),
    );
  }
}