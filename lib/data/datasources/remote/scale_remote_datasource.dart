// lib/data/datasources/remote/scale_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:mood_tracker/core/constants/api_constants.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/core/network/dio_client.dart';
import 'package:mood_tracker/data/models/scale/scale_model.dart';

abstract class ScaleRemoteDataSource {
  Future<List<ScaleModel>> getAllScales();
  Future<ScaleModel> getScaleById(String id);
  Future<ScaleModel> createScale({
    required String name,
    required String description,
    required int minValue,
    required int maxValue,
    required bool isActive,
    required List<Map<String, dynamic>> levels,
  });
  Future<ScaleModel> updateScale({
    required String id,
    String? name,
    String? description,
    bool? isActive,
    List<Map<String, dynamic>>? levels,
  });
  Future<bool> deleteScale(String id);
}

class ScaleRemoteDataSourceImpl implements ScaleRemoteDataSource {
  final DioClient _dioClient;

  ScaleRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ScaleModel>> getAllScales() async {
    try {
      final response = await _dioClient.get(ApiConstants.scales);

      return (response.data as List<dynamic>)
          .map((json) => ScaleModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ScaleModel> getScaleById(String id) async {
    try {
      final response = await _dioClient.get(ApiConstants.scale(id));
      return ScaleModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ScaleModel> createScale({
    required String name,
    required String description,
    required int minValue,
    required int maxValue,
    required bool isActive,
    required List<Map<String, dynamic>> levels,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'minValue': minValue,
        'maxValue': maxValue,
        'isActive': isActive,
        'levels': levels,
      };

      final response = await _dioClient.post(
        ApiConstants.scales,
        data: data,
      );
      return ScaleModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ScaleModel> updateScale({
    required String id,
    String? name,
    String? description,
    bool? isActive,
    List<Map<String, dynamic>>? levels,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (isActive != null) data['isActive'] = isActive;
      if (levels != null) data['levels'] = levels;

      final response = await _dioClient.put(
        ApiConstants.scale(id),
        data: data,
      );
      return ScaleModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteScale(String id) async {
    try {
      await _dioClient.delete(ApiConstants.scale(id));
      return true;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  void _handleDioException(DioException e) {
    if (e.response?.statusCode == 404) {
      throw NotFoundException();
    } else if (e.response?.statusCode == 401) {
      throw AuthenticationException();
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
      throw ServerException(e.message ?? 'Server error occurred');
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