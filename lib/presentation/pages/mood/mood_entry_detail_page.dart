import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';

class MoodEntryDetailPage extends StatefulWidget {
  final String id;

  const MoodEntryDetailPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<MoodEntryDetailPage> createState() => _MoodEntryDetailPageState();
}

class _MoodEntryDetailPageState extends State<MoodEntryDetailPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _entry;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load from MoodEntry bloc
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data for now
    _entry = {
      'id': widget.id,
      'date': 'March 17, 2025 10:30 AM',
      'stabilityScore': 75.0,
      'stabilityDescription': 'Good Stability',
      'comment': 'Feeling pretty good today, work went well. Had a productive meeting in the morning and was able to complete several tasks on my to-do list. Took a short walk during lunch which helped with energy levels.',
      'medication': 'Morning medication as prescribed',
      'sleepHours': 7.5,
      'scaleValues': [
        {
          'scaleId': AppConstants.humeurScaleId,
          'scaleName': 'Mood (Humeur)',
          'value': 8,
          'description': 'Humeur positive : bonne énergie, optimisme modéré, on se sent assez bien.',
        },
        {
          'scaleId': AppConstants.irritabiliteScaleId,
          'scaleName': 'Irritability (Irritabilité)',
          'value': 3,
          'description': 'Irritabilité modérée : on se sent facilement agacé, tension notable, mais pas d\'explosion.',
        },
        {
          'scaleId': AppConstants.confianceScaleId,
          'scaleName': 'Confidence (Confiance)',
          'value': 7,
          'description': 'Confiance moyenne : on se sent plutôt à l\'aise, tout en restant conscient de ses limites.',
        },
        {
          'scaleId': AppConstants.extraversionScaleId,
          'scaleName': 'Extraversion',
          'value': 6,
          'description': 'Légère préférence pour la solitude : on ne fuit pas la compagnie, mais on n\'en a pas un grand besoin.',
        },
        {
          'scaleId': AppConstants.bienEtreScaleId,
          'scaleName': 'Well-being (Bien-être)',
          'value': 8,
          'description': 'Bien-être modéré : on se sent plutôt serein, la nervosité est occasionnelle.',
        },
      ],
    };

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteEntry() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // TODO: Delete via bloc
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Navigate back
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Entry Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed('/mood/add', arguments: widget.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEntry,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _entry == null
          ? _buildErrorState()
          : _buildEntryDetails(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Entry not found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'The requested mood entry could not be loaded',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and stability score
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: AppTextStyles.labelLarge,
                          ),
                          Text(
                            _entry!['date'],
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildStabilityBadge(
                        _entry!['stabilityScore'],
                        _entry!['stabilityDescription'],
                      ),
                    ],
                  ),
                  if (_entry!['sleepHours'] != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.bedtime_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sleep: ${_entry!['sleepHours']} hours',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Scale values
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood Assessment',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  ..._entry!['scaleValues'].map<Widget>((scale) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildScaleValueItem(
                        scale['scaleName'],
                        scale['value'],
                        scale['description'],
                        minValue: 0,
                        maxValue: 13,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Additional info
          if (_entry!['comment']?.isNotEmpty == true ||
              _entry!['medication']?.isNotEmpty == true) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    if (_entry!['medication']?.isNotEmpty == true) ...[
                      Text(
                        'Medication',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _entry!['medication'],
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_entry!['comment']?.isNotEmpty == true) ...[
                      Text(
                        'Comments',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _entry!['comment'],
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Actions
          SizedBox(
            width: double.infinity,
            child: Slidable(
              key: const ValueKey('delete-actions'),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      Navigator.of(context).pushNamed(
                        '/mood/add',
                        arguments: widget.id,
                      );
                    },
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
                    onPressed: (_) => _deleteEntry(),
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
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.swipe_left_outlined,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Swipe left for actions',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStabilityBadge(double score, String description) {
    final color = _getStabilityColor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.crisis_alert,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '${score.toInt()}%',
                style: AppTextStyles.heading4.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            description,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleValueItem(
      String name,
      int value,
      String description, {
        required int minValue,
        required int maxValue,
      }) {
    final totalLevels = maxValue - minValue + 1;
    final normalizedValue = (value - minValue) / (totalLevels - 1);
    final color = _getValueColor(normalizedValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scale name and value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
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

        // Value bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: normalizedValue,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),

        // Min/max labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minValue.toString(),
              style: AppTextStyles.labelSmall,
            ),
            Text(
              maxValue.toString(),
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
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

  Color _getValueColor(double normalizedValue) {
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