import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/domain/entities/mood_entry.dart';
import 'package:mood_tracker/domain/entities/mood_scale_value.dart';
import 'package:intl/intl.dart';

class MoodChart extends StatelessWidget {
  final List<MoodEntry> entries;
  final String? scaleId; // If provided, will show this specific scale, otherwise show stability score
  final ChartPeriod period;

  const MoodChart({
    Key? key,
    required this.entries,
    this.scaleId,
    this.period = ChartPeriod.week,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyChart();
    }

    // Process data based on period
    final processedData = _processData();
    if (processedData.isEmpty) {
      return _buildEmptyChart();
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: processedData.length - 1,
        minY: 0,
        maxY: scaleId != null ? 13 : 100, // Assuming scales are 0-13, stability is 0-100
        gridData: FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: scaleId != null ? 2 : 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: _getBottomTitles(processedData),
          ),
          leftTitles: AxisTitles(
            sideTitles: _getLeftTitles(),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        lineBarsData: [
          _createLineData(processedData),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.surface,
            tooltipRoundedRadius: 8,
            tooltipBorder: const BorderSide(color: AppColors.primary, width: 1),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < processedData.length) {
                  final item = processedData[index];

                  final date = _formatDate(item.date);
                  final value = spot.y.toStringAsFixed(1);
                  final label = scaleId != null ? 'Value: $value' : 'Stability: $value%';

                  return LineTooltipItem(
                    '$date\n$label',
                    AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<ChartDataPoint> _processData() {
    // Sort entries by date (oldest first)
    final sortedEntries = List<MoodEntry>.from(entries)
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

    // Group entries based on period
    final groupedData = <DateTime, List<MoodEntry>>{};
    for (final entry in sortedEntries) {
      final groupKey = _getGroupKey(entry.entryDate);
      groupedData.putIfAbsent(groupKey, () => []).add(entry);
    }

    // Convert to averages
    final result = <ChartDataPoint>[];
    groupedData.forEach((date, entriesInPeriod) {
      if (scaleId != null) {
        // Calculate average for specific scale
        double sum = 0;
        int count = 0;

        for (final entry in entriesInPeriod) {
          for (final scaleValue in entry.scaleValues) {
            if (scaleValue.scaleId == scaleId) {
              sum += scaleValue.value;
              count++;
              break;
            }
          }
        }

        if (count > 0) {
          result.add(ChartDataPoint(
            date: date,
            value: sum / count,
          ));
        }
      } else {
        // Calculate average stability score
        double sum = 0;
        int count = 0;

        for (final entry in entriesInPeriod) {
          if (entry.stabilityScore != null) {
            sum += entry.stabilityScore!;
            count++;
          }
        }

        if (count > 0) {
          result.add(ChartDataPoint(
            date: date,
            value: sum / count,
          ));
        }
      }
    });

    // Sort result by date
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  DateTime _getGroupKey(DateTime date) {
    switch (period) {
      case ChartPeriod.day:
      // Group by hour
        return DateTime(date.year, date.month, date.day, date.hour);

      case ChartPeriod.week:
      // Group by day
        return DateTime(date.year, date.month, date.day);

      case ChartPeriod.month:
      // Group by day
        return DateTime(date.year, date.month, date.day);

      case ChartPeriod.year:
      // Group by week (approximate)
        final weekNumber = (date.day - 1) ~/ 7 + 1;
        return DateTime(date.year, date.month, (weekNumber - 1) * 7 + 1);

      case ChartPeriod.all:
      // Group by month
        return DateTime(date.year, date.month, 1);
    }
  }

  String _formatDate(DateTime date) {
    switch (period) {
      case ChartPeriod.day:
        return DateFormat('h:mm a').format(date);

      case ChartPeriod.week:
        return DateFormat('E').format(date); // Day of week

      case ChartPeriod.month:
        return DateFormat('MMM d').format(date);

      case ChartPeriod.year:
        return DateFormat('MMM W').format(date); // Month and week

      case ChartPeriod.all:
        return DateFormat('MMM y').format(date);
    }
  }

  SideTitles _getBottomTitles(List<ChartDataPoint> data) {
    return SideTitles(
      showTitles: true,
      reservedSize: 25,
      interval: data.length > 10 ? (data.length / 5).ceil().toDouble() : 1,
      getTitlesWidget: (value, meta) {
        final index = value.toInt();
        if (index < 0 || index >= data.length) {
          return const SizedBox.shrink();
        }

        final date = data[index].date;
        String text;

        switch (period) {
          case ChartPeriod.day:
            text = DateFormat('h a').format(date);
            break;
          case ChartPeriod.week:
            text = DateFormat('E').format(date);
            break;
          case ChartPeriod.month:
            text = DateFormat('d').format(date);
            break;
          case ChartPeriod.year:
            text = DateFormat('MMM').format(date);
            break;
          case ChartPeriod.all:
            text = DateFormat('MMM y').format(date);
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            text,
            style: AppTextStyles.labelSmall,
          ),
        );
      },
    );
  }

  SideTitles _getLeftTitles() {
    final interval = scaleId != null ? 2.0 : 20.0;

    return SideTitles(
      showTitles: true,
      interval: interval,
      reservedSize: 40,
      getTitlesWidget: (value, meta) {
        return Text(
          value.toInt().toString(),
          style: AppTextStyles.labelSmall,
          textAlign: TextAlign.right,
        );
      },
    );
  }

  LineChartBarData _createLineData(List<ChartDataPoint> data) {
    return LineChartBarData(
      spots: List.generate(
        data.length,
            (index) => FlSpot(index.toDouble(), data[index].value),
      ),
      isCurved: true,
      color: AppColors.primary,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(
        show: true,
        getDotPainter: _getDotPainter,
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.primary.withOpacity(0.2),
      ),
    );
  }

  static FlDotPainter _getDotPainter(
      FlSpot spot,
      double xPercentage,
      LineChartBarData bar,
      int index,
      ) {
    return FlDotCirclePainter(
      radius: 4,
      color: Colors.white,
      strokeWidth: 2,
      strokeColor: AppColors.primary,
    );
  }
}

class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({
    required this.date,
    required this.value,
  });
}

enum ChartPeriod {
  day,
  week,
  month,
  year,
  all,
}