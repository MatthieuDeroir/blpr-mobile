import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/scale_level.dart';

class Scale extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool isDefault;
  final String? userId;
  final int minValue;
  final int maxValue;
  final bool isActive;
  final List<ScaleLevel> levels;

  const Scale({
    required this.id,
    required this.name,
    required this.description,
    required this.isDefault,
    this.userId,
    required this.minValue,
    required this.maxValue,
    required this.isActive,
    required this.levels,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    isDefault,
    userId,
    minValue,
    maxValue,
    isActive,
    levels,
  ];
}