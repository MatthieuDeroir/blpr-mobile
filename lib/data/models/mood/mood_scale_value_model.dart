// lib/data/models/mood/mood_scale_value_model.dart
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';

class MoodScaleValueModel extends MoodScaleValue {
  const MoodScaleValueModel({
    required super.scaleId,
    super.scaleName,
    required super.value,
    super.description,
  });

  factory MoodScaleValueModel.fromJson(Map<String, dynamic> json) {
    return MoodScaleValueModel(
      scaleId: json['scaleId'],
      scaleName: json['scaleName'],
      value: json['value'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scaleId': scaleId,
      'value': value,
    };
  }

  factory MoodScaleValueModel.fromEntity(MoodScaleValue scaleValue) {
    return MoodScaleValueModel(
      scaleId: scaleValue.scaleId,
      scaleName: scaleValue.scaleName,
      value: scaleValue.value,
      description: scaleValue.description,
    );
  }
}