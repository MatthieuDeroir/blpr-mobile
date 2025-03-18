import 'package:flutter/material.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';

class MoodEntryCard extends StatelessWidget {
  final String id;
  final String date;
  final double stabilityScore;
  final String mainScale;
  final int mainScaleValue;
  final String? comment;

  const MoodEntryCard({
    Key? key,
    required this.id,
    required this.date,
    required this.stabilityScore,
    required this.mainScale,
    required this.mainScaleValue,
    this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/mood/$id');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and stability score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  _buildStabilityBadge(stabilityScore),
                ],
              ),
              const SizedBox(height: 12),

              // Main mood indicators
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mainScale,
                          style: AppTextStyles.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        _buildMoodIndicator(mainScaleValue),
                      ],
                    ),
                  ),
                  Icon(
                    _getMoodIcon(mainScaleValue),
                    size: 32,
                    color: _getMoodColor(mainScaleValue),
                  ),
                ],
              ),

              // Comment if available
              if (comment != null && comment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  comment!,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStabilityBadge(double score) {
    final color = _getStabilityColor(score);
    final text = _getStabilityText(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.crisis_alert,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$text (${score.toInt()})',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIndicator(int value) {
    // Assuming scale is 0-13 as in the backend
    const totalDots = 13;

    return Row(
      children: List.generate(
        totalDots + 1,
            (index) {
          final isActive = index <= value;
          return Container(
            width: index == 0 || index == totalDots ? 6 : 12,
            height: 8,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: isActive ? _getMoodColor(value) : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }

  Color _getStabilityColor(double score) {
    if (score < 20) {
      return Colors.red;
    } else if (score < 35) {
      return Colors.deepOrange;
    } else if (score < 50) {
      return Colors.orange;
    } else if (score < 65) {
      return Colors.amber;
    } else if (score < 80) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }

  String _getStabilityText(double score) {
    if (score < 20) {
      return "Severe Crisis";
    } else if (score < 35) {
      return "Major Instability";
    } else if (score < 50) {
      return "Moderately Unstable";
    } else if (score < 65) {
      return "Slightly Unstable";
    } else if (score < 80) {
      return "Average Stability";
    } else {
      return "Good Stability";
    }
  }

  Color _getMoodColor(int value) {
    // Assuming scale is 0-13 as in the backend
    final totalLevels = 13;

    if (value <= totalLevels / 3) {
      return AppColors.moodDepressionMedium;
    } else if (value <= 2 * totalLevels / 3) {
      return AppColors.moodNeutral;
    } else if (value <= totalLevels - 1) {
      return AppColors.moodPositiveMedium;
    } else {
      return AppColors.moodManic;
    }
  }

  IconData _getMoodIcon(int value) {
    // Assuming scale is 0-13 as in the backend
    final totalLevels = 13;

    if (value <= totalLevels / 3) {
      return Icons.sentiment_very_dissatisfied;
    } else if (value <= 2 * totalLevels / 3) {
      return Icons.sentiment_neutral;
    } else if (value <= totalLevels - 1) {
      return Icons.sentiment_satisfied;
    } else {
      return Icons.mood;
    }
  }
}