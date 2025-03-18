// lib/data/models/scale/stability_formula_model.dart
import 'package:mood_tracker/data/models/scale/scale_weight_model.dart';
import 'package:mood_tracker/domain/entities/stability_formula.dart';

class StabilityFormulaModel extends StabilityFormula {
  const StabilityFormulaModel({
    required super.id,
    super.userId,
    required super.formula,
    required super.description,
    required super.isDefault,
    required super.isActive,
    required super.scaleWeights,
  });

  factory StabilityFormulaModel.fromJson(Map<String, dynamic> json) {
    return StabilityFormulaModel(
      id: json['id'],
      userId: json['userId'],
      formula: json['formula'],
      description: json['description'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? false,
      scaleWeights: (json['scaleWeights'] as List<dynamic>?)
          ?.map((weight) => ScaleWeightModel.fromJson(weight))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'formula': formula,
      'description': description,
      'isDefault': isDefault,
      'isActive': isActive,
      'scaleWeights': scaleWeights.map((weight) => (weight as ScaleWeightModel).toJson()).toList(),
    };
  }

  factory StabilityFormulaModel.fromEntity(StabilityFormula formula) {
    return StabilityFormulaModel(
      id: formula.id,
      userId: formula.userId,
      formula: formula.formula,
      description: formula.description,
      isDefault: formula.isDefault,
      isActive: formula.isActive,
      scaleWeights: formula.scaleWeights,
    );
  }
}