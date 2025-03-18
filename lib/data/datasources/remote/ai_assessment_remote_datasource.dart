import 'package:dio/dio.dart';
import 'package:mood_tracker/core/constants/api_constants.dart';
import 'package:mood_tracker/core/error/exceptions.dart';
import 'package:mood_tracker/core/network/dio_client.dart';
import 'package:mood_tracker/domain/entities/ai_assessment.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/usecases/ai/chat_with_ai.dart';

abstract class AiAssessmentRemoteDataSource {
  Future<AiChatResponse> chatWithAi({required String message});
  Future<AiAssessment> generateAssessment({required List<Map<String, dynamic>> conversation});
}

class AiAssessmentRemoteDataSourceImpl implements AiAssessmentRemoteDataSource {
  final DioClient dioClient;

  AiAssessmentRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AiChatResponse> chatWithAi({required String message}) async {
    try {
      final response = await dioClient.post(
        ApiConstants.aiChat,
        data: {'message': message},
      );

      final bool isAssessment = response.data['isAssessment'] ?? false;

      if (isAssessment && response.data['assessment'] != null) {
        final assessment = _parseAssessment(response.data['assessment']);

        return AiChatResponse(
          message: response.data['message'],
          isAssessment: true,
          assessment: assessment,
        );
      } else {
        return AiChatResponse(
          message: response.data['message'],
          isAssessment: false,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AiAssessment> generateAssessment({required List<Map<String, dynamic>> conversation}) async {
    try {
      final response = await dioClient.post(
        ApiConstants.aiAssess,
        data: {'conversation': conversation},
      );

      return _parseAssessment(response.data);
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  AiAssessment _parseAssessment(Map<String, dynamic> data) {
    // Parse scale values
    final List<MoodScaleValue> scaleValues = [];

    if (data['scaleValues'] != null) {
      for (final value in data['scaleValues']) {
        scaleValues.add(MoodScaleValue(
          scaleId: value['scaleId'],
          scaleName: value['scaleName'],
          value: value['value'],
          description: value['description'],
        ));
      }
    }

    // Create assessment
    return AiAssessment(
      scaleValues: scaleValues,
      comment: data['comment'],
      medication: data['medication'],
      sleepHours: data['sleepHours'] != null ? (data['sleepHours'] as num).toDouble() : null,
    );
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

// Mocked implementation for testing without a backend
class MockAiAssessmentRemoteDataSource implements AiAssessmentRemoteDataSource {
  int _messageCount = 0;

  @override
  Future<AiChatResponse> chatWithAi({required String message}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    _messageCount++;

    // After a few messages, suggest an assessment
    if (_messageCount >= 3 && message.toLowerCase().contains('feel')) {
      return AiChatResponse(
        message: "Based on what you've shared, I can create a mood assessment for you. Would you like me to do that?",
        isAssessment: false,
      );
    }

    // If user asks for assessment, provide one
    if (message.toLowerCase().contains('assessment') ||
        message.toLowerCase().contains('yes, please') ||
        message.toLowerCase().contains('please do')) {

      final assessment = AiAssessment(
        scaleValues: [
          MoodScaleValue(
            scaleId: '9e28a52b-1a43-456d-be3d-85ec1d8d7dc5',
            scaleName: 'Mood (Humeur)',
            value: 6,
          ),
          MoodScaleValue(
            scaleId: 'a3cfcd9b-2608-4dce-a576-b0cab5894af5',
            scaleName: 'Irritability (Irritabilité)',
            value: 8,
          ),
          MoodScaleValue(
            scaleId: 'c7f09f47-c71f-4d2e-9e06-b53c6e9dec2f',
            scaleName: 'Confidence (Confiance)',
            value: 5,
          ),
        ],
        comment: "The user seems to be experiencing moderate stress and anxiety today. They mentioned difficulty sleeping and feeling overwhelmed with work.",
        sleepHours: 6.0,
      );

      return AiChatResponse(
        message: "I've created an assessment based on our conversation. You can review it and save it to your mood journal if it accurately reflects your current state.",
        isAssessment: true,
        assessment: assessment,
      );
    }

    // Generic response
    return AiChatResponse(
      message: "Thank you for sharing that. How long have you been feeling this way?",
      isAssessment: false,
    );
  }

  @override
  Future<AiAssessment> generateAssessment({required List<Map<String, dynamic>> conversation}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Create a mock assessment
    return AiAssessment(
      scaleValues: [
        MoodScaleValue(
          scaleId: '9e28a52b-1a43-456d-be3d-85ec1d8d7dc5',
          scaleName: 'Mood (Humeur)',
          value: 6,
        ),
        MoodScaleValue(
          scaleId: 'a3cfcd9b-2608-4dce-a576-b0cab5894af5',
          scaleName: 'Irritability (Irritabilité)',
          value: 8,
        ),
        MoodScaleValue(
          scaleId: 'c7f09f47-c71f-4d2e-9e06-b53c6e9dec2f',
          scaleName: 'Confidence (Confiance)',
          value: 5,
        ),
      ],
      comment: "Based on our conversation, it seems you're experiencing moderate stress and anxiety. You mentioned difficulty sleeping and feeling overwhelmed with work responsibilities.",
      sleepHours: 6.0,
    );
  }
}