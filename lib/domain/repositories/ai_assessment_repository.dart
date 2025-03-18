import 'package:dartz/dartz.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/ai_assessment.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/usecases/ai/chat_with_ai.dart';

abstract class AiAssessmentRepository {
  /// Send a message to the AI assistant
  Future<Either<Failure, AiChatResponse>> chatWithAi({required String message});

  /// Generate an assessment from a conversation history
  Future<Either<Failure, AiAssessment>> generateAssessment({
    required List<Map<String, dynamic>> conversation,
  });

  /// Save an assessment as a mood entry
  Future<Either<Failure, MoodEntry>> saveAssessment({
    required List<MoodScaleValue> scaleValues,
    String? comment,
    String? medication,
    double? sleepHours,
  });
}