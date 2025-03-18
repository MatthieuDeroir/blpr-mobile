// lib/data/datasources/remote/stability_formula_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:mood_tracker/core/constants/api_constants.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/core/network/dio_client.dart';
import 'package:mood_tracker/data/models/scale/stability_formula_model.dart';

abstract class StabilityFormulaRemoteDataSource {
  Future<List<StabilityFormulaModel>> getAllFormulas();
  Future<StabilityFormulaModel> getActiveFormula();
  Future<StabilityFormulaModel> getFormulaById(String id);
  Future<StabilityFormulaModel> createFormula({
    required String description,
    required bool isActive,
    required List<Map<String, dynamic>> scaleWeights,
  });
  Future<StabilityFormulaModel> updateFormula({
    required String id,
    String? description,
    bool? isActive,
    List<Map<String, dynamic>>? scaleWeights,
  });
  Future<bool> deleteFormula(String id);
}

class StabilityFormulaRemoteDataSourceImpl implements StabilityFormulaRemoteDataSource {
  final DioClient _dioClient;

  StabilityFormulaRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<StabilityFormulaModel>> getAllFormulas() async {
    try {
      final response = await _dioClient.get(ApiConstants.formulas);
      return (response.data as List<dynamic>)
          .map((json) => StabilityFormulaModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StabilityFormulaModel> getActiveFormula() async {
    try {
      final response = await _dioClient.get(ApiConstants.activeFormula);
      return StabilityFormulaModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StabilityFormulaModel> getFormulaById(String id) async {
    try {
      final response = await _dioClient.get(ApiConstants.formula(id));
      return StabilityFormulaModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StabilityFormulaModel> createFormula({
    required String description,
    required bool isActive,
    required List<Map<String, dynamic>> scaleWeights,
  }) async {
    try {
      final data = {
        'description': description,
        'isActive': isActive,
        'scaleWeights': scaleWeights,
      };

      final response = await _dioClient.post(
        ApiConstants.formulas,
        data: data,
      );
      return StabilityFormulaModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StabilityFormulaModel> updateFormula({
    required String id,
    String? description,
    bool? isActive,
    List<Map<String, dynamic>>? scaleWeights,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (description != null) data['description'] = description;
      if (isActive != null) data['isActive'] = isActive;
      if (scaleWeights != null) data['scaleWeights'] = scaleWeights;

      final response = await _dioClient.put(
        ApiConstants.formula(id),
        data: data,
      );
      return StabilityFormulaModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteFormula(String id) async {
    try {
      await _dioClient.delete(ApiConstants.formula(id));
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

