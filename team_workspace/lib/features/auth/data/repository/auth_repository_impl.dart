import 'package:team_workspace/core/error/exceptions.dart';
import 'package:team_workspace/core/error/failures.dart';
import 'package:team_workspace/core/network/network_info.dart';



import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/firebase_auth_datasource.dart';
import '../datasource/local_auth_datasource.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource firebaseAuthDataSource;
  final LocalAuthDataSource localAuthDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.firebaseAuthDataSource,
    required this.localAuthDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final user = await firebaseAuthDataSource.signUp(
        email: email,
        password: password,
        name: name,
      );
      await localAuthDataSource.cacheUser(user);
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final user = await firebaseAuthDataSource.login(
        email: email,
        password: password,
      );
      await localAuthDataSource.cacheUser(user);
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseAuthDataSource.logout();
      await localAuthDataSource.clearCache();
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, User?>> getAuthenticatedUser() async {
    try {
      final user = await firebaseAuthDataSource.getAuthenticatedUser();
      if (user != null) {
        await localAuthDataSource.cacheUser(user);
      }
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      return Right(await firebaseAuthDataSource.isUserLoggedIn());
    } catch (e) {
      return const Right(false);
    }
  }
}