import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/scale.dart';
import 'package:mood_tracker/domain/repositories/scale_repository.dart';

class GetScale {
  final ScaleRepository repository;

  GetScale(this.repository);

  Future<Either<Failure, Scale>> call(GetScaleParams params) {
    return repository.getScaleById(params.id);
  }
}

class GetScaleParams extends Equatable {
  final String id;

  const GetScaleParams({required this.id});

  @override
  List<Object?> get props => [id];
}