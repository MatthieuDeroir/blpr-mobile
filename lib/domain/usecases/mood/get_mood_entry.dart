import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/repositories/mood_entry_repository.dart';

class GetMoodEntry {
  final MoodEntryRepository repository;

  GetMoodEntry(this.repository);

  Future<Either<Failure, MoodEntry>> call(GetMoodEntryParams params) {
    return repository.getMoodEntryById(params.id);
  }
}

class GetMoodEntryParams extends Equatable {
  final String id;

  const GetMoodEntryParams({required this.id});

  @override
  List<Object?> get props => [id];
}