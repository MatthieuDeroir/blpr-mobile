import 'package:equatable/equatable.dart';
import 'package:mood_tracker/domain/entities/scale.dart';

abstract class ScalesState extends Equatable {
  const ScalesState();

  @override
  List<Object?> get props => [];
}

class ScalesInitial extends ScalesState {}

class ScalesLoading extends ScalesState {}

class ScalesLoaded extends ScalesState {
  final List<Scale> scales;
  final List<Scale> defaultScales;
  final List<Scale> customScales;
  final String? nameFilter;
  final bool activeOnly;

  const ScalesLoaded({
    required this.scales,
    required this.defaultScales,
    required this.customScales,
    this.nameFilter,
    this.activeOnly = false,
  });

  @override
  List<Object?> get props => [
    scales,
    defaultScales,
    customScales,
    nameFilter,
    activeOnly,
  ];
}

class ScalesError extends ScalesState {
  final String message;

  const ScalesError(this.message);

  @override
  List<Object?> get props => [message];
}