// lib/data/models/scale/scale_weight_model.dart
import 'package:mood_tracker/domain/entities/scale_weight.dart';

class ScaleWeightModel extends ScaleWeight {
  const ScaleWeightModel({
    required super.scaleId,
    super.scaleName,
    required super.weight,
    required super.isInverted,
  });

  factory ScaleWeightModel.fromJson(Map<String, dynamic> json) {
    return ScaleWeightModel(
      scaleId: json['scaleId'],
      scaleName: json['scaleName'],
      weight: (json['weight'] as num).toDouble(),
      isInverted: json['isInverted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scaleId': scaleId,
      'scaleName': scaleName,
      'weight': weight,
      'isInverted': isInverted,
    };
  }

  factory ScaleWeightModel.fromEntity(ScaleWeight scaleWeight) {
    return ScaleWeightModel(
      scaleId: scaleWeight.scaleId,
      scaleName: scaleWeight.scaleName,
      weight: scaleWeight.weight,
      isInverted: scaleWeight.isInverted,
    );
  }
}