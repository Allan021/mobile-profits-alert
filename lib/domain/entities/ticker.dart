enum TickerTrend { up, down, flat }

class Ticker {
  final String symbol;
  final String companyName;
  final double sentimentScore;
  final TickerTrend trend;

  const Ticker({
    required this.symbol,
    required this.companyName,
    required this.sentimentScore,
    required this.trend,
  });

  String get displayScore {
    final sign = sentimentScore >= 0 ? '+' : '';
    return '$sign${sentimentScore.toStringAsFixed(1)}%';
  }
}
