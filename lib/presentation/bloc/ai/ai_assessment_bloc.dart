import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/usecases/ai/chat_with_ai.dart';
import 'package:mood_tracker/domain/usecases/ai/generate_assessment.dart';
import 'package:mood_tracker/domain/usecases/ai/save_assessment.dart';
import 'package:mood_tracker/presentation/bloc/ai/ai_assessment_event.dart';
import 'package:mood_tracker/presentation/bloc/ai/ai_assessment_state.dart';

class AiAssessmentBloc extends Bloc<AiAssessmentEvent, AiAssessmentState> {
  final ChatWithAi chatWithAi;
  final GenerateAssessment generateAssessment;
  final SaveAssessment saveAssessment;

  AiAssessmentBloc({
    required this.chatWithAi,
    required this.generateAssessment,
    required this.saveAssessment,
  }) : super(AiAssessmentInitial()) {
    on<InitializeChat>(_onInitializeChat);
    on<SendChatMessage>(_onSendChatMessage);
    on<GenerateAiAssessment>(_onGenerateAssessment);
    on<SaveAiAssessment>(_onSaveAssessment);
  }

  Future<void> _onInitializeChat(
      InitializeChat event,
      Emitter<AiAssessmentState> emit,
      ) async {
    emit(AiAssessmentInitialized(
      conversation: const [],
      isFirstMessage: true,
    ));
  }

  Future<void> _onSendChatMessage(
      SendChatMessage event,
      Emitter<AiAssessmentState> emit,
      ) async {
    final currentState = state;

    if (currentState is AiAssessmentInitialized ||
        currentState is ChatMessageReceived ||
        currentState is AssessmentGenerated) {
      // Add user message to conversation
      final currentConversation = _getCurrentConversation(currentState);
      final updatedConversation = List.of(currentConversation)
        ..add(ChatMessage(
          content: event.message,
          isUser: true,
        ));

      emit(ChatMessageSending(
        conversation: updatedConversation,
        isFirstMessage: false,
      ));

      final result = await chatWithAi(ChatWithAiParams(message: event.message));

      result.fold(
            (failure) => emit(AiAssessmentError(
          message: failure.message,
          conversation: updatedConversation,
        )),
            (response) {
          final updatedConversationWithResponse = List.of(updatedConversation)
            ..add(ChatMessage(
              content: response.message,
              isUser: false,
              isAssessment: response.isAssessment,
              assessment: response.assessment,
            ));

          if (response.isAssessment) {
            emit(AssessmentGenerated(
              conversation: updatedConversationWithResponse,
              assessment: response.assessment!,
            ));
          } else {
            emit(ChatMessageReceived(
              conversation: updatedConversationWithResponse,
              isFirstMessage: false,
            ));
          }
        },
      );
    }
  }

  Future<void> _onGenerateAssessment(
      GenerateAiAssessment event,
      Emitter<AiAssessmentState> emit,
      ) async {
    final currentState = state;

    if (currentState is AiAssessmentInitialized ||
        currentState is ChatMessageReceived) {
      final currentConversation = _getCurrentConversation(currentState);

      emit(AssessmentGenerating(
        conversation: currentConversation,
      ));

      final result = await generateAssessment(GenerateAssessmentParams(
        conversation: currentConversation.map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        }).toList(),
      ));

      result.fold(
            (failure) => emit(AiAssessmentError(
          message: failure.message,
          conversation: currentConversation,
        )),
            (assessment) {
          final updatedConversation = List.of(currentConversation)
            ..add(ChatMessage(
              content: 'Based on our conversation, I\'ve created an assessment of your mood. You can review it and save it to your mood journal if it accurately reflects how you\'re feeling.',
              isUser: false,
              isAssessment: true,
              assessment: assessment,
            ));

          emit(AssessmentGenerated(
            conversation: updatedConversation,
            assessment: assessment,
          ));
        },
      );
    }
  }

  Future<void> _onSaveAssessment(
      SaveAiAssessment event,
      Emitter<AiAssessmentState> emit,
      ) async {
    final currentState = state;

    if (currentState is AssessmentGenerated) {
      emit(AssessmentSaving(
        conversation: currentState.conversation,
        assessment: currentState.assessment,
      ));

      final result = await saveAssessment(SaveAssessmentParams(
        scaleValues: event.assessment.scaleValues,
        sleepHours: event.assessment.sleepHours,
        comment: event.assessment.comment,
        medication: event.assessment.medication,
      ));

      result.fold(
            (failure) => emit(AiAssessmentError(
          message: failure.message,
          conversation: currentState.conversation,
        )),
            (entry) {
          emit(AssessmentSaved(
            conversation: currentState.conversation,
            assessment: currentState.assessment,
            savedEntry: entry,
          ));
        },
      );
    }
  }

  List<ChatMessage> _getCurrentConversation(AiAssessmentState state) {
    if (state is AiAssessmentInitialized) {
      return state.conversation;
    } else if (state is ChatMessageSending) {
      return state.conversation;
    } else if (state is ChatMessageReceived) {
      return state.conversation;
    } else if (state is AssessmentGenerating) {
      return state.conversation;
    } else if (state is AssessmentGenerated) {
      return state.conversation;
    } else if (state is AssessmentSaving) {
      return state.conversation;
    } else if (state is AssessmentSaved) {
      return state.conversation;
    } else if (state is AiAssessmentError) {
      return state.conversation;
    }

    return [];
  }
}