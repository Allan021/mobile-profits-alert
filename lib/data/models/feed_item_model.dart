import '../../domain/entities/news_item.dart';
import '../../domain/entities/alert.dart';

class FeedItemModel {
  final String id;
  final String title;
  final String rationale;
  final String direction;
  final int impactScore;
  final int confidence;
  final String tickersCsv;
  final String source;
  final String? url;
  final String fetchedAt;
  final String fetchedAgo;
  final String signalTag;
  final String catalystLabel;

  const FeedItemModel({
    required this.id,
    required this.title,
    required this.rationale,
    required this.direction,
    required this.impactScore,
    required this.confidence,
    required this.tickersCsv,
    required this.source,
    this.url,
    required this.fetchedAt,
    required this.fetchedAgo,
    required this.signalTag,
    required this.catalystLabel,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['item_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      rationale: json['rationale']?.toString() ?? '',
      direction: json['direction']?.toString() ?? 'neutral',
      impactScore: (json['impact_score'] as num?)?.toInt() ?? 0,
      confidence: _parseConfidence(json['confidence']),
      tickersCsv: json['tickers_csv']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      url: json['url']?.toString(),
      fetchedAt: json['fetched_at']?.toString() ?? '',
      fetchedAgo: json['fetched_ago']?.toString() ?? '',
      signalTag: json['signal_tag']?.toString() ?? '',
      catalystLabel: json['catalyst_label']?.toString() ?? '',
    );
  }

  // DB stores confidence as float 0.0–1.0; UI expects int 0–100.
  static int _parseConfidence(dynamic raw) {
    if (raw == null) return 0;
    final v = (raw as num).toDouble();
    return v <= 1.0 ? (v * 100).round() : v.toInt();
  }

  List<String> get affectedTickers =>
      tickersCsv.split(',').where((t) => t.isNotEmpty).toList();

  String get primaryTicker => affectedTickers.firstOrNull ?? '';

  NewsItem toNewsItem() {
    return NewsItem(
      id: id,
      ticker: primaryTicker,
      headline: title,
      source: source.isNotEmpty ? source : 'Profit Alerts',
      author: '',
      url: url,
      direction: _mapDirection(direction),
      confidence: confidence,
      rationale: rationale,
      analysisLabel: signalTag.isNotEmpty ? signalTag : catalystLabel,
      affectedTickers: affectedTickers,
      publishedAt: DateTime.tryParse(fetchedAt) ?? DateTime.now(),
    );
  }

  Alert toAlert() {
    final dir = _mapDirection(direction);
    return Alert(
      id: id,
      ticker: primaryTicker,
      headline: title,
      direction: dir,
      label: _directionLabel(dir),
      receivedAt: DateTime.tryParse(fetchedAt) ?? DateTime.now(),
      isNew: _isNew(),
    );
  }

  bool _isNew() {
    final dt = DateTime.tryParse(fetchedAt);
    if (dt == null) return false;
    return DateTime.now().difference(dt).inHours < 2;
  }

  static SentimentDirection _mapDirection(String d) {
    switch (d.toLowerCase()) {
      case 'positive':
      case 'bullish':
        return SentimentDirection.positive;
      case 'negative':
      case 'bearish':
        return SentimentDirection.negative;
      default:
        return SentimentDirection.neutral;
    }
  }

  static String _directionLabel(SentimentDirection d) {
    switch (d) {
      case SentimentDirection.positive:
        return 'Bullish Signal';
      case SentimentDirection.negative:
        return 'Bearish Signal';
      case SentimentDirection.neutral:
        return 'Neutral';
    }
  }
}
