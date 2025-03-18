import 'package:dio/dio.dart';
import 'package:mood_tracker/core/constants/api_constants.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/core/network/dio_client.dart';
import 'package:mood_tracker/data/models/auth/auth_response_model.dart';
import 'package:mood_tracker/data/models/auth/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String username,
    required String password,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'username': username,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException('User with this email already exists');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: 'Validation error',
          errors: _extractValidationErrors(e.response?.data),
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw ConnectionException();
      } else {
        throw ServerException(e.message ?? 'Registration failed');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Invalid email or password');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw ConnectionException();
      } else {
        throw ServerException(e.message ?? 'Login failed');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiConstants.currentUser);

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw ConnectionException();
      } else {
        throw ServerException(e.message ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  List<String> _extractValidationErrors(dynamic data) {
    List<String> errors = [];

    if (data != null && data['errors'] != null) {
      if (data['errors'] is List) {
        errors = (data['errors'] as List).map((e) => e.toString()).toList();
      } else if (data['errors'] is Map) {
        final errorMap = data['errors'] as Map;
        errorMap.forEach((key, value) {
          if (value is List) {
            errors.addAll((value as List).map((e) => '$key: $e'));
          } else {
            errors.add('$key: $value');
          }
        });
      }
    }

    return errors;
  }
}