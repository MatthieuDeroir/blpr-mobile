// lib/presentation/bloc/mood/mood_entry_form_state.dart
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:mood_tracker/domain/entities/scale.dart';

abstract class MoodEntryFormState extends Equatable {
  const MoodEntryFormState();

  @override
  List<Object?> get props => [];
}

class MoodEntryFormInitial extends MoodEntryFormState {}

class MoodEntryFormLoading extends MoodEntryFormState {}

class MoodEntryFormLoaded extends MoodEntryFormState {
  final String? entryId;
  final DateTime entryDate;
  final List<MoodScaleValue> scaleValues;
  final String comment;
  final String medication;
  final double? sleepHours;
  final List<Scale> availableScales;
  final bool isEditing;

  const MoodEntryFormLoaded({
    this.entryId,
    required this.entryDate,
    required this.scaleValues,
    required this.comment,
    required this.medication,
    this.sleepHours,
    required this.availableScales,
    this.isEditing = false,
  });

  MoodEntryFormLoaded copyWith({
    String? entryId,
    DateTime? entryDate,
    List<MoodScaleValue>? scaleValues,
    String? comment,
    String? medication,
    double? sleepHours,
    List<Scale>? availableScales,
    bool? isEditing,
  }) {
    return MoodEntryFormLoaded(
      entryId: entryId ?? this.entryId,
      entryDate: entryDate ?? this.entryDate,
      scaleValues: scaleValues ?? this.scaleValues,
      comment: comment ?? this.comment,
      medication: medication ?? this.medication,
      sleepHours: sleepHours ?? this.sleepHours,
      availableScales: availableScales ?? this.availableScales,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  Scale? getScaleById(String scaleId) {
    try {
      return availableScales.firstWhere((scale) => scale.id == scaleId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    entryId,
    entryDate,
    scaleValues,
    comment,
    medication,
    sleepHours,
    availableScales,
    isEditing,
  ];
}

class MoodEntryFormSubmitting extends MoodEntryFormState {}

class MoodEntryFormSubmitted extends MoodEntryFormState {
  final MoodEntry entry;

  const MoodEntryFormSubmitted(this.entry);

  @override
  List<Object?> get props => [entry];
}

class MoodEntryFormError extends MoodEntryFormState {
  final String message;

  const MoodEntryFormError(this.message);

  @override
  List<Object?> get props => [message];
}