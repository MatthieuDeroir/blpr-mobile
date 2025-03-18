import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';

class AiAssessment extends Equatable {
  final List<MoodScaleValue> scaleValues;
  final String? comment;
  final String? medication;
  final double? sleepHours;

  const AiAssessment({
    required this.scaleValues,
    this.comment,
    this.medication,
    this.sleepHours,
  });

  @override
  List<Object?> get props => [
    scaleValues,
    comment,
    medication,
    sleepHours,
  ];
}