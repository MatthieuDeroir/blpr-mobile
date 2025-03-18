import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/stability_formula.dart';

abstract class FormulaState extends Equatable {
  const FormulaState();

  @override
  List<Object?> get props => [];
}

class FormulaInitial extends FormulaState {}

class FormulaLoading extends FormulaState {}

class FormulasLoaded extends FormulaState {
  final List<StabilityFormula> formulas;
  final StabilityFormula? activeFormula;

  const FormulasLoaded({
    required this.formulas,
    this.activeFormula,
  });

  @override
  List<Object?> get props => [formulas, activeFormula];
}

class ActiveFormulaLoaded extends FormulaState {
  final StabilityFormula formula;

  const ActiveFormulaLoaded(this.formula);

  @override
  List<Object?> get props => [formula];
}

class FormulaError extends FormulaState {
  final String message;

  const FormulaError(this.message);

  @override
  List<Object?> get props => [message];
}