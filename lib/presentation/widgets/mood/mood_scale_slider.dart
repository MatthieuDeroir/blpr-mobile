import 'package:flutter/material.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';

class MoodScaleSlider extends StatelessWidget {
  final String name;
  final String description;
  final int minValue;
  final int maxValue;
  final int value;
  final Function(int) onChanged;

  const MoodScaleSlider({
    Key? key,
    required this.name,
    required this.description,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scale name and value display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getValueColor(value),
                shape: BoxShape.circle,
              ),
              child: Text(
                value.toString(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Slider
        Row(
          children: [
            // Min label
            SizedBox(
              width: 28,
              child: Text(
                minValue.toString(),
                style: AppTextStyles.labelSmall,
                textAlign: TextAlign.center,
              ),
            ),

            // Slider
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getValueColor(value),
                  inactiveTrackColor: Colors.grey.shade200,
                  thumbColor: _getValueColor(value),
                  overlayColor: _getValueColor(value).withOpacity(0.2),
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  min: minValue.toDouble(),
                  max: maxValue.toDouble(),
                  value: value.toDouble(),
                  divisions: maxValue - minValue,
                  onChanged: (newValue) {
                    onChanged(newValue.round());
                  },
                ),
              ),
            ),

            // Max label
            SizedBox(
              width: 28,
              child: Text(
                maxValue.toString(),
                style: AppTextStyles.labelSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        // Level description
        Text(
          _getLevelDescription(value),
          style: AppTextStyles.bodySmall.copyWith(
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getLevelDescription(int value) {
    // TODO: Replace with actual descriptions from the backend
    // This is a simplified version for now
    final totalLevels = maxValue - minValue + 1;
    final normalizedValue = (value - minValue) / (totalLevels - 1);

    if (normalizedValue < 0.15) {
      return "Very low/depressed";
    } else if (normalizedValue < 0.3) {
      return "Low";
    } else if (normalizedValue < 0.45) {
      return "Slightly below average";
    } else if (normalizedValue < 0.55) {
      return "Average/neutral";
    } else if (normalizedValue < 0.7) {
      return "Slightly above average";
    } else if (normalizedValue < 0.85) {
      return "High";
    } else if (normalizedValue < 0.95) {
      return "Very high/positive";
    } else {
      return "Extreme/manic";
    }
  }

  Color _getValueColor(int value) {
    // Maps the value to a color
    final totalLevels = maxValue - minValue + 1;
    final normalizedValue = (value - minValue) / (totalLevels - 1);

    if (normalizedValue < 0.15) {
      return AppColors.moodDepressionDark;
    } else if (normalizedValue < 0.3) {
      return AppColors.moodDepressionMedium;
    } else if (normalizedValue < 0.45) {
      return AppColors.moodDepressionLight;
    } else if (normalizedValue < 0.55) {
      return AppColors.moodNeutral;
    } else if (normalizedValue < 0.7) {
      return AppColors.moodPositiveLight;
    } else if (normalizedValue < 0.85) {
      return AppColors.moodPositiveMedium;
    } else if (normalizedValue < 0.95) {
      return AppColors.moodPositiveHigh;
    } else {
      return AppColors.moodManic;
    }
  }
}