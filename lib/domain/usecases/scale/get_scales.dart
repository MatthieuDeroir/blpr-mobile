import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/scale.dart';
import 'package:mood_tracker/domain/repositories/scale_repository.dart';

class GetScales {
  final ScaleRepository repository;

  GetScales(this.repository);

  Future<Either<Failure, List<Scale>>> call(GetScalesParams params) {
    return repository.getAllScales();
  }
}

class GetScalesParams extends Equatable {
  const GetScalesParams();

  @override
  List<Object?> get props => [];
}