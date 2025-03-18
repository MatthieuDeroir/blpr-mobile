import 'package:equatable/equatable.dart';

class ScaleWeight extends Equatable {
  final String scaleId;
  final String? scaleName;
  final double weight;
  final bool isInverted;

  const ScaleWeight({
    required this.scaleId,
    this.scaleName,
    required this.weight,
    required this.isInverted,
  });

  @override
  List<Object?> get props => [scaleId, scaleName, weight, isInverted];
}