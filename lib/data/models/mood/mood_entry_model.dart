// lib/data/models/mood/mood_entry_model.dart
import 'package:mood_tracker/data/models/mood/mood_scale_value_model.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';

class MoodEntryModel extends MoodEntry {
  const MoodEntryModel({
    required super.id,
    required super.userId,
    required super.entryDate,
    super.comment,
    super.medication,
    super.sleepHours,
    super.stabilityScore,
    super.stabilityDescription,
    required super.scaleValues,
  });

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) {
    return MoodEntryModel(
      id: json['id'],
      userId: json['userId'],
      entryDate: DateTime.parse(json['entryDate']),
      comment: json['comment'],
      medication: json['medication'],
      sleepHours: json['sleepHours']?.toDouble(),
      stabilityScore: json['stabilityScore']?.toDouble(),
      stabilityDescription: json['stabilityDescription'],
      scaleValues: (json['scaleValues'] as List<dynamic>?)
          ?.map((value) => MoodScaleValueModel.fromJson(value))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entryDate': entryDate.toIso8601String(),
      'comment': comment,
      'medication': medication,
      'sleepHours': sleepHours,
      'scaleValues': scaleValues
          .map((value) => (value as MoodScaleValueModel).toJson())
          .toList(),
    };
  }

  factory MoodEntryModel.fromEntity(MoodEntry entry) {
    return MoodEntryModel(
      id: entry.id,
      userId: entry.userId,
      entryDate: entry.entryDate,
      comment: entry.comment,
      medication: entry.medication,
      sleepHours: entry.sleepHours,
      stabilityScore: entry.stabilityScore,
      stabilityDescription: entry.stabilityDescription,
      scaleValues: entry.scaleValues,
    );
  }
}