import 'package:dartz/dartz.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/core/network/network_info.dart';
import 'package:mood_tracker/data/datasources/local/auth_local_datasource.dart';
import 'package:mood_tracker/data/datasources/remote/auth_remote_datasource.dart';
import 'package:mood_tracker/data/models/auth/user_model.dart';
import 'package:mood_tracker/domain/entities/user.dart';
import 'package:mood_tracker/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final authResponse = await remoteDataSource.register(
          email: email,
          username: username,
          password: password,
        );

        // Save auth data locally
        await localDataSource.saveToken(authResponse.token);
        await localDataSource.saveUser(authResponse.user);
        await localDataSource.setLoggedIn(true);

        return Right(authResponse.user);
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message, errors: e.errors));
      } on ConflictException catch (e) {
        return Left(ConflictFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException catch (e) {
        return Left(ConnectionFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final authResponse = await remoteDataSource.login(
          email: email,
          password: password,
        );

        // Save auth data locally
        await localDataSource.saveToken(authResponse.token);
        await localDataSource.saveUser(authResponse.user);
        await localDataSource.setLoggedIn(true);

        return Right(authResponse.user);
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on ConnectionException catch (e) {
        return Left(ConnectionFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // First check if we have a user in local storage
      final localUser = await localDataSource.getUser();

      if (localUser != null) {
        // If we have a network connection, try to refresh the user data
        if (await networkInfo.isConnected) {
          try {
            final remoteUser = await remoteDataSource.getCurrentUser();

            // Update local user data
            await localDataSource.saveUser(remoteUser);

            return Right(remoteUser);
          } on AuthenticationException {
            // If the token is invalid, return the local user
            return Right(localUser);
          } catch (_) {
            // For any other error, return the local user
            return Right(localUser);
          }
        } else {
          // If offline, return the local user
          return Right(localUser);
        }
      } else {
        // If no local user, try to get from API if online
        if (await networkInfo.isConnected) {
          try {
            final remoteUser = await remoteDataSource.getCurrentUser();

            // Save user data locally
            await localDataSource.saveUser(remoteUser);

            return Right(remoteUser);
          } on AuthenticationException catch (e) {
            return Left(AuthenticationFailure(message: e.message));
          } on ServerException catch (e) {
            return Left(ServerFailure(message: e.message));
          } catch (e) {
            return Left(UnknownFailure(message: e.toString()));
          }
        } else {
          return const Left(ConnectionFailure(message: 'No user found and offline'));
        }
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await localDataSource.isLoggedIn();
    } catch (_) {
      return false;
    }
  }
}