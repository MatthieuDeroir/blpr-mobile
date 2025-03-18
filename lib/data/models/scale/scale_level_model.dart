import 'package:mood_tracker/domain/entities/scale_level.dart';

class ScaleLevelModel extends ScaleLevel {
  const ScaleLevelModel({
    required super.id,
    required super.scaleId,
    required super.level,
    required super.description,
  });

  factory ScaleLevelModel.fromJson(Map<String, dynamic> json) {
    return ScaleLevelModel(
      id: json['id'] ?? '',
      scaleId: json['scaleId'] ?? '',
      level: json['level'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scaleId': scaleId,
      'level': level,
      'description': description,
    };
  }

  factory ScaleLevelModel.fromEntity(ScaleLevel scaleLevel) {
    return ScaleLevelModel(
      id: scaleLevel.id,
      scaleId: scaleLevel.scaleId,
      level: scaleLevel.level,
      description: scaleLevel.description,
    );
  }
}