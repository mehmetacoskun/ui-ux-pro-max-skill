import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'glass_card.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Revenue Streams",
            style: TextStyle(
              color: AppColors.textBody,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5000,
                      getTitlesWidget: leftTitleWidgets,
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 15000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3000),
                      FlSpot(1, 4500),
                      FlSpot(2, 3800),
                      FlSpot(3, 8000),
                      FlSpot(4, 7500),
                      FlSpot(5, 12000),
                      FlSpot(6, 11000),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.3),
                          const Color(0xFF22C55E).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: AppColors.textMuted,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('MON', style: style);
        break;
      case 1:
        text = const Text('TUE', style: style);
        break;
      case 2:
        text = const Text('WED', style: style);
        break;
      case 3:
        text = const Text('THU', style: style);
        break;
      case 4:
        text = const Text('FRI', style: style);
        break;
      case 5:
        text = const Text('SAT', style: style);
        break;
      case 6:
        text = const Text('SUN', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: AppColors.textMuted,
      fontSize: 12,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == 5000) {
      text = '5k';
    } else if (value == 10000) {
      text = '10k';
    } else if (value == 15000) {
      text = '15k';
    } else {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style, textAlign: TextAlign.left),
    );
  }
}
