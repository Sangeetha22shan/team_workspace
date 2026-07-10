class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException({
    required this.message,
    this.code,
  });
}

class AuthenticationException implements Exception {
  final String message;
  final String? code;

  AuthenticationException({
    required this.message,
    this.code,
  });
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

class NotAuthorizedException implements Exception {
  final String message;

  NotAuthorizedException(this.message);
}