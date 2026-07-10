import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';



import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecase.dart';


// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthAuthenticatedState extends AuthState {
  final User user;

  const AuthAuthenticatedState(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

class AuthErrorState extends AuthState {
  final String message;
  final String? code;

  const AuthErrorState({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCase authUseCase;

  AuthBloc({
    required this.authUseCase,
  }) : super(const AuthInitialState()) {
    on<AuthSignUpEvent>(_onSignUp);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
  }

  Future<void> _onSignUp(
      AuthSignUpEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());

    final result = await authUseCase.signUp(
      email: event.email,
      password: event.password,
      name: event.name,
    );

    result.fold(
          (failure) => emit(
        AuthErrorState(
          message: failure.message,
          code: failure.code,
        ),
      ),
          (user) => emit(AuthAuthenticatedState(user)),
    );
  }

  Future<void> _onLogin(
      AuthLoginEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());

    final result = await authUseCase.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
          (failure) => emit(
        AuthErrorState(
          message: failure.message,
          code: failure.code,
        ),
      ),
          (user) => emit(AuthAuthenticatedState(user)),
    );
  }

  Future<void> _onLogout(
      AuthLogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());

    final result = await authUseCase.logout();

    result.fold(
          (failure) => emit(
        AuthErrorState(
          message: failure.message,
          code: failure.code,
        ),
      ),
          (_) => emit(const AuthUnauthenticatedState()),
    );
  }

  Future<void> _onCheckStatus(
      AuthCheckStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    final result = await authUseCase.checkAuthStatus();

    result.fold(
          (failure) => emit(const AuthUnauthenticatedState()),
          (isLoggedIn) {
        if (isLoggedIn) {
          // In a real app, you'd fetch the actual user data
          emit(const AuthAuthenticatedState(
            User(
              id: 'test',
              email: 'test@example.com',
              name: 'Test User',
            ),
          ));
        } else {
          emit(const AuthUnauthenticatedState());
        }
      },
    );
  }
}