import '../models/feed_item_model.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class FeedService {
  final ApiClient _client;

  FeedService(this._client);

  Future<List<FeedItemModel>> getFeed({
    int page = 1,
    int perPage = 20,
    String? ticker,
    String? direction,
    String? q,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (direction != null && direction.isNotEmpty) params['direction'] = direction;
    if (q != null && q.isNotEmpty) params['q'] = q;

    final data = await _client.get(ApiEndpoints.mobileFeed, params: params);
    final rows = data['rows'];
    if (rows is List) {
      return rows
          .whereType<Map<String, dynamic>>()
          .map(FeedItemModel.fromJson)
          .toList();
    }
    return [];
  }

  Future<FeedItemModel?> getItem(String itemId) async {
    final data = await _client.get(ApiEndpoints.itemDetail(itemId));
    final item = data['item'];
    if (item is Map<String, dynamic>) return FeedItemModel.fromJson(item);
    return null;
  }

  /// Returns items filtered by direction — used for the Alerts tab.
  Future<List<FeedItemModel>> getAlertItems({String? direction}) async {
    final params = <String, dynamic>{'per_page': 30};
    if (direction != null && direction.isNotEmpty) params['direction'] = direction;

    final data = await _client.get(ApiEndpoints.dashboardInitial, params: params);
    final rows = _extractRows(data);
    if (direction == null) return rows;

    return rows.where((r) {
      final d = r.direction.toLowerCase();
      return d == direction || (direction == 'positive' && d == 'bullish') || (direction == 'negative' && d == 'bearish');
    }).toList();
  }

  /// Returns alerts from the dedicated /api/mobile/alerts endpoint.
  Future<List<Map<String, dynamic>>> getMobileAlerts({int limit = 30, int offset = 0}) async {
    final data = await _client.get(
      ApiEndpoints.alerts,
      params: {'limit': limit, 'offset': offset},
    );
    final alerts = data['alerts'];
    if (alerts is List) return alerts.whereType<Map<String, dynamic>>().toList();
    return [];
  }

  List<FeedItemModel> _extractRows(Map<String, dynamic> data) {
    final rows = <Map<String, dynamic>>[];

    final rawRows = data['rows'];
    if (rawRows is List) {
      for (final r in rawRows) {
        if (r is Map<String, dynamic>) rows.add(r);
      }
    }

    // Groups mode: flatten all group rows
    if (rows.isEmpty) {
      final groups = data['groups'];
      if (groups is List) {
        for (final g in groups) {
          if (g is! Map<String, dynamic>) continue;
          final gRows = g['rows'];
          if (gRows is List) {
            for (final r in gRows) {
              if (r is Map<String, dynamic>) rows.add(r);
            }
          }
        }
      }
    }

    return rows.map(FeedItemModel.fromJson).toList();
  }
}
