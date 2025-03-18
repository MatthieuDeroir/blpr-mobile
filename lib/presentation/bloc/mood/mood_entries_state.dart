// lib/presentation/bloc/mood/mood_entries_state.dart
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';

abstract class MoodEntriesState extends Equatable {
  const MoodEntriesState();

  @override
  List<Object?> get props => [];
}

class MoodEntriesInitial extends MoodEntriesState {}

class MoodEntriesLoading extends MoodEntriesState {}

class MoodEntriesLoaded extends MoodEntriesState {
  final List<MoodEntry> entries;
  final bool hasReachedMax;
  final int totalLoaded;
  final bool filteredByDate;
  final DateTime? startDate;
  final DateTime? endDate;

  const MoodEntriesLoaded({
    required this.entries,
    required this.hasReachedMax,
    required this.totalLoaded,
    this.filteredByDate = false,
    this.startDate,
    this.endDate,
  });

  MoodEntriesLoaded copyWith({
    List<MoodEntry>? entries,
    bool? hasReachedMax,
    int? totalLoaded,
    bool? filteredByDate,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MoodEntriesLoaded(
      entries: entries ?? this.entries,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalLoaded: totalLoaded ?? this.totalLoaded,
      filteredByDate: filteredByDate ?? this.filteredByDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    entries,
    hasReachedMax,
    totalLoaded,
    filteredByDate,
    startDate,
    endDate,
  ];
}

class MoodEntriesError extends MoodEntriesState {
  final String message;

  const MoodEntriesError(this.message);

  @override
  List<Object?> get props => [message];
}