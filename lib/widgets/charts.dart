import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/client_model.dart';

// ── Equity Line Chart ─────────────────────────────────────
class EquityLineChart extends StatelessWidget {
  final List<double> equity;
  final List<String> months;
  final Color lineColor;
  final double height;

  const EquityLineChart({
    super.key,
    required this.equity,
    required this.months,
    this.lineColor = AETheme.indigo2,
    this.height = 165,
  });

  @override
  Widget build(BuildContext context) {
    if (equity.length < 2) {
      return SizedBox(height: height, child: const Center(child: Text('No data')));
    }

    final minY = equity.reduce((a, b) => a < b ? a : b) * 0.997;
    final maxY = equity.reduce((a, b) => a > b ? a : b) * 1.003;

    final spots = equity.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: const Color(0x0A070921),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: months.isNotEmpty,
                reservedSize: 20,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= months.length) return const SizedBox();
                  return Text(
                    months[i],
                    style: AETheme.syne(size: 8, color: const Color(0x48070921)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: lineColor,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3.5,
                  color: lineColor,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withValues(alpha: 0.18),
                    lineColor.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Donut / Allocation Chart ──────────────────────────────
class AllocationDonut extends StatelessWidget {
  final List<AllocationSlice> allocation;
  final int winRate;
  final int colorValue;
  final double size;

  const AllocationDonut({
    super.key,
    required this.allocation,
    required this.winRate,
    required this.colorValue,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final sections = allocation.map((a) {
      final col = Color(a.colorValue);
      return PieChartSectionData(
        value: a.pct.toDouble(),
        color: col,
        radius: size * 0.43 * 0.42,
        showTitle: false,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: size * 0.43 * 0.58,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$winRate%',
                    style: AETheme.fraunces(
                      size: 13,
                      color: Color(colorValue),
                      weight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'win rate',
                    style: AETheme.syne(
                      size: 8,
                      color: const Color(0x50070921),
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...allocation.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(a.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        a.label,
                        style: AETheme.syne(size: 12, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Text(
                    '${a.pct}%',
                    style: AETheme.syne(
                      size: 12,
                      weight: FontWeight.w800,
                      color: Color(a.colorValue),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────
