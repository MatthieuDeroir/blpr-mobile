import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/user.dart';
import 'package:mood_tracker/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}