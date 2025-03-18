import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';

class MoodChart extends StatelessWidget {
  const MoodChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to actual mood data from a bloc
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: _bottomTitles,
          ),
          leftTitles: AxisTitles(
            sideTitles: _leftTitles,
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
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
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        lineBarsData: [
          _createMoodLineData(),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.surface,
            tooltipRoundedRadius: 8,
            tooltipBorder: const BorderSide(color: AppColors.primary, width: 1),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final stability = spot.y.toStringAsFixed(1);
                return LineTooltipItem(
                  'Stability: $stability',
                  AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  LineChartBarData _createMoodLineData() {
    // Sample data points
    final spots = [
      const FlSpot(0, 65), // 7 days ago
      const FlSpot(1, 68), // 6 days ago
      const FlSpot(2, 60), // 5 days ago
      const FlSpot(3, 55), // 4 days ago
      const FlSpot(4, 65), // 3 days ago
      const FlSpot(5, 70), // 2 days ago
      const FlSpot(6, 75), // 1 day ago
    ];

    return LineChartBarData(
      spots: spots,
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

  SideTitles get _bottomTitles => SideTitles(
    showTitles: true,
    interval: 1,
    getTitlesWidget: (value, meta) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final index = value.toInt() % 7;

      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          days[index],
          style: AppTextStyles.labelSmall,
        ),
      );
    },
  );

  SideTitles get _leftTitles => SideTitles(
    showTitles: true,
    interval: 20,
    reservedSize: 40,
    getTitlesWidget: (value, meta) {
      String text = value.toInt().toString();

      return Text(
        text,
        style: AppTextStyles.labelSmall,
        textAlign: TextAlign.right,
      );
    },
  );
}