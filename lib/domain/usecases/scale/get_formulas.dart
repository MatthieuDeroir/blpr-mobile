import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/stability_formula.dart';
import 'package:mood_tracker/domain/repositories/stability_formula_repository.dart';

class GetFormulas {
  final StabilityFormulaRepository repository;

  GetFormulas(this.repository);

  Future<Either<Failure, List<StabilityFormula>>> call(GetFormulasParams params) {
    return repository.getAllFormulas();
  }
}

class GetFormulasParams extends Equatable {
  const GetFormulasParams();

  @override
  List<Object?> get props => [];
}