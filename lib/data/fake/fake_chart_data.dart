import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/news_item.dart';

class ChartDataGenerator {
  static const _basePrices = <String, double>{
    'AAPL': 193.5,  'TSLA': 248.0,  'NVDA': 875.0, 'MSFT': 412.0,
    'AMZN': 193.0,  'GOOGL': 172.0, 'META': 518.0, 'SPY':  518.0,
    'QQQ':  448.0,  'AMD':   158.0,  'NFLX': 688.0, 'COIN': 225.0,
    'PLTR':  24.0,  'SOFI':    8.5,  'GME':   18.0, 'BAC':   38.0,
    'JPM':  195.0,  'GS':    460.0,  'WMT':   65.0, 'BABA':  80.0,
  };

  static double _base(String ticker) {
    final t = ticker.toUpperCase().replaceAll('.', '');
    return _basePrices[t] ??
        (60.0 + Random(ticker.hashCode.abs() % 9973).nextDouble() * 440.0);
  }

  /// 20-point sparkline for list rows.
  static List<FlSpot> sparkline(String ticker, SentimentDirection direction) =>
      _generate(ticker, direction, points: 20, volatility: 0.013);

  /// Full price history for the detail chart.
  /// [points] maps to timeframe tabs: 24 / 40 / 30 / 90.
  static List<FlSpot> history(
    String ticker,
    SentimentDirection direction,
    int points, {
    double? volatility,
  }) =>
      _generate(ticker, direction,
          points: points, volatility: volatility ?? 0.016);

  static List<FlSpot> _generate(
    String ticker,
    SentimentDirection direction, {
    required int points,
    required double volatility,
  }) {
    final base = _base(ticker);
    final trend = direction == SentimentDirection.positive
        ? 0.0020
        : direction == SentimentDirection.negative
            ? -0.0020
            : 0.0004;

    // Start displaced so the final price lands near the base.
    double price = base *
        (direction == SentimentDirection.positive
            ? 0.93
            : direction == SentimentDirection.negative
                ? 1.07
                : 1.0);

    final r = Random((ticker.hashCode ^ direction.index).abs());
    final spots = <FlSpot>[];

    for (int i = 0; i < points; i++) {
      // Box-Muller lite for Gaussian-ish noise.
      final u1 = r.nextDouble() + 1e-9;
      final u2 = r.nextDouble() + 1e-9;
      final noise = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
      price = price * (1 + trend) + noise * price * volatility;
      price = price.clamp(base * 0.35, base * 2.8);
      spots.add(FlSpot(i.toDouble(), price));
    }
    return spots;
  }

  static double changePercent(List<FlSpot> spots) {
    if (spots.length < 2) return 0;
    return ((spots.last.y - spots.first.y) / spots.first.y) * 100;
  }

  static String fmtPrice(double price) {
    if (price >= 1000) return '\$${(price / 1000).toStringAsFixed(2)}K';
    return '\$${price.toStringAsFixed(2)}';
  }
}
