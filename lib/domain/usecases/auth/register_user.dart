import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/user.dart';
import 'package:mood_tracker/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      username: params.username,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String username;
  final String password;

  const RegisterParams({
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [email, username, password];
}