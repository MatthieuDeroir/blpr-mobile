import 'package:dartz/dartz.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';

abstract class MoodEntryRepository {
  /// Get mood entries for the current user with optional pagination
  Future<Either<Failure, List<MoodEntry>>> getMoodEntries({int? limit, int? offset});

  /// Get a specific mood entry by ID
  Future<Either<Failure, MoodEntry>> getMoodEntryById(String id);

  /// Create a new mood entry
  Future<Either<Failure, MoodEntry>> createMoodEntry({
    required DateTime entryDate,
    String? comment,
    String? medication,
    double? sleepHours,
    required List<MoodScaleValue> scaleValues,
  });

  /// Update an existing mood entry
  Future<Either<Failure, MoodEntry>> updateMoodEntry({
    required String id,
    DateTime? entryDate,
    String? comment,
    String? medication,
    double? sleepHours,
    List<MoodScaleValue>? scaleValues,
  });

  /// Delete a mood entry
  Future<Either<Failure, bool>> deleteMoodEntry(String id);

  /// Get mood entries for a specific date range
  Future<Either<Failure, List<MoodEntry>>> getMoodEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}