import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/scale_weight.dart';

class StabilityFormula extends Equatable {
  final String id;
  final String? userId;
  final String formula;
  final String description;
  final bool isDefault;
  final bool isActive;
  final List<ScaleWeight> scaleWeights;

  const StabilityFormula({
    required this.id,
    this.userId,
    required this.formula,
    required this.description,
    required this.isDefault,
    required this.isActive,
    required this.scaleWeights,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    formula,
    description,
    isDefault,
    isActive,
    scaleWeights,
  ];
}