// lib/domain/usecases/scale/update_scale.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/scale.dart';
import 'package:mood_tracker/domain/repositories/scale_repository.dart';

class UpdateScale {
  final ScaleRepository repository;

  UpdateScale(this.repository);

  Future<Either<Failure, Scale>> call(UpdateScaleParams params) {
    return repository.updateScale(
      id: params.id,
      name: params.name,
      description: params.description,
      isActive: params.isActive,
      levels: params.levels,
    );
  }
}

class UpdateScaleParams extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final bool? isActive;
  final List<Map<String, dynamic>>? levels;

  const UpdateScaleParams({
    required this.id,
    this.name,
    this.description,
    this.isActive,
    this.levels,
  });

  @override
  List<Object?> get props => [id, name, description, isActive, levels];
}