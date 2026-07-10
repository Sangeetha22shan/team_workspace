import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:team_workspace/injection/service_locator.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard_page.dart';
import 'features/auth/presentation/pages/login_page.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await setupServiceLocator();

  runApp(const TeamWorkspaceApp());
}

class TeamWorkspaceApp extends StatelessWidget {
  const TeamWorkspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Team Workspace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        // Always show the login page by default. Navigation to the dashboard
        // happens only after a successful login from the login page.
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {

            if (state is AuthAuthenticatedState) {
              return const DashboardPage();
            }

            return const LoginPage();
          },
        ),
        routes: {
          '/login': (_) => const LoginPage(),
          '/dashboard': (_) => const DashboardPage(),
        },
      ),
    );
  }
}