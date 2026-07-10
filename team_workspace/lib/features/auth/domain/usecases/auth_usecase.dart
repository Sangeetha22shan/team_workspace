import 'package:team_workspace/core/error/failures.dart';

import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Consolidated AuthUseCase that exposes all auth-related operations.
class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase(this.repository);

  Future<Either<Failure, bool>> checkAuthStatus() {
    return repository.isUserLoggedIn();
  }

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      name: name,
    );
  }

  Future<Either<Failure, void>> logout() {
    return repository.logout();
  }
}