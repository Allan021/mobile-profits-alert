import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/fake/fake_chart_data.dart';
import '../../domain/entities/news_item.dart';

class PriceChartWidget extends StatefulWidget {
  final String ticker;
  final SentimentDirection direction;

  const PriceChartWidget({
    super.key,
    required this.ticker,
    required this.direction,
  });

  @override
  State<PriceChartWidget> createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  static const _labels = ['1D', '5D', '1M', '3M'];
  static const _points = [24, 40, 30, 90];

  int _tfIndex = 2;
  late List<FlSpot> _spots;
  double? _touchedY;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _spots = ChartDataGenerator.history(
      widget.ticker,
      widget.direction,
      _points[_tfIndex],
    );
    _touchedY = null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final change = ChartDataGenerator.changePercent(_spots);
    final isUp = change >= 0;
    final chartColor = isUp
        ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
        : (isDark ? AppColors.negativeDark : AppColors.negativeLight);

    final displayPrice = _touchedY != null
        ? ChartDataGenerator.fmtPrice(_touchedY!)
        : ChartDataGenerator.fmtPrice(_spots.last.y);
    final changeStr = '${isUp ? '+' : ''}${change.toStringAsFixed(2)}%';

    final minY = _spots.map((s) => s.y).reduce(math.min);
    final maxY = _spots.map((s) => s.y).reduce(math.max);
    final yRange = maxY - minY;
    final yPad = yRange * 0.12;
    final interval = yRange > 0 ? yRange / 4 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Price header ──────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                displayPrice,
                key: ValueKey(displayPrice),
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.white : AppColors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chartColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 16,
                      color: chartColor,
                    ),
                    Text(
                      changeStr,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: chartColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.ticker,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),

        // ── Chart ─────────────────────────────────────────────────
        SizedBox(
          height: 190,
          child: LineChart(
            LineChartData(
              minY: minY - yPad,
              maxY: maxY + yPad,
              clipData: const FlClipData.all(),
              lineBarsData: [
                LineChartBarData(
                  spots: _spots,
                  isCurved: true,
                  curveSmoothness: 0.32,
                  color: chartColor,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        chartColor.withOpacity(0.30),
                        chartColor.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                      .withOpacity(0.5),
                  strokeWidth: 0.5,
                  dashArray: [4, 6],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 54,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          ChartDataGenerator.fmtPrice(value),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: isDark ? Colors.white70 : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: (event, resp) {
                  if (!mounted) return;
                  setState(() {
                    _touchedY = resp?.lineBarSpots?.firstOrNull?.y;
                  });
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) =>
                      isDark ? const Color(0xFF243252) : AppColors.lightCard,
                  tooltipRoundedRadius: 8,
                  tooltipBorder: BorderSide(
                    color: chartColor.withOpacity(0.4),
                    width: 1,
                  ),
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                            ChartDataGenerator.fmtPrice(s.y),
                            GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: chartColor,
                            ),
                          ))
                      .toList(),
                ),
                handleBuiltInTouches: true,
              ),
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
          ),
        ),
        const SizedBox(height: 14),

        // ── Timeframe tabs ────────────────────────────────────────
        Row(
          children: List.generate(_labels.length, (i) {
            final sel = i == _tfIndex;
            return GestureDetector(
              onTap: () => setState(() {
                _tfIndex = i;
                _refresh();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? chartColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? chartColor
                        : (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                  ),
                ),
                child: Text(
                  _labels[i],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel
                        ? (isDark ? AppColors.black : AppColors.white)
                        : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.06,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 500.ms,
        );
  }
}
