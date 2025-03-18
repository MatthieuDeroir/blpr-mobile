import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/repositories/ai_assessment_repository.dart';

class SaveAssessment {
  final AiAssessmentRepository repository;

  SaveAssessment(this.repository);

  Future<Either<Failure, MoodEntry>> call(SaveAssessmentParams params) {
    return repository.saveAssessment(
      scaleValues: params.scaleValues,
      comment: params.comment,
      medication: params.medication,
      sleepHours: params.sleepHours,
    );
  }
}

class SaveAssessmentParams extends Equatable {
  final List<MoodScaleValue> scaleValues;
  final String? comment;
  final String? medication;
  final double? sleepHours;

  const SaveAssessmentParams({
    required this.scaleValues,
    this.comment,
    this.medication,
    this.sleepHours,
  });

  @override
  List<Object?> get props => [scaleValues, comment, medication, sleepHours];
}