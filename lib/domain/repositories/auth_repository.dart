import 'package:dartz/dartz.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/user.dart';

abstract class AuthRepository {
  /// Register a new user with email, username, and password
  Future<Either<Failure, User>> register({
    required String email,
    required String username,
    required String password,
  });

  /// Log in a user with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Get the currently logged in user
  Future<Either<Failure, User>> getCurrentUser();

  /// Log out the current user
  Future<Either<Failure, bool>> logout();

  /// Check if a user is currently logged in
  Future<bool> isLoggedIn();
}