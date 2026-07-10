abstract class Failure implements Exception {
  final String message;
  final String? code;

  Failure({required this.message, this.code});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure({
    required super.message,
    super.code,
  });
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure({
    required super.message,
    super.code,
  });
}

class ValidationFailure extends Failure {
  ValidationFailure({
    required super.message,
    super.code,
  });
}

class CacheFailure extends Failure {
  CacheFailure({
    required super.message,
    super.code,
  });
}

class NetworkFailure extends Failure {
  NetworkFailure({
    required super.message,
    super.code,
  });
}

class NotFoundFailure extends Failure {
  NotFoundFailure({
    required super.message,
    super.code,
  });
}

class UnknownFailure extends Failure {
  UnknownFailure({
    required super.message,
    super.code,
  });
}