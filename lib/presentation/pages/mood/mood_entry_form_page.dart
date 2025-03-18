import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/core/utils/validation_utils.dart';
import 'package:mood_tracker/domain/entities/scale.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entry_form_bloc.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entry_form_event.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entry_form_state.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';
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

  @override
  void initState() {
    super.initState();

    // Initialize form or load entry for editing
    if (widget.id != null) {
      context.read<MoodEntryFormBloc>().add(LoadMoodEntryForEdit(widget.id!));
    } else {
      context.read<MoodEntryFormBloc>().add(InitializeMoodEntryForm());
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _medicationController.dispose();
    _sleepHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null ? 'Edit Mood Entry' : 'New Mood Entry'),
      ),
      body: BlocConsumer<MoodEntryFormBloc, MoodEntryFormState>(
        listener: (context, state) {
          if (state is MoodEntryFormSubmitted) {
            // Show success message and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.id != null
                      ? 'Entry updated successfully'
                      : 'Entry created successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is MoodEntryFormError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is MoodEntryFormLoaded) {
            // Update controllers when form is loaded with data
            _commentController.text = state.comment;
            _medicationController.text = state.medication;
            _sleepHoursController.text = state.sleepHours?.toString() ?? '';
          }
        },
        builder: (context, state) {
          if (state is MoodEntryFormInitial || state is MoodEntryFormLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is MoodEntryFormLoaded) {
            return _buildForm(context, state);
          } else if (state is MoodEntryFormSubmitting) {
            return const Center(child: LoadingIndicator());
          } else if (state is MoodEntryFormError) {
            return _buildErrorState(context, state.message);
          }

          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, MoodEntryFormLoaded state) {
    return Form(
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
                          onTap: () => _selectDate(context, state),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              DateFormat('EEE, MMM d, yyyy').format(state.entryDate),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context, state),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              DateFormat('h:mm a').format(state.entryDate),
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
                  ...state.scaleValues.map((scaleValue) {
                    final scale = state.getScaleById(scaleValue.scaleId);
                    if (scale == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: MoodScaleSlider(
                        name: scale.name,
                        description: scale.description,
                        minValue: scale.minValue,
                        maxValue: scale.maxValue,
                        value: scaleValue.value,
                        onChanged: (value) {
                          context.read<MoodEntryFormBloc>().add(
                            UpdateScaleValue(
                              scaleId: scaleValue.scaleId,
                              value: value,
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
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
                    onChanged: (value) {
                      context.read<MoodEntryFormBloc>().add(
                        UpdateSleepHours(
                          value.isNotEmpty ? double.tryParse(value) : null,
                        ),
                      );
                    },
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
                    onChanged: (value) {
                      context.read<MoodEntryFormBloc>().add(
                        UpdateMedication(value),
                      );
                    },
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
                    onChanged: (value) {
                      context.read<MoodEntryFormBloc>().add(
                        UpdateComment(value),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                context.read<MoodEntryFormBloc>().add(SubmitMoodEntryForm());
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(widget.id != null ? 'Update Entry' : 'Save Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
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
            'Error',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (widget.id != null) {
                context.read<MoodEntryFormBloc>().add(LoadMoodEntryForEdit(widget.id!));
              } else {
                context.read<MoodEntryFormBloc>().add(InitializeMoodEntryForm());
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, MoodEntryFormLoaded state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      final updatedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        state.entryDate.hour,
        state.entryDate.minute,
      );
      context.read<MoodEntryFormBloc>().add(UpdateEntryDate(updatedDate));
    }
  }

  Future<void> _selectTime(BuildContext context, MoodEntryFormLoaded state) async {
    final TimeOfDay currentTime = TimeOfDay.fromDateTime(state.entryDate);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      final updatedDate = DateTime(
        state.entryDate.year,
        state.entryDate.month,
        state.entryDate.day,
        picked.hour,
        picked.minute,
      );
      context.read<MoodEntryFormBloc>().add(UpdateEntryDate(updatedDate));
    }
  }
}