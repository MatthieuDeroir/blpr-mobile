import 'package:equatable/equatable.dart';

abstract class FormulaEvent extends Equatable {
  const FormulaEvent();

  @override
  List<Object?> get props => [];
}

class LoadFormulas extends FormulaEvent {
  const LoadFormulas();
}

class LoadActiveFormula extends FormulaEvent {
  const LoadActiveFormula();
}

class CreateFormulaEvent extends FormulaEvent {
  final String description;
  final bool isActive;
  final List<Map<String, dynamic>> scaleWeights;

  const CreateFormulaEvent({
    required this.description,
    required this.isActive,
    required this.scaleWeights,
  });

  @override
  List<Object?> get props => [description, isActive, scaleWeights];
}

class UpdateFormulaEvent extends FormulaEvent {
  final String id;
  final String? description;
  final bool? isActive;
  final List<Map<String, dynamic>>? scaleWeights;

  const UpdateFormulaEvent({
    required this.id,
    this.description,
    this.isActive,
    this.scaleWeights,
  });

  @override
  List<Object?> get props => [id, description, isActive, scaleWeights];
}

class SetActiveFormula extends FormulaEvent {
  final String id;

  const SetActiveFormula({required this.id});

  @override
  List<Object?> get props => [id];
}