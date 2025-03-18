import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/stability_formula.dart';
import 'package:mood_tracker/domain/repositories/stability_formula_repository.dart';

class CreateFormula {
  final StabilityFormulaRepository repository;

  CreateFormula(this.repository);

  Future<Either<Failure, StabilityFormula>> call(CreateFormulaParams params) {
    return repository.createFormula(
      description: params.description,
      isActive: params.isActive,
      scaleWeights: params.scaleWeights,
    );
  }
}

class CreateFormulaParams extends Equatable {
  final String description;
  final bool isActive;
  final List<Map<String, dynamic>> scaleWeights;

  const CreateFormulaParams({
    required this.description,
    required this.isActive,
    required this.scaleWeights,
  });

  @override
  List<Object?> get props => [description, isActive, scaleWeights];
}