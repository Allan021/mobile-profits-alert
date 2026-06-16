import '../../domain/entities/ticker.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../fake/fake_watchlist_data.dart';

class FakeWatchlistRepository implements WatchlistRepository {
  final List<Ticker> _watchlist = List.from(fakeWatchlist);

  @override
  Future<List<Ticker>> getWatchlist() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_watchlist);
  }

  @override
  Future<void> addTicker(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final ticker = fakeSearchResults.firstWhere(
      (t) => t.symbol == symbol,
      orElse: () => Ticker(symbol: symbol, companyName: symbol, sentimentScore: 0, trend: TickerTrend.flat),
    );
    if (!_watchlist.any((t) => t.symbol == symbol)) {
      _watchlist.add(ticker);
    }
  }

  @override
  Future<void> removeTicker(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _watchlist.removeWhere((t) => t.symbol == symbol);
  }

  @override
  Future<List<Ticker>> searchTickers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return fakeSearchResults;
    final q = query.toUpperCase();
    return fakeSearchResults
        .where((t) => t.symbol.contains(q) || t.companyName.toUpperCase().contains(q))
        .toList();
  }
}
