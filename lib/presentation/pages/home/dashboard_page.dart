import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_bloc.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_state.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_bloc.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_event.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_state.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';
import 'package:mood_tracker/presentation/widgets/mood/mood_chart.dart';
import 'package:mood_tracker/presentation/widgets/mood/mood_entry_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load mood entries when the dashboard is initialized
    context.read<MoodEntriesBloc>().add(const LoadMoodEntries(limit: 5));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user.username}',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Today is ${DateFormat('EEEE, MMMM d').format(DateTime.now())}',
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'How are you feeling today?',
                          style: AppTextStyles.heading4,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/mood/add');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Mood Entry'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mood trend chart
                Text(
                  'Your Mood Trend',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),
                BlocBuilder<MoodEntriesBloc, MoodEntriesState>(
                  builder: (context, state) {
                    if (state is MoodEntriesLoaded) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: MoodChart(
                                  entries: state.entries,
                                  period: ChartPeriod.week,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed('/mood');
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: LoadingIndicator()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Recent entries
                Text(
                  'Recent Entries',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),

                BlocBuilder<MoodEntriesBloc, MoodEntriesState>(
                  builder: (context, state) {
                    if (state is MoodEntriesLoaded) {
                      if (state.entries.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text('No entries yet. Add your first mood entry!'),
                            ),
                          ),
                        );
                      }

                      // Show the most recent entries
                      return Column(
                        children: state.entries.take(2).map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: MoodEntryCard(
                              entry: entry,
                              onTap: () {
                                Navigator.of(context).pushNamed('/mood/${entry.id}');
                              },
                              onDelete: () {
                                // Show delete confirmation
                                _showDeleteConfirmation(context, entry.id);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    } else if (state is MoodEntriesLoading) {
                      return const Center(child: LoadingIndicator());
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/mood');
                    },
                    child: const Text('View All Entries'),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: LoadingIndicator(),
          );
        }
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MoodEntriesBloc>().add(DeleteMoodEntryEvent(id: entryId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}