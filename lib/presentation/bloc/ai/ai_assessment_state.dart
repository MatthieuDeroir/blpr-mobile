import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/ai_assessment.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';

abstract class AiAssessmentState extends Equatable {
  const AiAssessmentState();

  @override
  List<Object?> get props => [];
}

class AiAssessmentInitial extends AiAssessmentState {}

class AiAssessmentInitialized extends AiAssessmentState {
  final List<ChatMessage> conversation;
  final bool isFirstMessage;

  const AiAssessmentInitialized({
    required this.conversation,
    this.isFirstMessage = true,
  });

  @override
  List<Object?> get props => [conversation, isFirstMessage];
}

class ChatMessageSending extends AiAssessmentState {
  final List<ChatMessage> conversation;
  final bool isFirstMessage;

  const ChatMessageSending({
    required this.conversation,
    this.isFirstMessage = false,
  });

  @override
  List<Object?> get props => [conversation, isFirstMessage];
}

class ChatMessageReceived extends AiAssessmentState {
  final List<ChatMessage> conversation;
  final bool isFirstMessage;

  const ChatMessageReceived({
    required this.conversation,
    this.isFirstMessage = false,
  });

  @override
  List<Object?> get props => [conversation, isFirstMessage];
}

class AssessmentGenerating extends AiAssessmentState {
  final List<ChatMessage> conversation;

  const AssessmentGenerating({
    required this.conversation,
  });

  @override
  List<Object?> get props => [conversation];
}

class AssessmentGenerated extends AiAssessmentState {
  final List<ChatMessage> conversation;
  final AiAssessment assessment;

  const AssessmentGenerated({
    required this.conversation,
    required this.assessment,
  });

  @override
  List<Object?> get props => [conversation, assessment];
}

class AssessmentSaving extends AiAssessmentState {
  final List<ChatMessage> conversation;
  final AiAssessment assessment;

  const AssessmentSaving({
    required this.conversation,
    required this.assessment,
  });

  @override
  List<Object?> get props => [conversation, assessment];
}

class AssessmentSaved extends AiAssessmentState {
  final List<ChatMessage> conversation;
  final AiAssessment assessment;
  final MoodEntry savedEntry;

  const AssessmentSaved({
    required this.conversation,
    required this.assessment,
    required this.savedEntry,
  });

  @override
  List<Object?> get props => [conversation, assessment, savedEntry];
}

class AiAssessmentError extends AiAssessmentState {
  final String message;
  final List<ChatMessage> conversation;

  const AiAssessmentError({
    required this.message,
    required this.conversation,
  });

  @override
  List<Object?> get props => [message, conversation];
}

class ChatMessage {
  final String content;
  final bool isUser;
  final bool isAssessment;
  final AiAssessment? assessment;

  const ChatMessage({
    required this.content,
    required this.isUser,
    this.isAssessment = false,
    this.assessment,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.content == content &&
        other.isUser == isUser &&
        other.isAssessment == isAssessment;
  }

  @override
  int get hashCode => content.hashCode ^ isUser.hashCode ^ isAssessment.hashCode;
}