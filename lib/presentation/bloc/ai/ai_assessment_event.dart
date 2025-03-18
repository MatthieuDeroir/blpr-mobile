import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/ai_assessment.dart';

abstract class AiAssessmentEvent extends Equatable {
  const AiAssessmentEvent();

  @override
  List<Object?> get props => [];
}

class InitializeChat extends AiAssessmentEvent {
  const InitializeChat();
}

class SendChatMessage extends AiAssessmentEvent {
  final String message;

  const SendChatMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

class GenerateAiAssessment extends AiAssessmentEvent {
  const GenerateAiAssessment();
}

class SaveAiAssessment extends AiAssessmentEvent {
  final AiAssessment assessment;

  const SaveAiAssessment({required this.assessment});

  @override
  List<Object?> get props => [assessment];
}