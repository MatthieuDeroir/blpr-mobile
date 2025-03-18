import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/scale.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_bloc.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_event.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_state.dart';
import 'package:mood_tracker/presentation/bloc/scale/scales_bloc.dart';
import 'package:mood_tracker/presentation/bloc/scale/scales_event.dart';
import 'package:mood_tracker/presentation/bloc/scale/scales_state.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';
import 'package:mood_tracker/presentation/widgets/mood/mood_chart.dart';

class MoodAnalyticsPage extends StatefulWidget {
  const MoodAnalyticsPage({Key? key}) : super(key: key);

  @override
  State<MoodAnalyticsPage> createState() => _MoodAnalyticsPageState();
}

class _MoodAnalyticsPageState extends State<MoodAnalyticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ChartPeriod _selectedPeriod = ChartPeriod.week;
  String? _selectedScaleId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data
    context.read<MoodEntriesBloc>().add(const LoadMoodEntries(limit: 100));
    context.read<ScalesBloc>().add(LoadScales());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stability Score'),
            Tab(text: 'Scale Trends'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Period selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Period:', style: AppTextStyles.labelMedium),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPeriodChip(ChartPeriod.day, 'Day'),
                        _buildPeriodChip(ChartPeriod.week, 'Week'),
                        _buildPeriodChip(ChartPeriod.month, 'Month'),
                        _buildPeriodChip(ChartPeriod.year, 'Year'),
                        _buildPeriodChip(ChartPeriod.all, 'All Time'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Stability Score Tab
                _buildStabilityChart(),

                // Scale Trends Tab
                _buildScaleTrendsChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(ChartPeriod period, String label) {
    final isSelected = period == _selectedPeriod;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedPeriod = period;
            });
          }
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStabilityChart() {
    return BlocBuilder<MoodEntriesBloc, MoodEntriesState>(
      builder: (context, state) {
        if (state is MoodEntriesLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is MoodEntriesError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        } else if (state is MoodEntriesLoaded) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stability Score Trend',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),
                Text(
                  'How your overall mental stability has changed over time',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Chart
                Expanded(
                  child: MoodChart(
                    entries: state.entries,
                    period: _selectedPeriod,
                  ),
                ),

                // Statistics
                _buildStabilityStats(state.entries),
              ],
            ),
          );
        }

        return const Center(child: LoadingIndicator());
      },
    );
  }

  Widget _buildScaleTrendsChart() {
    return BlocBuilder<ScalesBloc, ScalesState>(
      builder: (context, scalesState) {
        if (scalesState is ScalesLoading) {
          return const Center(child: LoadingIndicator());
        } else if (scalesState is ScalesError) {
          return Center(
            child: Text('Error: ${scalesState.message}'),
          );
        } else if (scalesState is ScalesLoaded) {
          return BlocBuilder<MoodEntriesBloc, MoodEntriesState>(
            builder: (context, entriesState) {
              if (entriesState is MoodEntriesLoaded) {
                return Column(
                  children: [
                    // Scale selection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Scale',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedScaleId ?? _getDefaultScaleId(scalesState.scales),
                        items: scalesState.scales.map((scale) {
                          return DropdownMenuItem<String>(
                            value: scale.id,
                            child: Text(scale.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedScaleId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chart
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: MoodChart(
                          entries: entriesState.entries,
                          scaleId: _selectedScaleId ?? _getDefaultScaleId(scalesState.scales),
                          period: _selectedPeriod,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const Center(child: LoadingIndicator());
            },
          );
        }

        return const Center(child: LoadingIndicator());
      },
    );
  }

  String _getDefaultScaleId(List<Scale> scales) {
    // Try to find the "Mood" scale first
    try {
      return scales.firstWhere(
            (scale) => scale.name.toLowerCase().contains('mood'),
      ).id;
    } catch (_) {
      // If not found, return the first scale
      return scales.isNotEmpty ? scales.first.id : AppConstants.humeurScaleId;
    }
  }

  Widget _buildStabilityStats(List<MoodEntry> entries) {
    // Filter entries that have stability scores
    final entriesWithScores = entries.where((e) => e.stabilityScore != null).toList();

    if (entriesWithScores.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate statistics
    final scores = entriesWithScores.map((e) => e.stabilityScore!).toList();
    scores.sort();

    final currentScore = scores.last;
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    final lowestScore = scores.first;
    final highestScore = scores.last;

    // Create stat cards
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Current',
                  '${currentScore.toInt()}%',
                  _getStabilityColor(currentScore),
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Average',
                  '${averageScore.toInt()}%',
                  _getStabilityColor(averageScore),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Lowest',
                  '${lowestScore.toInt()}%',
                  _getStabilityColor(lowestScore),
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Highest',
                  '${highestScore.toInt()}%',
                  _getStabilityColor(highestScore),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: color,
              ),
            ),
          ],
        ),
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
}