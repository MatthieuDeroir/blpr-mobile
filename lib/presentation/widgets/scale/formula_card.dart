import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';

class FormulaCard extends StatelessWidget {
  final String id;
  final String description;
  final bool isDefault;
  final bool isActive;
  final List<Map<String, dynamic>> scaleWeights;
  final VoidCallback? onSetActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FormulaCard({
    Key? key,
    required this.id,
    required this.description,
    required this.isDefault,
    required this.isActive,
    required this.scaleWeights,
    this.onSetActive,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with description and badges
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withOpacity(0.1) : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isDefault ? 'Default Formula' : 'Custom Formula',
                              style: AppTextStyles.labelMedium,
                            ),
                          ),
                          if (isDefault)
                            _buildBadge(
                              text: 'Default',
                              color: AppColors.info,
                              icon: Icons.verified,
                            ),
                          if (isActive)
                            _buildBadge(
                              text: 'Active',
                              color: AppColors.success,
                              icon: Icons.check_circle,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scale weights
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scale Weights',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8),
                ...scaleWeights.map(_buildWeightItem).toList(),
              ],
            ),
          ),

          // Actions
          if (!isActive || !isDefault)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isActive)
                    TextButton.icon(
                      onPressed: onSetActive,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Set Active'),
                    ),
                  if (!isDefault && onEdit != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );

    // For default formulas or if delete is not allowed, just return the card
    if (isDefault || onDelete == null) {
      return card;
    }

    // For custom formulas, wrap in Slidable
    return Slidable(
      key: ValueKey(id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (!isActive)
            SlidableAction(
              onPressed: (_) => onSetActive?.call(),
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: 'Set Active',
            ),
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
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

  Widget _buildWeightItem(Map<String, dynamic> weight) {
    final scaleName = weight['scaleName'] as String;
    final weightValue = weight['weight'] as double;
    final isInverted = weight['isInverted'] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Scale name
          Expanded(
            flex: 3,
            child: Text(
              scaleName,
              style: AppTextStyles.bodyMedium,
            ),
          ),

          // Weight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Weight: ${weightValue.toStringAsFixed(1)}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Inverted status
          if (isInverted) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swap_vert,
                    size: 14,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Inverted',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}