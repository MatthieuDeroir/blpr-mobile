// lib/domain/entities/mood_scale_value.dart
import 'package:equatable/equatable.dart';

class MoodScaleValue extends Equatable {
  final String scaleId;
  final String? scaleName;
  final int value;
  final String? description;

  const MoodScaleValue({
    required this.scaleId,
    this.scaleName,
    required this.value,
    this.description,
  });

  @override
  List<Object?> get props => [scaleId, scaleName, value, description];
}