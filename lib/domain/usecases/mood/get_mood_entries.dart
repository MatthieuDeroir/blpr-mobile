import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/repositories/mood_entry_repository.dart';

class GetMoodEntries {
  final MoodEntryRepository repository;

  GetMoodEntries(this.repository);

  Future<Either<Failure, List<MoodEntry>>> call(GetMoodEntriesParams params) {
    return repository.getMoodEntries(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetMoodEntriesParams extends Equatable {
  final int? limit;
  final int? offset;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetMoodEntriesParams({
    this.limit,
    this.offset,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [limit, offset, startDate, endDate];
}