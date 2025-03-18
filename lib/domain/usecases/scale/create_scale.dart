// lib/domain/usecases/scale/create_scale.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/scale.dart';
import 'package:mood_tracker/domain/repositories/scale_repository.dart';

class CreateScale {
  final ScaleRepository repository;

  CreateScale(this.repository);

  Future<Either<Failure, Scale>> call(CreateScaleParams params) {
    return repository.createScale(
      name: params.name,
      description: params.description,
      minValue: params.minValue,
      maxValue: params.maxValue,
      isActive: params.isActive,
      levels: params.levels,
    );
  }
}

class CreateScaleParams extends Equatable {
  final String name;
  final String description;
  final int minValue;
  final int maxValue;
  final bool isActive;
  final List<Map<String, dynamic>> levels;

  const CreateScaleParams({
    required this.name,
    required this.description,
    required this.minValue,
    required this.maxValue,
    required this.isActive,
    required this.levels,
  });

  @override
  List<Object?> get props => [name, description, minValue, maxValue, isActive, levels];
}