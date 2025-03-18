// lib/presentation/bloc/mood/mood_entries_event.dart
import 'package:equatable/equatable.dart';

abstract class MoodEntriesEvent extends Equatable {
  const MoodEntriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoodEntries extends MoodEntriesEvent {
  final int limit;

  const LoadMoodEntries({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class RefreshMoodEntries extends MoodEntriesEvent {}

class LoadMoreMoodEntries extends MoodEntriesEvent {
  final int limit;

  const LoadMoreMoodEntries({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class DeleteMoodEntryEvent extends MoodEntriesEvent {
  final String id;

  const DeleteMoodEntryEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class FilterMoodEntriesByDate extends MoodEntriesEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterMoodEntriesByDate({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}