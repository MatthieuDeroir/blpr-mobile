import 'package:flutter/material.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';

class ScaleDetailPage extends StatefulWidget {
  final String id;

  const ScaleDetailPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<ScaleDetailPage> createState() => _ScaleDetailPageState();
}

class _ScaleDetailPageState extends State<ScaleDetailPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _scale;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _loadScale();
  }

  Future<void> _loadScale() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load from Scale bloc
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if this is a default scale or a custom one
    final isDefaultScale = [
      AppConstants.humeurScaleId,
      AppConstants.irritabiliteScaleId,
      AppConstants.confianceScaleId,
      AppConstants.extraversionScaleId,
      AppConstants.bienEtreScaleId,
    ].contains(widget.id);

    // Set editability
    _isEditable = !isDefaultScale;

    // Mock data for Mood scale
    if (widget.id == AppConstants.humeurScaleId) {
      _scale = {
        'id': AppConstants.humeurScaleId,
        'name': 'Mood (Humeur)',
        'description': 'Scale for measuring mood between depression and mania',
        'isDefault': true,
        'minValue': 0,
        'maxValue': 13,
        'isActive': true,
        'levels': [
          {'level': 0, 'description': 'Détresse absolue : désespoir intense, idées suicidaires ou grande souffrance psychique.'},
          {'level': 1, 'description': 'Dépression très sévère : incapacité quasi totale à fonctionner, tristesse omniprésente.'},
          {'level': 2, 'description': 'Dépression marquée : pleurs fréquents, sentiment de culpabilité ou d\'inutilité prononcé.'},
          {'level': 3, 'description': 'Dépression modérée : fatigue importante, ralentissement, difficultés à éprouver du plaisir.'},
          {'level': 4, 'description': 'Déprime notable : humeur morose la majeure partie du temps, mais moments de répit.'},
          {'level': 5, 'description': 'Légère dépression : pessimisme, baisse de motivation, on arrive cependant à faire l\'essentiel.'},
          {'level': 6, 'description': 'Humeur légèrement basse : tristesse diffuse, mais capacité à fonctionner presque normale.'},
          {'level': 7, 'description': 'Humeur neutre : ni tristesse majeure, ni euphorie, sentiment d\'équilibre.'},
          {'level': 8, 'description': 'Humeur positive : bonne énergie, optimisme modéré, on se sent assez bien.'},
          {'level': 9, 'description': 'Humeur assez élevée : enthousiasme, vitalité, légère euphorie possible.'},
          {'level': 10, 'description': 'Humeur haute : exaltation, créativité, possible tendance à parler beaucoup plus vite.'},
          {'level': 11, 'description': 'Hypomanie : énergie débordante, insomnie ou besoin de sommeil réduit, irritabilité potentielle.'},
          {'level': 12, 'description': 'Forte hypomanie / proche manie : sentiment de toute-puissance, impulsivité accrue, difficulté à se concentrer.'},
          {'level': 13, 'description': 'Manie : euphorie ou irritabilité extrême, risque de comportements dangereux, déconnexion partielle de la réalité.'},
        ],
      };
    } else if (widget.id == 'custom-1') {
      // Mock data for a custom scale
      _scale = {
        'id': 'custom-1',
        'name': 'Energy Level',
        'description': 'Custom scale for tracking daily energy levels',
        'isDefault': false,
        'minValue': 0,
        'maxValue': 10,
        'isActive': true,
        'levels': [
          {'level': 0, 'description': 'Complete exhaustion, unable to get out of bed'},
          {'level': 1, 'description': 'Extremely fatigued, basic tasks require tremendous effort'},
          {'level': 2, 'description': 'Very tired, can only manage essential activities'},
          {'level': 3, 'description': 'Low energy, tasks take longer than usual'},
          {'level': 4, 'description': 'Below average energy, noticeable fatigue'},
          {'level': 5, 'description': 'Moderate energy, can function but not at full capacity'},
          {'level': 6, 'description': 'Slightly above average energy'},
          {'level': 7, 'description': 'Good energy level, productive and active'},
          {'level': 8, 'description': 'High energy, very productive and motivated'},
          {'level': 9, 'description': 'Very energetic, able to accomplish a lot without fatigue'},
          {'level': 10, 'description': 'Extremely energetic, maximum productivity and vitality'},
        ],
      };
    } else {
      // For other scales, create a simplified mock
      _scale = {
        'id': widget.id,
        'name': 'Unknown Scale',
        'description': 'Details not available',
        'isDefault': isDefaultScale,
        'minValue': 0,
        'maxValue': 10,
        'isActive': true,
        'levels': List.generate(
          11,
              (index) => {
            'level': index,
            'description': 'Level $index description',
          },
        ),
      };
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleActive() {
    if (_scale != null) {
      setState(() {
        _scale!['isActive'] = !_scale!['isActive'];
      });

      // TODO: Update via bloc
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _scale!['isActive'] ? 'Scale activated' : 'Scale deactivated',
          ),
          backgroundColor: _scale!['isActive'] ? AppColors.success : AppColors.info,
        ),
      );
    }
  }

  Future<void> _deleteScale() async {
    if (!_isEditable) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scale'),
        content: const Text('Are you sure you want to delete this scale? This action cannot be undone.'),
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
        title: Text(_scale?.isNotEmpty == true ? _scale!['name'] : 'Scale Details'),
        actions: [
          if (_isEditable) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed('/scale/edit', arguments: widget.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteScale,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _scale == null
          ? _buildErrorState()
          : _buildScaleDetails(),
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
            'Scale not found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'The requested scale could not be loaded',
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

  Widget _buildScaleDetails() {
    final totalLevels = _scale!['maxValue'] - _scale!['minValue'] + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scale info card
          Card(
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
                          _scale!['name'],
                          style: AppTextStyles.heading3,
                        ),
                      ),
                      if (_scale!['isDefault'])
                        _buildBadge(
                          text: 'Default',
                          color: AppColors.info,
                          icon: Icons.verified,
                        ),
                      if (!_scale!['isActive'])
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
                    _scale!['description'],
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Range info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Range',
                              style: AppTextStyles.labelLarge,
                            ),
                            Text(
                              '${_scale!['minValue']} - ${_scale!['maxValue']}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Levels',
                              style: AppTextStyles.labelLarge,
                            ),
                            Text(
                              '$totalLevels levels',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (_isEditable) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Active toggle
                    SwitchListTile(
                      title: const Text('Active'),
                      subtitle: Text(
                        'Enable this scale for mood entries',
                        style: AppTextStyles.bodySmall,
                      ),
                      value: _scale!['isActive'],
                      onChanged: (_) => _toggleActive(),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Levels section
          Text(
            'Scale Levels',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),

          // Scale levels
          for (final level in _scale!['levels']) _buildLevelItem(level),
        ],
      ),
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

  Widget _buildLevelItem(Map<String, dynamic> level) {
    final levelValue = level['level'] as int;
    final description = level['description'] as String;

    // Calculate color based on position in the range
    final totalLevels = _scale!['maxValue'] - _scale!['minValue'] + 1;
    final position = (levelValue - _scale!['minValue']) / (totalLevels - 1);
    final color = _getColorForPosition(position);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level indicator
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Text(
                levelValue.toString(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Description
            Expanded(
              child: Text(
                description,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
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