import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/domain/entities/ai_assessment.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/presentation/bloc/ai/ai_assessment_bloc.dart';
import 'package:mood_tracker/presentation/bloc/ai/ai_assessment_event.dart';
import 'package:mood_tracker/presentation/bloc/ai/ai_assessment_state.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';

class AiAssessmentPage extends StatefulWidget {
  const AiAssessmentPage({Key? key}) : super(key: key);

  @override
  State<AiAssessmentPage> createState() => _AiAssessmentPageState();
}

class _AiAssessmentPageState extends State<AiAssessmentPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AiAssessmentBloc>().add(const InitializeChat());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mood Assistant'),
        actions: [
          BlocBuilder<AiAssessmentBloc, AiAssessmentState>(
            builder: (context, state) {
              if (state is ChatMessageReceived ||
                  state is AssessmentGenerated ||
                  state is AssessmentSaved) {
                return IconButton(
                  icon: const Icon(Icons.assessment),
                  tooltip: 'Generate assessment',
                  onPressed: () {
                    context.read<AiAssessmentBloc>().add(const GenerateAiAssessment());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: BlocConsumer<AiAssessmentBloc, AiAssessmentState>(
              listener: (context, state) {
                if (state is ChatMessageReceived ||
                    state is AssessmentGenerated ||
                    state is AssessmentSaved) {
                  _scrollToBottom();
                }

                if (state is AssessmentSaved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assessment saved successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }

                if (state is AiAssessmentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AiAssessmentInitial) {
                  return const Center(child: LoadingIndicator());
                }

                if (state is AiAssessmentInitialized && state.isFirstMessage) {
                  return _buildWelcomeScreen();
                }

                // Get conversation from various states
                final conversation = _getConversation(state);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: conversation.length,
                  itemBuilder: (context, index) {
                    final message = conversation[index];

                    if (message.isAssessment && message.assessment != null) {
                      return _buildAssessmentMessage(message, state);
                    } else {
                      return _buildChatMessage(message);
                    }
                  },
                );
              },
            ),
          ),

          // Status indicator
          BlocBuilder<AiAssessmentBloc, AiAssessmentState>(
            builder: (context, state) {
              if (state is ChatMessageSending) {
                return Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Thinking...'),
                    ],
                  ),
                );
              } else if (state is AssessmentGenerating) {
                return Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Generating assessment...'),
                    ],
                  ),
                );
              } else if (state is AssessmentSaving) {
                return Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Saving assessment...'),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                BlocBuilder<AiAssessmentBloc, AiAssessmentState>(
                  builder: (context, state) {
                    final isLoading = state is ChatMessageSending ||
                        state is AssessmentGenerating ||
                        state is AssessmentSaving;

                    return IconButton(
                      icon: Icon(
                        Icons.send,
                        color: isLoading ? Colors.grey : AppColors.primary,
                      ),
                      onPressed: isLoading ? null : _sendMessage,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ChatMessage> _getConversation(AiAssessmentState state) {
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

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<AiAssessmentBloc>().add(SendChatMessage(message: message));
      _messageController.clear();

      // Scroll to bottom after a short delay to ensure new messages are in view
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.psychology,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'AI Mood Assistant',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Chat with the AI assistant about how you\'re feeling. The AI can help assess your mood and generate mood entries for your journal.',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _messageController.text = 'Hello! I\'d like to talk about how I\'m feeling today.';
                _sendMessage();
              },
              child: const Text('Start a conversation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentMessage(ChatMessage message, AiAssessmentState state) {
    final assessment = message.assessment!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      // Header
      Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.psychology,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI Mood Assessment',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          // Show different actions based on state
          if (state is AssessmentGenerated)
            TextButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () {
                context.read<AiAssessmentBloc>().add(
                  SaveAiAssessment(assessment: assessment),
                );
              },
            ),
          if (state is AssessmentSaved)
            const Chip(
              label: Text('Saved'),
              backgroundColor: AppColors.success,
              labelStyle: TextStyle(color: Colors.white),
            ),
        ],
      ),
    ),