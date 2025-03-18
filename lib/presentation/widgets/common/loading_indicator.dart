import 'package:flutter/material.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const LoadingIndicator({
    Key? key,
    this.size = 48.0,
    this.color = AppColors.primary,
    this.strokeWidth = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}