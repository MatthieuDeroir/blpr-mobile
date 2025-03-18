import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state when the app starts
class AuthInitial extends AuthState {}

// Checking authentication status
class AuthCheckingStatus extends AuthState {}

// User is authenticated
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// User is not authenticated
class Unauthenticated extends AuthState {}

// Login states
class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final User user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends AuthState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Register states
class RegisterLoading extends AuthState {}

class RegisterSuccess extends AuthState {
  final User user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterFailure extends AuthState {
  final String message;
  final List<String> errors;

  const RegisterFailure(this.message, {this.errors = const []});

  @override
  List<Object?> get props => [message, errors];
}

// Logout states
class LogoutLoading extends AuthState {}

class LogoutSuccess extends AuthState {}

class LogoutFailure extends AuthState {
  final String message;

  const LogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}