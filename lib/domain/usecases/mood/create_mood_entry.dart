import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/repositories/mood_entry_repository.dart';

class CreateMoodEntry {
  final MoodEntryRepository repository;

  CreateMoodEntry(this.repository);

  Future<Either<Failure, MoodEntry>> call(CreateMoodEntryParams params) {
    return repository.createMoodEntry(
      entryDate: params.entryDate,
      comment: params.comment,
      medication: params.medication,
      sleepHours: params.sleepHours,
      scaleValues: params.scaleValues,
    );
  }
}

class CreateMoodEntryParams extends Equatable {
  final DateTime entryDate;
  final String? comment;
  final String? medication;
  final double? sleepHours;
  final List<MoodScaleValue> scaleValues;

  const CreateMoodEntryParams({
    required this.entryDate,
    this.comment,
    this.medication,
    this.sleepHours,
    required this.scaleValues,
  });

  @override
  List<Object?> get props => [
    entryDate,
    comment,
    medication,
    sleepHours,
    scaleValues,
  ];
}