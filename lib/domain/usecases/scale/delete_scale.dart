// lib/domain/usecases/scale/delete_scale.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/repositories/scale_repository.dart';

class DeleteScale {
  final ScaleRepository repository;

  DeleteScale(this.repository);

  Future<Either<Failure, bool>> call(DeleteScaleParams params) {
    return repository.deleteScale(params.id);
  }
}

class DeleteScaleParams extends Equatable {
  final String id;

  const DeleteScaleParams({required this.id});

  @override
  List<Object?> get props => [id];
}