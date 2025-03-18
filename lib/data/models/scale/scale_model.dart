import 'package:mood_tracker/data/models/scale/scale_level_model.dart';
import 'package:mood_tracker/domain/entities/scale.dart';

class ScaleModel extends Scale {
  const ScaleModel({
    required super.id,
    required super.name,
    required super.description,
    required super.isDefault,
    super.userId,
    required super.minValue,
    required super.maxValue,
    required super.isActive,
    required super.levels,
  });

  factory ScaleModel.fromJson(Map<String, dynamic> json) {
    return ScaleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      isDefault: json['isDefault'] ?? false,
      userId: json['userId'],
      minValue: json['minValue'],
      maxValue: json['maxValue'],
      isActive: json['isActive'] ?? true,
      levels: (json['levels'] as List<dynamic>?)
          ?.map((level) => ScaleLevelModel.fromJson(level))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isDefault': isDefault,
      'userId': userId,
      'minValue': minValue,
      'maxValue': maxValue,
      'isActive': isActive,
      'levels': levels.map((level) => (level as ScaleLevelModel).toJson()).toList(),
    };
  }

  factory ScaleModel.fromEntity(Scale scale) {
    return ScaleModel(
      id: scale.id,
      name: scale.name,
      description: scale.description,
      isDefault: scale.isDefault,
      userId: scale.userId,
      minValue: scale.minValue,
      maxValue: scale.maxValue,
      isActive: scale.isActive,
      levels: scale.levels,
    );
  }
}