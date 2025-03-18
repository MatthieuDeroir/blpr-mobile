import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';

class ScaleCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final int minValue;
  final int maxValue;
  final bool isActive;
  final bool isDefault;
  final bool isEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ScaleCard({
    Key? key,
    required this.id,
    required this.name,
    required this.description,
    required this.minValue,
    required this.maxValue,
    required this.isActive,
    required this.isDefault,
    this.isEditable = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/scale/$id');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and badges
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.heading4,
                    ),
                  ),
                  if (isDefault)
                    _buildBadge(
                      text: 'Default',
                      color: AppColors.info,
                      icon: Icons.verified,
                    ),
                  if (!isActive)
                    _buildBadge(
                      text: 'Inactive',
                      color: AppColors.textSecondary,
                      icon: Icons.visibility_off,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Scale range
              Row(
                children: [
                  Text(
                    'Range: $minValue-$maxValue',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildScaleRangeIndicator(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // If not editable, just return the card
    if (!isEditable) {
      return card;
    }

    // If editable, wrap in Slidable
    return Slidable(
      key: ValueKey(id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
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
            onPressed: (_) => onDelete?.call(),
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
      child: card,
    );
  }

  Widget _buildBadge({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleRangeIndicator() {
    // Create a visual representation of the scale range
    final levels = maxValue - minValue + 1;
    final stepWidth = 1.0 / levels;

    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: List.generate(
            levels,
                (index) {
              // Calculate color based on position in the range
              final position = index / (levels - 1);
              final color = _getColorForPosition(position);

              return Expanded(
                child: Container(
                  color: color,
                  height: 8,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getColorForPosition(double position) {
    // Returns a color from the mood gradient based on position (0.0 to 1.0)
    if (position < 0.15) {
      return AppColors.moodDepressionDark;
    } else if (position < 0.3) {
      return AppColors.moodDepressionMedium;
    } else if (position < 0.45) {
      return AppColors.moodDepressionLight;
    } else if (position < 0.55) {
      return AppColors.moodNeutral;
    } else if (position < 0.7) {
      return AppColors.moodPositiveLight;
    } else if (position < 0.85) {
      return AppColors.moodPositiveMedium;
    } else if (position < 0.95) {
      return AppColors.moodPositiveHigh;
    } else {
      return AppColors.moodManic;
    }
  }
}