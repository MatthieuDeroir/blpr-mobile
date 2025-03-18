import 'package:dartz/dartz.dart';
import 'package:mood_tracker/core/error/failures.dart';
import 'package:mood_tracker/domain/entities/scale.dart';

abstract class ScaleRepository {
  /// Get all scales (both system defaults and user-created)
  Future<Either<Failure, List<Scale>>> getAllScales();

  /// Get a specific scale by ID
  Future<Either<Failure, Scale>> getScaleById(String id);

  /// Create a new custom scale
  Future<Either<Failure, Scale>> createScale({
    required String name,
    required String description,
    required int minValue,
    required int maxValue,
    required bool isActive,
    required List<Map<String, dynamic>> levels,
  });

  /// Update an existing scale
  Future<Either<Failure, Scale>> updateScale({
    required String id,
    String? name,
    String? description,
    bool? isActive,
    List<Map<String, dynamic>>? levels,
  });

  /// Delete a scale
  Future<Either<Failure, bool>> deleteScale(String id);
}