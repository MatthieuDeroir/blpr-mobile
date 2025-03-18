import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/repositories/mood_entry_repository.dart';

class DeleteMoodEntry {
  final MoodEntryRepository repository;

  DeleteMoodEntry(this.repository);

  Future<Either<Failure, bool>> call(DeleteMoodEntryParams params) {
    return repository.deleteMoodEntry(params.id);
  }
}

class DeleteMoodEntryParams extends Equatable {
  final String id;

  const DeleteMoodEntryParams({required this.id});

  @override
  List<Object?> get props => [id];
}