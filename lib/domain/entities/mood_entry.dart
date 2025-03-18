import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';

class MoodEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime entryDate;
  final String? comment;
  final String? medication;
  final double? sleepHours;
  final double? stabilityScore;
  final String? stabilityDescription;
  final List<MoodScaleValue> scaleValues;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.entryDate,
    this.comment,
    this.medication,
    this.sleepHours,
    this.stabilityScore,
    this.stabilityDescription,
    required this.scaleValues,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    entryDate,
    comment,
    medication,
    sleepHours,
    stabilityScore,
    stabilityDescription,
    scaleValues,
  ];
}