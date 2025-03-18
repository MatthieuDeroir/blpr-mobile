import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = ''});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred'});
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({super.message = 'Network connection error'});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message = 'Authentication error'});
}

class ValidationFailure extends Failure {
  final List<String> errors;

  const ValidationFailure({
    super.message = 'Validation error',
    this.errors = const [],
  });

  @override
  List<Object> get props => [message, errors];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found'});
}

class ConflictFailure extends Failure {
  const ConflictFailure({super.message = 'Resource conflict'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Unknown error occurred'});
}