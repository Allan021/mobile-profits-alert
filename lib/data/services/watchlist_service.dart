import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class WatchlistService {
  final ApiClient _client;

  WatchlistService(this._client);

  Future<List<String>> getWatchlistTickers() async {
    final data = await _client.get(ApiEndpoints.userSettings);
    final tickers = data['watchlist_tickers'];
    if (tickers is List) return tickers.map((e) => e.toString()).toList();
    return [];
  }

  Future<List<String>> addTicker(String ticker) async {
    final data = await _client.post(
      ApiEndpoints.watchlistAdd,
      data: {'ticker': ticker},
    );
    final tickers = data['watchlist_tickers'];
    if (tickers is List) return tickers.map((e) => e.toString()).toList();
    return [];
  }

  Future<List<String>> removeTicker(String ticker) async {
    final data = await _client.post(
      ApiEndpoints.watchlistRemove,
      data: {'ticker': ticker},
    );
    final tickers = data['watchlist_tickers'];
    if (tickers is List) return tickers.map((e) => e.toString()).toList();
    return [];
  }

  Future<List<Map<String, dynamic>>> searchTickers(String query) async {
    final data = await _client.get(ApiEndpoints.tickerSearch(query));
    final results = data['results'];
    if (results is List) {
      return results.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
