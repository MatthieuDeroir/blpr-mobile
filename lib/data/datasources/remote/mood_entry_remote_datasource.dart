// lib/data/datasources/remote/mood_entry_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:mood_tracker/core/constants/api_constants.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/core/network/dio_client.dart';
import 'package:mood_tracker/data/models/mood/mood_entry_model.dart';

abstract class MoodEntryRemoteDataSource {
  Future<List<MoodEntryModel>> getMoodEntries({int? limit, int? offset});
  Future<MoodEntryModel> getMoodEntryById(String id);
  Future<MoodEntryModel> createMoodEntry(MoodEntryModel entry);
  Future<MoodEntryModel> updateMoodEntry(String id, MoodEntryModel entry);
  Future<bool> deleteMoodEntry(String id);
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange(
      DateTime startDate, DateTime endDate);
}

class MoodEntryRemoteDataSourceImpl implements MoodEntryRemoteDataSource {
  final DioClient _dioClient;

  MoodEntryRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<MoodEntryModel>> getMoodEntries({int? limit, int? offset}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _dioClient.get(
        ApiConstants.moodEntries,
        queryParameters: queryParams,
      );

      return (response.data as List<dynamic>)
          .map((json) => MoodEntryModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MoodEntryModel> getMoodEntryById(String id) async {
    try {
      final response = await _dioClient.get(ApiConstants.moodEntry(id));
      return MoodEntryModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MoodEntryModel> createMoodEntry(MoodEntryModel entry) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.moodEntries,
        data: entry.toJson(),
      );
      return MoodEntryModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MoodEntryModel> updateMoodEntry(
      String id, MoodEntryModel entry) async {
    try {
      final response = await _dioClient.put(
        ApiConstants.moodEntry(id),
        data: entry.toJson(),
      );
      return MoodEntryModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteMoodEntry(String id) async {
    try {
      await _dioClient.delete(ApiConstants.moodEntry(id));
      return true;
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final queryParams = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      final response = await _dioClient.get(
        ApiConstants.moodEntries,
        queryParameters: queryParams,
      );

      return (response.data as List<dynamic>)
          .map((json) => MoodEntryModel.fromJson(json))
          .toList();
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