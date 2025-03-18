/// Base exception for all app-specific exceptions
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Exception for server errors
class ServerException extends AppException {
  ServerException([String message = 'Server error occurred']) : super(message);
}

/// Exception for network connectivity issues
class ConnectionException extends AppException {
  ConnectionException([String message = 'Network connection error']) : super(message);
}

/// Exception for authentication issues
class AuthenticationException extends AppException {
  AuthenticationException([String message = 'Authentication error']) : super(message);
}

/// Exception for validation issues
class ValidationException extends AppException {
  final List<String> errors;

  ValidationException({
    String message = 'Validation error',
    this.errors = const [],
  }) : super(message);
}

/// Exception for resource not found
class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found']) : super(message);
}

/// Exception for resource conflicts
class ConflictException extends AppException {
  ConflictException([String message = 'Resource conflict']) : super(message);
}

/// Exception for cache issues
class CacheException extends AppException {
  CacheException([String message = 'Cache error']) : super(message);
}