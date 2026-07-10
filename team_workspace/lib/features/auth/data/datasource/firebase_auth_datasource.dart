import 'package:firebase_auth/firebase_auth.dart';
import 'package:team_workspace/core/error/exceptions.dart';

import '../models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getAuthenticatedUser();

  Future<bool> isUserLoggedIn();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthenticationException(
          message: 'Failed to create user',
        );
      }

      await user.updateDisplayName(name);
      await user.reload();

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? name,
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: e.message ?? 'Sign up failed',
        code: e.code,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during sign up',
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthenticationException(
          message: 'Failed to login',
        );
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        message: e.message ?? 'Login failed',
        code: e.code,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'An unexpected error occurred during login',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to logout',
      );
    }
  }

  @override
  Future<UserModel?> getAuthenticatedUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
        photoUrl: user.photoURL,
      );
    } catch (e) {
      throw AuthenticationException(
        message: 'Failed to get authenticated user',
      );
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return _firebaseAuth.currentUser != null;
  }
}