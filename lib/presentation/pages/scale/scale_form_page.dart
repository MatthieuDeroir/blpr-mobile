import 'package:flutter/material.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/core/utils/validation_utils.dart';

class ScaleFormPage extends StatefulWidget {
  final String? id; // If not null, we're editing an existing scale

  const ScaleFormPage({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  State<ScaleFormPage> createState() => _ScaleFormPageState();
}

class _ScaleFormPageState extends State<ScaleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _levelDescriptionControllers = [];

  bool _isActive = true;
  int _minValue = 0;
  int _maxValue = 10;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.id != null;
    _initializeLevelControllers();

    if (_isEditing) {
      _loadScale();
    }
  }

  void _initializeLevelControllers() {
    _levelDescriptionControllers.clear();
    final levelCount = _maxValue - _minValue + 1;
    for (int i = 0; i < levelCount; i++) {
      _levelDescriptionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _levelDescriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadScale() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load from Scale bloc
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data for editing
    _nameController.text = 'Energy Level';
    _descriptionController.text = 'Custom scale for tracking daily energy levels';
    _minValue = 0;
    _maxValue = 10;
    _isActive = true;

    // Re-initialize controllers for the correct number of levels
    _initializeLevelControllers();

    // Populate level descriptions
    final descriptions = [
      'Complete exhaustion, unable to get out of bed',
      'Extremely fatigued, basic tasks require tremendous effort',
      'Very tired, can only manage essential activities',
      'Low energy, tasks take longer than usual',
      'Below average energy, noticeable fatigue',
      'Moderate energy, can function but not at full capacity',
      'Slightly above average energy',
      'Good energy level, productive and active',
      'High energy, very productive and motivated',
      'Very energetic, able to accomplish a lot without fatigue',
      'Extremely energetic, maximum productivity and vitality',
    ];

    for (int i = 0; i < descriptions.length; i++) {
      _levelDescriptionControllers[i].text = descriptions[i];
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _updateRangeValues(int min, int max) {
    setState(() {
      _minValue = min;
      _maxValue = max;
      _initializeLevelControllers();
    });
  }

  Future<void> _saveScale() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Prepare data
      final name = _nameController.text;
      final description = _descriptionController.text;
      final levels = List.generate(
        _maxValue - _minValue + 1,
            (index) => {
          'level': _minValue + index,
          'description': _levelDescriptionControllers[index].text,
        },
      );

      // TODO: Save via bloc
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Scale' : 'Create Scale'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Scale info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scale Information',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Scale Name',
                        hintText: 'e.g., Energy Level',
                      ),
                      validator: ValidationUtils.validateScaleName,
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'What does this scale measure?',
                      ),
                      maxLines: 3,
                      validator: ValidationUtils.validateScaleDescription,
                    ),
                    const SizedBox(height: 16),

                    // Range selector
                    Text(
                      'Scale Range',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Min Value',
                            ),
                            value: _minValue,
                            items: List.generate(
                              5,
                                  (index) => DropdownMenuItem(
                                value: index,
                                child: Text(index.toString()),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null && value <= _maxValue - 1) {
                                _updateRangeValues(value, _maxValue);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Max Value',
                            ),
                            value: _maxValue,
                            items: List.generate(
                              20,
                                  (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text((index + 1).toString()),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null && value >= _minValue + 1) {
                                _updateRangeValues(_minValue, value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Active switch
                    SwitchListTile(
                      title: const Text('Active'),
                      subtitle: Text(
                        'Make this scale available for mood entries',
                        style: AppTextStyles.bodySmall,
                      ),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Level descriptions
            Text(
              'Level Descriptions',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Define what each level of the scale means',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Level description fields
            for (int i = 0; i < _levelDescriptionControllers.length; i++)
              _buildLevelDescriptionField(i),

            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saveScale,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isEditing ? 'Update Scale' : 'Create Scale'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelDescriptionField(int index) {
    final level = _minValue + index;
    final color = _getColorForLevel(level);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level indicator
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 12, top: 12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Text(
              level.toString(),
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Description field
          Expanded(
            child: TextFormField(
              controller: _levelDescriptionControllers[index],
              decoration: InputDecoration(
                labelText: 'Level $level Description',
                hintText: 'Describe what level $level means',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide a description for level $level';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForLevel(int level) {
    final normalizedValue = (level - _minValue) / (_maxValue - _minValue);

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