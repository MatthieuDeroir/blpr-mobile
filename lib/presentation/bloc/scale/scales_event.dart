import 'package:equatable/equatable.dart';

abstract class ScalesEvent extends Equatable {
  const ScalesEvent();

  @override
  List<Object?> get props => [];
}

class LoadScales extends ScalesEvent {
  final bool activeOnly;

  const LoadScales({this.activeOnly = false});

  @override
  List<Object?> get props => [activeOnly];
}

class CreateScaleEvent extends ScalesEvent {
  final String name;
  final String description;
  final int minValue;
  final int maxValue;
  final bool isActive;
  final List<Map<String, dynamic>> levels;

  const CreateScaleEvent({
    required this.name,
    required this.description,
    required this.minValue,
    required this.maxValue,
    required this.isActive,
    required this.levels,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    minValue,
    maxValue,
    isActive,
    levels,
  ];
}

class UpdateScaleEvent extends ScalesEvent {
  final String id;
  final String? name;
  final String? description;
  final bool? isActive;
  final List<Map<String, dynamic>>? levels;

  const UpdateScaleEvent({
    required this.id,
    this.name,
    this.description,
    this.isActive,
    this.levels,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    isActive,
    levels,
  ];
}

class DeleteScaleEvent extends ScalesEvent {
  final String id;

  const DeleteScaleEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class FilterScales extends ScalesEvent {
  final String? nameFilter;
  final bool activeOnly;

  const FilterScales({
    this.nameFilter,
    this.activeOnly = false,
  });

  @override
  List<Object?> get props => [nameFilter, activeOnly];
}