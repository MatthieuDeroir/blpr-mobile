import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/stability_formula.dart';
import 'package:mood_tracker/domain/repositories/stability_formula_repository.dart';

class UpdateFormula {
  final StabilityFormulaRepository repository;

  UpdateFormula(this.repository);

  Future<Either<Failure, StabilityFormula>> call(UpdateFormulaParams params) {
    return repository.updateFormula(
      id: params.id,
      description: params.description,
      isActive: params.isActive,
      scaleWeights: params.scaleWeights,
    );
  }
}

class UpdateFormulaParams extends Equatable {
  final String id;
  final String? description;
  final bool? isActive;
  final List<Map<String, dynamic>>? scaleWeights;

  const UpdateFormulaParams({
    required this.id,
    this.description,
    this.isActive,
    this.scaleWeights,
  });

  @override
  List<Object?> get props => [id, description, isActive, scaleWeights];
}