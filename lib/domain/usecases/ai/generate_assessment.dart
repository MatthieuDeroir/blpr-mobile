import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/ai_assessment.dart';
import 'package:mood_tracker/domain/repositories/ai_assessment_repository.dart';

class GenerateAssessment {
  final AiAssessmentRepository repository;

  GenerateAssessment(this.repository);

  Future<Either<Failure, AiAssessment>> call(GenerateAssessmentParams params) {
    return repository.generateAssessment(conversation: params.conversation);
  }
}

class GenerateAssessmentParams extends Equatable {
  final List<Map<String, dynamic>> conversation;

  const GenerateAssessmentParams({required this.conversation});

  @override
  List<Object?> get props => [conversation];
}