import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/ai_assessment.dart';
import 'package:mood_tracker/domain/repositories/ai_assessment_repository.dart';

class ChatWithAi {
  final AiAssessmentRepository repository;

  ChatWithAi(this.repository);

  Future<Either<Failure, AiChatResponse>> call(ChatWithAiParams params) {
    return repository.chatWithAi(message: params.message);
  }
}

class ChatWithAiParams extends Equatable {
  final String message;

  const ChatWithAiParams({required this.message});

  @override
  List<Object?> get props => [message];
}

class AiChatResponse extends Equatable {
  final String message;
  final bool isAssessment;
  final AiAssessment? assessment;

  const AiChatResponse({
    required this.message,
    this.isAssessment = false,
    this.assessment,
  });

  @override
  List<Object?> get props => [message, isAssessment, assessment];
}