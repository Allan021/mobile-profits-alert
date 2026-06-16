enum SentimentDirection { positive, negative, neutral }

class NewsItem {
  final String id;
  final String ticker;
  final String headline;
  final String source;
  final String author;
  final String? url;
  final SentimentDirection direction;
  final int confidence;
  final String rationale;
  final String analysisLabel;
  final List<String> affectedTickers;
  final DateTime publishedAt;

  const NewsItem({
    required this.id,
    required this.ticker,
    required this.headline,
    required this.source,
    required this.author,
    this.url,
    required this.direction,
    required this.confidence,
    required this.rationale,
    required this.analysisLabel,
    required this.affectedTickers,
    required this.publishedAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
