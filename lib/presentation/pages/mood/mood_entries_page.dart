import 'package:flutter/material.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';
import 'package:mood_tracker/presentation/widgets/mood/mood_entry_card.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodEntriesPage extends StatefulWidget {
  const MoodEntriesPage({Key? key}) : super(key: key);

  @override
  State<MoodEntriesPage> createState() => _MoodEntriesPageState();
}

class _MoodEntriesPageState extends State<MoodEntriesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _isLoading = false;
  bool _showCalendar = true;

  // TODO: Replace with data from bloc
  final List<Map<String, dynamic>> _mockEntries = [
    {
      'id': '1',
      'date': 'Today, 10:30 AM',
      'stabilityScore': 75.0,
      'mainScale': 'Mood',
      'mainScaleValue': 8,
      'comment': 'Feeling pretty good today, work went well.',
    },
    {
      'id': '2',
      'date': 'Yesterday, 9:15 PM',
      'stabilityScore': 65.0,
      'mainScale': 'Mood',
      'mainScaleValue': 7,
      'comment': 'Slightly tired but otherwise okay.',
    },
    {
      'id': '3',
      'date': 'Mar 15, 2:45 PM',
      'stabilityScore': 45.0,
      'mainScale': 'Mood',
      'mainScaleValue': 5,
      'comment': 'Stressful day at work, feeling a bit overwhelmed.',
    },
    {
      'id': '4',
      'date': 'Mar 14, 8:30 AM',
      'stabilityScore': 35.0,
      'mainScale': 'Mood',
      'mainScaleValue': 3,
      'comment': 'Slept poorly, feeling very low energy and irritable.',
    },
    {
      'id': '5',
      'date': 'Mar 13, 7:00 PM',
      'stabilityScore': 82.0,
      'mainScale': 'Mood',
      'mainScaleValue': 9,
      'comment': 'Great day! Accomplished a lot and feeling energized.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEntries();
  }

  void _loadEntries() {
    // TODO: Load entries from bloc
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar
        if (_showCalendar)
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadEntries();
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                // Event loader
                eventLoader: (day) {
                  // TODO: Return actual events for this day
                  return [];
                },
                calendarStyle: CalendarStyle(
                  markersMaxCount: 3,
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  formatButtonTextStyle: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

        // Calendar toggle button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showCalendar = !_showCalendar;
                  });
                },
                icon: Icon(
                  _showCalendar ? Icons.calendar_today : Icons.calendar_month,
                  size: 18,
                ),
                label: Text(_showCalendar ? 'Hide Calendar' : 'Show Calendar'),
              ),
            ],
          ),
        ),

        // Entries list
        Expanded(
          child: _isLoading
              ? const Center(child: LoadingIndicator())
              : _mockEntries.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _mockEntries.length,
            itemBuilder: (context, index) {
              final entry = _mockEntries[index];
              return MoodEntryCard(
                id: entry['id'],
                date: entry['date'],
                stabilityScore: entry['stabilityScore'],
                mainScale: entry['mainScale'],
                mainScaleValue: entry['mainScaleValue'],
                comment: entry['comment'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mood,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No mood entries yet',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first entry',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/mood/add');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Entry'),
          ),
        ],
      ),
    );
  }
}