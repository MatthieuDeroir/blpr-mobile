import 'package:equatable/equatable.dart';

class ScaleLevel extends Equatable {
  final String id;
  final String scaleId;
  final int level;
  final String description;

  const ScaleLevel({
    required this.id,
    required this.scaleId,
    required this.level,
    required this.description,
  });

  @override
  List<Object?> get props => [id, scaleId, level, description];
}