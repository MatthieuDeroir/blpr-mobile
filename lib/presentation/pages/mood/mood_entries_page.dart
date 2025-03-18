import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_bloc.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_event.dart';
import 'package:mood_tracker/presentation/bloc/mood/mood_entries_state.dart';
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
  bool _showCalendar = true;
  final ScrollController _scrollController = ScrollController();
  final Map<DateTime, List<MoodEntry>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Load initial entries
    context.read<MoodEntriesBloc>().add(const LoadMoodEntries(limit: 20));

    // Setup scroll controller for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MoodEntriesBloc>().add(const LoadMoreMoodEntries(limit: 10));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _groupEntriesByDay(List<MoodEntry> entries) {
    _eventsByDay.clear();

    for (final entry in entries) {
      final day = DateTime(
        entry.entryDate.year,
        entry.entryDate.month,
        entry.entryDate.day,
      );

      if (_eventsByDay[day] == null) {
        _eventsByDay[day] = [];
      }

      _eventsByDay[day]!.add(entry);
    }
  }

  List<MoodEntry> _getEntriesForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _eventsByDay[normalizedDay] ?? [];
  }

  void _filterByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    context.read<MoodEntriesBloc>().add(
      FilterMoodEntriesByDate(
        startDate: startOfDay,
        endDate: endOfDay,
      ),
    );
  }

  void _resetFilter() {
    context.read<MoodEntriesBloc>().add(const LoadMoodEntries(limit: 20));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar
        if (_showCalendar)
          BlocBuilder<MoodEntriesBloc, MoodEntriesState>(
            builder: (context, state) {
              if (state is MoodEntriesLoaded) {
                _groupEntriesByDay(state.entries);
              }

              return Card(
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

                      // Filter entries by selected day
                      _filterByDate(selectedDay);
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
                      return _getEntriesForDay(day);
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
                      markerDecoration: const BoxDecoration(
                        color: AppColors.secondary,
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
              );
            },
          ),

        // Calendar toggle button and filter indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              BlocBuilder<MoodEntriesBloc, MoodEntriesState>(
                builder: (context, state) {
                  if (state is MoodEntriesLoaded && state.filteredByDate) {
                    return Expanded(
                      child: Row(
                        children: [
                          Text(
                            state.startDate != null
                                ? 'Filtered: ${DateFormat('MMM d, yyyy').format(state.startDate!)}'
                                : '',
                            style: AppTextStyles.labelMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _resetFilter,
                            tooltip: 'Clear filter',
                          ),
                        ],
                      ),
                    );
                  }
                  return const Spacer();
                },
              ),
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
          child: BlocBuilder<MoodEntriesBloc, MoodEntriesState>(
            builder: (context, state) {
              if (state is MoodEntriesLoading) {
                return const Center(child: LoadingIndicator());
              } else if (state is MoodEntriesError) {
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
                        'Error loading mood entries',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<MoodEntriesBloc>().add(const LoadMoodEntries());
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              } else if (state is MoodEntriesLoaded) {
                if (state.entries.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<MoodEntriesBloc>().add(RefreshMoodEntries());
                    return;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.entries.length + (state.hasReachedMax ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index >= state.entries.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final entry = state.entries[index];
                      return MoodEntryCard(
                        entry: entry,
                        onTap: () {
                          Navigator.of(context).pushNamed('/mood/${entry.id}');
                        },
                        onDelete: () {
                          _showDeleteConfirmation(context, entry.id);
                        },
                      );
                    },
                  ),
                );
              }

              return const Center(child: LoadingIndicator());
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

  Future<void> _showDeleteConfirmation(BuildContext context, String entryId) async {
    final result = await showDialog<bool>(
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

    if (result == true) {
      context.read<MoodEntriesBloc>().add(DeleteMoodEntryEvent(id: entryId));
    }
  }
}