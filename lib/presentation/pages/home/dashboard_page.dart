import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_bloc.dart';
import 'package:mood_tracker/presentation/bloc/auth/auth_state.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';
import 'package:mood_tracker/presentation/widgets/mood/mood_chart.dart';
import 'package:mood_tracker/presentation/widgets/mood/mood_entry_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 200,
                          child: MoodChart(),
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
                ),
                const SizedBox(height: 24),

                // Recent entries
                Text(
                  'Recent Entries',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),

                // TODO: Replace with actual data from MoodEntry bloc
                const MoodEntryCard(
                  id: '1',
                  date: 'Today, 10:30 AM',
                  stabilityScore: 75,
                  mainScale: 'Mood',
                  mainScaleValue: 8,
                  comment: 'Feeling pretty good today, work went well.',
                ),
                const SizedBox(height: 8),
                const MoodEntryCard(
                  id: '2',
                  date: 'Yesterday, 9:15 PM',
                  stabilityScore: 65,
                  mainScale: 'Mood',
                  mainScaleValue: 7,
                  comment: 'Slightly tired but otherwise okay.',
                ),
                const SizedBox(height: 16),
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
}