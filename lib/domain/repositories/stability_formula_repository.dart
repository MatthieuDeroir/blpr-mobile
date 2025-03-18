import 'package:dartz/dartz.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/stability_formula.dart';

abstract class StabilityFormulaRepository {
  /// Get all stability formulas for the current user
  Future<Either<Failure, List<StabilityFormula>>> getAllFormulas();

  /// Get the currently active formula
  Future<Either<Failure, StabilityFormula>> getActiveFormula();

  /// Get a specific formula by ID
  Future<Either<Failure, StabilityFormula>> getFormulaById(String id);

  /// Create a new formula
  Future<Either<Failure, StabilityFormula>> createFormula({
    required String description,
    required bool isActive,
    required List<Map<String, dynamic>> scaleWeights,
  });

  /// Update an existing formula
  Future<Either<Failure, StabilityFormula>> updateFormula({
    required String id,
    String? description,
    bool? isActive,
    List<Map<String, dynamic>>? scaleWeights,
  });

  /// Delete a formula
  Future<Either<Failure, bool>> deleteFormula(String id);
}