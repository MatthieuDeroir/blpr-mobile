// lib/presentation/bloc/mood/mood_entry_form_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/usecases/mood/create_mood_entry.dart';
import 'package:mood_tracker/domain/usecases/mood/get_mood_entry.dart';
import 'package:mood_tracker/domain/usecases/mood/update_mood_entry.dart';
import 'package:mood_tracker/domain/usecases/scale/get_scales.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entry_form_event.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entry_form_state.dart';

class MoodEntryFormBloc extends Bloc<MoodEntryFormEvent, MoodEntryFormState> {
  final CreateMoodEntry createMoodEntry;
  final UpdateMoodEntry updateMoodEntry;
  final GetMoodEntry getMoodEntry;
  final GetScales getScales;

  MoodEntryFormBloc({
    required this.createMoodEntry,
    required this.updateMoodEntry,
    required this.getMoodEntry,
    required this.getScales,
  }) : super(MoodEntryFormInitial()) {
    on<InitializeMoodEntryForm>(_onInitializeForm);
    on<LoadMoodEntryForEdit>(_onLoadMoodEntry);
    on<UpdateScaleValue>(_onUpdateScaleValue);
    on<UpdateEntryDate>(_onUpdateEntryDate);
    on<UpdateComment>(_onUpdateComment);
    on<UpdateMedication>(_onUpdateMedication);
    on<UpdateSleepHours>(_onUpdateSleepHours);
    on<SubmitMoodEntryForm>(_onSubmitForm);
  }

  Future<void> _onInitializeForm(
      InitializeMoodEntryForm event,
      Emitter<MoodEntryFormState> emit,
      ) async {
    emit(MoodEntryFormLoading());

    final scalesResult = await getScales(const GetScalesParams());

    scalesResult.fold(
          (failure) {
        emit(MoodEntryFormError(failure.message));
      },
          (scales) {
        final scaleValues = scales
            .where((scale) => scale.isActive)
            .map((scale) => MoodScaleValue(
          scaleId: scale.id,
          scaleName: scale.name,
          // Default to middle value
          value: scale.minValue + ((scale.maxValue - scale.minValue) ~/ 2),
        ))
            .toList();

        emit(MoodEntryFormLoaded(
          entryId: null,
          entryDate: DateTime.now(),
          scaleValues: scaleValues,
          comment: '',
          medication: '',
          sleepHours: null,
          availableScales: scales,
        ));
      },
    );
  }

  Future<void> _onLoadMoodEntry(
      LoadMoodEntryForEdit event,
      Emitter<MoodEntryFormState> emit,
      ) async {
    emit(MoodEntryFormLoading());

    final scalesResult = await getScales(const GetScalesParams());
    final entryResult = await getMoodEntry(GetMoodEntryParams(id: event.id));

    // Handle possible error cases
    if (scalesResult.isLeft()) {
      scalesResult.fold(
            (failure) => emit(MoodEntryFormError(failure.message)),
            (_) => null,
      );
      return;
    }

    if (entryResult.isLeft()) {
      entryResult.fold(
            (failure) => emit(MoodEntryFormError(failure.message)),
            (_) => null,
      );
      return;
    }

    // Extract data if both results are successful
    final scales = scalesResult.getOrElse(() => []);

    // Fix: Don't use null as the fallback for MoodEntry
    final entry = entryResult.getOrElse(() {
      // Create a default entry if none is found (this should not happen in practice)
      return MoodEntry(
        id: event.id,
        userId: '',
        entryDate: DateTime.now(),
        scaleValues: [],
      );
    });

    // Make sure all active scales are represented in the form
    final existingScaleIds = entry.scaleValues.map((sv) => sv.scaleId).toSet();
    final additionalScaleValues = scales
        .where((scale) => scale.isActive && !existingScaleIds.contains(scale.id))
        .map((scale) => MoodScaleValue(
      scaleId: scale.id,
      scaleName: scale.name,
      value: scale.minValue + ((scale.maxValue - scale.minValue) ~/ 2),
    ))
        .toList();

    final allScaleValues = [...entry.scaleValues, ...additionalScaleValues];

    emit(MoodEntryFormLoaded(
      entryId: entry.id,
      entryDate: entry.entryDate,
      scaleValues: allScaleValues,
      comment: entry.comment ?? '',
      medication: entry.medication ?? '',
      sleepHours: entry.sleepHours,
      availableScales: scales,
      isEditing: true,
    ));
  }

  void _onUpdateScaleValue(
      UpdateScaleValue event,
      Emitter<MoodEntryFormState> emit,
      ) {
    final currentState = state;
    if (currentState is MoodEntryFormLoaded) {
      final updatedScaleValues = currentState.scaleValues.map((scaleValue) {
        if (scaleValue.scaleId == event.scaleId) {
          return MoodScaleValue(
            scaleId: scaleValue.scaleId,
            scaleName: scaleValue.scaleName,
            value: event.value,
            description: scaleValue.description,
          );
        }
        return scaleValue;
      }).toList();

      emit(currentState.copyWith(scaleValues: updatedScaleValues));
    }
  }

  void _onUpdateEntryDate(
      UpdateEntryDate event,
      Emitter<MoodEntryFormState> emit,
      ) {
    final currentState = state;
    if (currentState is MoodEntryFormLoaded) {
      emit(currentState.copyWith(entryDate: event.date));
    }
  }

  void _onUpdateComment(
      UpdateComment event,
      Emitter<MoodEntryFormState> emit,
      ) {
    final currentState = state;
    if (currentState is MoodEntryFormLoaded) {
      emit(currentState.copyWith(comment: event.comment));
    }
  }

  void _onUpdateMedication(
      UpdateMedication event,
      Emitter<MoodEntryFormState> emit,
      ) {
    final currentState = state;
    if (currentState is MoodEntryFormLoaded) {
      emit(currentState.copyWith(medication: event.medication));
    }
  }

  void _onUpdateSleepHours(
      UpdateSleepHours event,
      Emitter<MoodEntryFormState> emit,
      ) {
    final currentState = state;
    if (currentState is MoodEntryFormLoaded) {
      emit(currentState.copyWith(sleepHours: event.hours));
    }
  }

  Future<void> _onSubmitForm(
      SubmitMoodEntryForm event,
      Emitter<MoodEntryFormState> emit,
      ) async {
    final currentState = state;
    if (currentState is MoodEntryFormLoaded) {
      emit(MoodEntryFormSubmitting());

      final result = currentState.isEditing
          ? await updateMoodEntry(
        UpdateMoodEntryParams(
          id: currentState.entryId!,
          entryDate: currentState.entryDate,
          comment: currentState.comment.isEmpty ? null : currentState.comment,
          medication: currentState.medication.isEmpty ? null : currentState.medication,
          sleepHours: currentState.sleepHours,
          scaleValues: currentState.scaleValues,
        ),
      )
          : await createMoodEntry(
        CreateMoodEntryParams(
          entryDate: currentState.entryDate,
          comment: currentState.comment.isEmpty ? null : currentState.comment,
          medication: currentState.medication.isEmpty ? null : currentState.medication,
          sleepHours: currentState.sleepHours,
          scaleValues: currentState.scaleValues,
        ),
      );

      result.fold(
            (failure) => emit(MoodEntryFormError(failure.message)),
            (entry) => emit(MoodEntryFormSubmitted(entry)),
      );
    }
  }
}