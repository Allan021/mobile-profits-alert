import 'package:flutter/foundation.dart';

import '../../domain/entities/alert.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../services/feed_service.dart';

class ApiAlertsRepository implements AlertsRepository {
  final FeedService _feed;

  ApiAlertsRepository(this._feed);

  @override
  Future<List<Alert>> getAlerts({SentimentDirection? filter}) async {
    try {
      final rows = await _feed.getMobileAlerts(limit: 50);
      var alerts = rows.map(_rowToAlert).toList();
      if (filter != null) {
        alerts = alerts.where((a) => a.direction == filter).toList();
      }
      return alerts;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[Alerts] getAlerts error: $e\n$st');
      return [];
    }
  }

  @override
  Future<int> getAlertsUsedThisMonth() async {
    try {
      final rows = await _feed.getMobileAlerts(limit: 100);
      final now = DateTime.now();
      return rows.where((r) {
        final dt = DateTime.tryParse((r['sent_at'] ?? '').toString());
        return dt != null && dt.month == now.month && dt.year == now.year;
      }).length.clamp(0, 999);
    } catch (e) {
      if (kDebugMode) debugPrint('[Alerts] getAlertsUsedThisMonth error: $e');
      return 0;
    }
  }

  static Alert _rowToAlert(Map<String, dynamic> row) {
    final dirStr = (row['direction'] ?? '').toString().toLowerCase();
    final dir = switch (dirStr) {
      'positive' || 'bullish' => SentimentDirection.positive,
      'negative' || 'bearish' => SentimentDirection.negative,
      _ => SentimentDirection.neutral,
    };
    final sentAt = (row['sent_at'] ?? '').toString();
    final ticker = (row['ticker'] ?? '').toString();
    final newsItemId = (row['news_item_id'] ?? '').toString();
    return Alert(
      id: newsItemId.isNotEmpty ? newsItemId : '${ticker}_$sentAt',
      ticker: ticker,
      headline: (row['title'] ?? '').toString(),
      direction: dir,
      label: switch (dir) {
        SentimentDirection.positive => 'Bullish Signal',
        SentimentDirection.negative => 'Bearish Signal',
        SentimentDirection.neutral => 'Neutral',
      },
      receivedAt: DateTime.tryParse(sentAt) ?? DateTime.now(),
      isNew: _isRecent(sentAt),
    );
  }

  static bool _isRecent(String sentAt) {
    final dt = DateTime.tryParse(sentAt);
    if (dt == null) return false;
    return DateTime.now().difference(dt).inHours < 2;
  }
}
