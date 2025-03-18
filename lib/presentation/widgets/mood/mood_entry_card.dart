import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';

class MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MoodEntryCard({
    Key? key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get main scale (typically mood) for display
    final mainScale = _getMainScale();

    return Slidable(
      key: ValueKey(entry.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => Navigator.of(context).pushNamed(
              '/mood/edit',
              arguments: entry.id,
            ),
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
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
                      _formatDate(entry.entryDate),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (entry.stabilityScore != null)
                      _buildStabilityBadge(entry.stabilityScore!, entry.stabilityDescription),
                  ],
                ),
                const SizedBox(height: 12),

                // Main mood indicators
                if (mainScale != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mainScale.scaleName ?? 'Mood',
                              style: AppTextStyles.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            _buildMoodIndicator(mainScale),
                          ],
                        ),
                      ),
                      Icon(
                        _getMoodIcon(mainScale),
                        size: 32,
                        color: _getMoodColor(mainScale),
                      ),
                    ],
                  ),
                ],

                // Comment if available
                if (entry.comment != null && entry.comment!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    entry.comment!,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Sleep hours if available
                if (entry.sleepHours != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.bedtime_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sleep: ${entry.sleepHours!.toStringAsFixed(1)} hrs',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  MoodScaleValue? _getMainScale() {
    // Get mood scale if available (this will depend on your predefined scale IDs)
    // You might want to replace this with your actual implementation
    try {
      // Try to find mood scale first
      return entry.scaleValues.firstWhere(
            (value) => value.scaleName?.toLowerCase().contains('mood') ?? false,
      );
    } catch (_) {
      // If not found, just return the first scale value
      return entry.scaleValues.isNotEmpty ? entry.scaleValues.first : null;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == DateTime(now.year, now.month, now.day)) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (dateToCompare == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat('MMM d, yyyy, h:mm a').format(date);
    }
  }

  Widget _buildStabilityBadge(double score, String? description) {
    final color = _getStabilityColor(score);
    final text = description ?? _getStabilityText(score);

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

  Widget _buildMoodIndicator(MoodScaleValue scale) {
    // This is a simplified version - ideally, you would want to use the scale's min/max values
    const totalDots = 13;
    const minValue = 0;

    return Row(
      children: List.generate(
        totalDots + 1,
            (index) {
          final isActive = index <= (scale.value - minValue);
          return Container(
            width: index == 0 || index == totalDots ? 6 : 12,
            height: 8,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: isActive ? _getMoodColor(scale) : Colors.grey.withOpacity(0.2),
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

  Color _getMoodColor(MoodScaleValue scale) {
    // Ideally this should use scale.value, minValue and maxValue
    // This is a simplified version assuming scale 0-13
    final normalizedValue = scale.value / 13;

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

  IconData _getMoodIcon(MoodScaleValue scale) {
    // Simplified version assuming scale 0-13
    final normalizedValue = scale.value / 13;

    if (normalizedValue < 0.3) {
      return Icons.sentiment_very_dissatisfied;
    } else if (normalizedValue < 0.45) {
      return Icons.sentiment_dissatisfied;
    } else if (normalizedValue < 0.55) {
      return Icons.sentiment_neutral;
    } else if (normalizedValue < 0.75) {
      return Icons.sentiment_satisfied;
    } else if (normalizedValue < 0.9) {
      return Icons.sentiment_very_satisfied;
    } else {
      return Icons.mood;
    }
  }
}