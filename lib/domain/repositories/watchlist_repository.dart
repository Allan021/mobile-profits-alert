import '../entities/ticker.dart';

abstract class WatchlistRepository {
  Future<List<Ticker>> getWatchlist();
  Future<void> addTicker(String symbol);
  Future<void> removeTicker(String symbol);
  Future<List<Ticker>> searchTickers(String query);
}
