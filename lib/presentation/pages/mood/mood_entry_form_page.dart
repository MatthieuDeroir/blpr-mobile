import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/core/utils/validation_utils.dart';
import 'package:mood_tracker/presentation/widgets/mood/mood_scale_slider.dart';

class MoodEntryFormPage extends StatefulWidget {
  final String? id; // If provided, we're editing an existing entry

  const MoodEntryFormPage({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  State<MoodEntryFormPage> createState() => _MoodEntryFormPageState();
}

class _MoodEntryFormPageState extends State<MoodEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _medicationController = TextEditingController();
  final _sleepHoursController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // TODO: Replace with data from scale bloc
  final _mockScales = [
    {
      'id': AppConstants.humeurScaleId,
      'name': 'Mood (Humeur)',
      'description': 'Scale for measuring mood between depression and mania',
      'minValue': 0,
      'maxValue': 13,
      'value': 7, // Default to middle value
    },
    {
      'id': AppConstants.irritabiliteScaleId,
      'name': 'Irritability (Irritabilité)',
      'description': 'Scale for measuring irritability and anger levels',
      'minValue': 0,
      'maxValue': 13,
      'value': 7,
    },
    {
      'id': AppConstants.confianceScaleId,
      'name': 'Confidence (Confiance)',
      'description': 'Scale for measuring self-confidence and esteem',
      'minValue': 0,
      'maxValue': 13,
      'value': 7,
    },
    {
      'id': AppConstants.extraversionScaleId,
      'name': 'Extraversion',
      'description': 'Scale for measuring sociability and extraversion',
      'minValue': 0,
      'maxValue': 13,
      'value': 7,
    },
    {
      'id': AppConstants.bienEtreScaleId,
      'name': 'Well-being (Bien-être)',
      'description': 'Scale for measuring general well-being and anxiety',
      'minValue': 0,
      'maxValue': 13,
      'value': 7,
    },
  ];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.id != null;

    if (_isEditing) {
      _loadEntry();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _medicationController.dispose();
    _sleepHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadEntry() async {
    // TODO: Load entry data from bloc based on widget.id
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data for now
    _commentController.text = 'Feeling pretty good today, work went well.';
    _medicationController.text = 'Morning medication as prescribed';
    _sleepHoursController.text = '7.5';
    _selectedDate = DateTime.now().subtract(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 10, minute: 30);

    // Update scales
    setState(() {
      _mockScales[0]['value'] = 8; // Mood
      _mockScales[1]['value'] = 3; // Irritability
      _mockScales[2]['value'] = 7; // Confidence
      _mockScales[3]['value'] = 6; // Extraversion
      _mockScales[4]['value'] = 8; // Well-being

      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _updateScaleValue(String scaleId, int value) {
    setState(() {
      final scale = _mockScales.firstWhere((scale) => scale['id'] == scaleId);
      scale['value'] = value;
    });
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Save entry via bloc
      setState(() {
        _isLoading = true;
      });

      // Prepare data
      final entryDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final scaleValues = _mockScales.map((scale) => {
        'scaleId': scale['id'],
        'value': scale['value'],
      }).toList();

      final sleepHours = _sleepHoursController.text.isNotEmpty
          ? double.tryParse(_sleepHoursController.text)
          : null;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Navigate back
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
        title: Text(_isEditing ? 'Edit Mood Entry' : 'New Mood Entry'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date and time selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When?',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Time',
                                prefixIcon: Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _selectedTime.format(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mood scales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How do you feel?',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),

                    // Scale sliders
                    for (final scale in _mockScales) ...[
                      MoodScaleSlider(
                        name: scale['name'] as String,
                        description: scale['description'] as String,
                        minValue: scale['minValue'] as int,
                        maxValue: scale['maxValue'] as int,
                        value: scale['value'] as int,
                        onChanged: (value) => _updateScaleValue(scale['id'] as String, value),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional info
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

                    // Sleep hours
                    TextFormField(
                      controller: _sleepHoursController,
                      decoration: const InputDecoration(
                        labelText: 'Sleep Hours',
                        prefixIcon: Icon(Icons.bedtime_outlined),
                        hintText: 'Optional',
                      ),
                      keyboardType: TextInputType.number,
                      validator: ValidationUtils.validateSleepHours,
                    ),
                    const SizedBox(height: 16),

                    // Medication
                    TextFormField(
                      controller: _medicationController,
                      decoration: const InputDecoration(
                        labelText: 'Medication',
                        prefixIcon: Icon(Icons.medication_outlined),
                        hintText: 'Optional',
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),

                    // Comments
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comments',
                        prefixIcon: Icon(Icons.comment_outlined),
                        hintText: 'How was your day? (Optional)',
                      ),
                      maxLines: 3,
                      validator: ValidationUtils.validateMoodComment,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isEditing ? 'Update Entry' : 'Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}