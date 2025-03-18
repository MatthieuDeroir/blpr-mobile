// lib/presentation/bloc/mood/mood_entry_form_event.dart
import 'package:equatable/equatable.dart';

abstract class MoodEntryFormEvent extends Equatable {
  const MoodEntryFormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMoodEntryForm extends MoodEntryFormEvent {}

class LoadMoodEntryForEdit extends MoodEntryFormEvent {
  final String id;

  const LoadMoodEntryForEdit(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateScaleValue extends MoodEntryFormEvent {
  final String scaleId;
  final int value;

  const UpdateScaleValue({
    required this.scaleId,
    required this.value,
  });

  @override
  List<Object?> get props => [scaleId, value];
}

class UpdateEntryDate extends MoodEntryFormEvent {
  final DateTime date;

  const UpdateEntryDate(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateComment extends MoodEntryFormEvent {
  final String comment;

  const UpdateComment(this.comment);

  @override
  List<Object?> get props => [comment];
}

class UpdateMedication extends MoodEntryFormEvent {
  final String medication;

  const UpdateMedication(this.medication);

  @override
  List<Object?> get props => [medication];
}

class UpdateSleepHours extends MoodEntryFormEvent {
  final double? hours;

  const UpdateSleepHours(this.hours);

  @override
  List<Object?> get props => [hours];
}

class SubmitMoodEntryForm extends MoodEntryFormEvent {}