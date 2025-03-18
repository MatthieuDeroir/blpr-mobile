import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/repositories/mood_entry_repository.dart';

class UpdateMoodEntry {
  final MoodEntryRepository repository;

  UpdateMoodEntry(this.repository);

  Future<Either<Failure, MoodEntry>> call(UpdateMoodEntryParams params) {
    return repository.updateMoodEntry(
      id: params.id,
      entryDate: params.entryDate,
      comment: params.comment,
      medication: params.medication,
      sleepHours: params.sleepHours,
      scaleValues: params.scaleValues,
    );
  }
}

class UpdateMoodEntryParams extends Equatable {
  final String id;
  final DateTime entryDate;
  final String? comment;
  final String? medication;
  final double? sleepHours;
  final List<MoodScaleValue> scaleValues;

  const UpdateMoodEntryParams({
    required this.id,
    required this.entryDate,
    this.comment,
    this.medication,
    this.sleepHours,
    required this.scaleValues,
  });

  @override
  List<Object?> get props => [
    id,
    entryDate,
    comment,
    medication,
    sleepHours,
    scaleValues,
  ];
}