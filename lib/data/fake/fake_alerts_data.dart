import '../../domain/entities/alert.dart';
import '../../domain/entities/news_item.dart';

final List<Alert> fakeAlerts = [
  Alert(
    id: 'a1',
    ticker: 'TSLA',
    headline: 'Significant drop in sentiment detected following recent production reports. High volume of bearish options activity.',
    direction: SentimentDirection.negative,
    label: 'High Negative',
    receivedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 18)),
    isNew: true,
  ),
  Alert(
    id: 'a2',
    ticker: 'NVDA',
    headline: 'Unusual options activity indicating bullish sentiment ahead of earnings call. Upward momentum building.',
    direction: SentimentDirection.positive,
    label: 'Strong Buy',
    receivedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    isNew: true,
  ),
  Alert(
    id: 'a3',
    ticker: 'AAPL',
    headline: 'Scheduled product announcement starting in 1 hour. Expect increased volatility in tech sector.',
    direction: SentimentDirection.neutral,
    label: 'Event',
    receivedAt: DateTime.now().subtract(const Duration(hours: 4)),
    isNew: false,
  ),
  Alert(
    id: 'a4',
    ticker: 'META',
    headline: 'Regulatory news causing minor sell-off pressure. Sentiment remains cautious.',
    direction: SentimentDirection.negative,
    label: 'Moderate Negative',
    receivedAt: DateTime.now().subtract(const Duration(days: 1, hours: 8, minutes: 15)),
    isNew: false,
  ),
  Alert(
    id: 'a5',
    ticker: 'MSFT',
    headline: 'Azure AI revenue milestone boosts investor confidence. Analysts raise price targets.',
    direction: SentimentDirection.positive,
    label: 'Strong Buy',
    receivedAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
    isNew: false,
  ),
];
