import 'news_item.dart';

class Alert {
  final String id;
  final String ticker;
  final String headline;
  final SentimentDirection direction;
  final String label;
  final DateTime receivedAt;
  final bool isNew;

  const Alert({
    required this.id,
    required this.ticker,
    required this.headline,
    required this.direction,
    required this.label,
    required this.receivedAt,
    this.isNew = false,
  });
}
