import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/fake/fake_chart_data.dart';
import '../../domain/entities/news_item.dart';

// Cache sparkline paths — same ticker+direction always yields same data,
// no point recomputing on every rebuild.
final _spotCache = <String, List<Offset>>{};

List<Offset> _buildOffsets(String ticker, SentimentDirection direction) {
  final key = '$ticker:${direction.index}';
  return _spotCache.putIfAbsent(key, () {
    final spots = ChartDataGenerator.sparkline(ticker, direction);
    if (spots.isEmpty) return [];
    final xs = spots.map((s) => s.x).toList();
    final ys = spots.map((s) => s.y).toList();
    final minX = xs.reduce(min);
    final maxX = xs.reduce(max);
    final minY = ys.reduce(min);
    final maxY = ys.reduce(max);
    final rangeX = (maxX - minX).abs();
    final rangeY = (maxY - minY).abs();
    return spots
        .map((s) => Offset(
              rangeX == 0 ? 0 : (s.x - minX) / rangeX,
              rangeY == 0 ? 0.5 : 1.0 - (s.y - minY) / rangeY,
            ))
        .toList();
  });
}

class SparklineWidget extends StatelessWidget {
  final String ticker;
  final SentimentDirection direction;
  final double width;
  final double height;

  const SparklineWidget({
    super.key,
    required this.ticker,
    required this.direction,
    this.width = 72,
    this.height = 34,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offsets = _buildOffsets(ticker, direction);
    final isUp = offsets.length >= 2 && offsets.last.dy <= offsets.first.dy;
    final color = isUp
        ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
        : (isDark ? AppColors.negativeDark : AppColors.negativeLight);

    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _SparklinePainter(offsets: offsets, color: color),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<Offset> offsets;
  final Color color;

  const _SparklinePainter({required this.offsets, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (offsets.length < 2) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final first = Offset(offsets[0].dx * size.width, offsets[0].dy * size.height);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < offsets.length; i++) {
      final pt = Offset(offsets[i].dx * size.width, offsets[i].dy * size.height);
      final prev = Offset(offsets[i - 1].dx * size.width, offsets[i - 1].dy * size.height);
      final cpX = (prev.dx + pt.dx) / 2;
      path.cubicTo(cpX, prev.dy, cpX, pt.dy, pt.dx, pt.dy);
    }

    // Gradient fill below line
    final fillPath = Path()..addPath(path, Offset.zero);
    final last = Offset(offsets.last.dx * size.width, offsets.last.dy * size.height);
    fillPath
      ..lineTo(last.dx, size.height)
      ..lineTo(first.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.color != color || old.offsets != offsets;
}
