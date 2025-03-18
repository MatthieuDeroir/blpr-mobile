import 'package:dartz/dartz.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/user.dart';
import 'package:mood_tracker/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}