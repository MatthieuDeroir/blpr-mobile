import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/stability_formula.dart';
import 'package:mood_tracker/domain/repositories/stability_formula_repository.dart';

class GetActiveFormula {
  final StabilityFormulaRepository repository;

  GetActiveFormula(this.repository);

  Future<Either<Failure, StabilityFormula>> call(GetActiveFormulaParams params) {
    return repository.getActiveFormula();
  }
}

class GetActiveFormulaParams extends Equatable {
  const GetActiveFormulaParams();

  @override
  List<Object?> get props => [];
}