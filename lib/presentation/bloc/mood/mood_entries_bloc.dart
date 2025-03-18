// lib/presentation/bloc/mood/mood_entries_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/usecases/mood/get_mood_entries.dart';
import 'package:mood_tracker/domain/usecases/mood/delete_mood_entry.dart';
import 'package:mood_tracker/domain/repositories/mood_entry_repository.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_event.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_state.dart';

class MoodEntriesBloc extends Bloc<MoodEntriesEvent, MoodEntriesState> {
  final GetMoodEntries getMoodEntries;
  final DeleteMoodEntry deleteMoodEntry;
  final MoodEntryRepository moodEntryRepository; // Added for date filtering

  MoodEntriesBloc({
    required this.getMoodEntries,
    required this.deleteMoodEntry,
    required this.moodEntryRepository,
  }) : super(MoodEntriesInitial()) {
    on<LoadMoodEntries>(_onLoadMoodEntries);
    on<RefreshMoodEntries>(_onRefreshMoodEntries);
    on<LoadMoreMoodEntries>(_onLoadMoreMoodEntries);
    on<DeleteMoodEntryEvent>(_onDeleteMoodEntry);
    on<FilterMoodEntriesByDate>(_onFilterMoodEntriesByDate);
  }

  Future<void> _onLoadMoodEntries(
      LoadMoodEntries event,
      Emitter<MoodEntriesState> emit,
      ) async {
    emit(MoodEntriesLoading());

    final result = await getMoodEntries(
      GetMoodEntriesParams(limit: event.limit, offset: 0),
    );

    result.fold(
          (failure) => emit(MoodEntriesError(failure.message)),
          (entries) => emit(MoodEntriesLoaded(
        entries: entries,
        hasReachedMax: entries.length < event.limit,
        totalLoaded: entries.length,
      )),
    );
  }

  Future<void> _onRefreshMoodEntries(
      RefreshMoodEntries event,
      Emitter<MoodEntriesState> emit,
      ) async {
    final currentState = state;
    int limit = 10;

    if (currentState is MoodEntriesLoaded) {
      limit = currentState.totalLoaded;
    }

    final result = await getMoodEntries(
      GetMoodEntriesParams(limit: limit, offset: 0),
    );

    result.fold(
          (failure) => emit(MoodEntriesError(failure.message)),
          (entries) => emit(MoodEntriesLoaded(
        entries: entries,
        hasReachedMax: entries.length < limit,
        totalLoaded: entries.length,
      )),
    );
  }

  Future<void> _onLoadMoreMoodEntries(
      LoadMoreMoodEntries event,
      Emitter<MoodEntriesState> emit,
      ) async {
    final currentState = state;
    if (currentState is MoodEntriesLoaded) {
      if (currentState.hasReachedMax) return;

      final result = await getMoodEntries(
        GetMoodEntriesParams(
          limit: event.limit,
          offset: currentState.totalLoaded,
        ),
      );

      result.fold(
            (failure) => emit(MoodEntriesError(failure.message)),
            (newEntries) {
          if (newEntries.isEmpty) {
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            emit(MoodEntriesLoaded(
              entries: [...currentState.entries, ...newEntries],
              hasReachedMax: newEntries.length < event.limit,
              totalLoaded: currentState.totalLoaded + newEntries.length,
            ));
          }
        },
      );
    }
  }

  Future<void> _onDeleteMoodEntry(
      DeleteMoodEntryEvent event,
      Emitter<MoodEntriesState> emit,
      ) async {
    final currentState = state;
    if (currentState is MoodEntriesLoaded) {
      // Optimistic update
      final updatedEntries = List<MoodEntry>.from(currentState.entries)
        ..removeWhere((entry) => entry.id == event.id);

      emit(MoodEntriesLoaded(
        entries: updatedEntries,
        hasReachedMax: currentState.hasReachedMax,
        totalLoaded: currentState.totalLoaded - 1,
      ));

      final result = await deleteMoodEntry(DeleteMoodEntryParams(id: event.id));

      result.fold(
            (failure) {
          // Revert on failure
          emit(MoodEntriesError(failure.message));
          add(RefreshMoodEntries());
        },
            (_) => null, // Already updated optimistically
      );
    }
  }

  Future<void> _onFilterMoodEntriesByDate(
      FilterMoodEntriesByDate event,
      Emitter<MoodEntriesState> emit,
      ) async {
    emit(MoodEntriesLoading());

    // Use the repository's date range method directly
    final result = await moodEntryRepository.getMoodEntriesByDateRange(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
          (failure) => emit(MoodEntriesError(failure.message)),
          (entries) => emit(MoodEntriesLoaded(
        entries: entries,
        hasReachedMax: true, // When filtering, we load all matching entries
        totalLoaded: entries.length,
        filteredByDate: true,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }
}