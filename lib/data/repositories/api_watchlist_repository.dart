import 'package:flutter/foundation.dart';

import '../../domain/entities/ticker.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../fake/fake_watchlist_data.dart';
import '../services/watchlist_service.dart';

class ApiWatchlistRepository implements WatchlistRepository {
  final WatchlistService _service;
  final List<Ticker> _local = [];

  ApiWatchlistRepository(this._service);

  @override
  Future<List<Ticker>> getWatchlist() async {
    try {
      final symbols = await _service.getWatchlistTickers();
      if (symbols.isNotEmpty) {
        _local
          ..clear()
          ..addAll(symbols.map(_symbolToTicker));
        return List.from(_local);
      }
      if (kDebugMode) debugPrint('[Watchlist] getWatchlist returned 0 symbols, using local/fake');
    } catch (e, st) {
      if (kDebugMode) debugPrint('[Watchlist] getWatchlist error: $e\n$st');
    }
    return List.from(_local);
  }

  @override
  Future<void> addTicker(String symbol) async {
    final symbols = await _service.addTicker(symbol);
    _local
      ..clear()
      ..addAll(symbols.map(_symbolToTicker));
  }

  @override
  Future<void> removeTicker(String symbol) async {
    final symbols = await _service.removeTicker(symbol);
    _local
      ..clear()
      ..addAll(symbols.map(_symbolToTicker));
  }

  @override
  Future<List<Ticker>> searchTickers(String query) async {
    try {
      final results = await _service.searchTickers(query);
      return results.map((r) => Ticker(
        symbol: r['symbol'] as String? ?? '',
        companyName: r['company'] as String? ?? '',
        sentimentScore: 0,
        trend: TickerTrend.flat,
      )).where((t) => t.symbol.isNotEmpty).toList();
    } catch (e, st) {
      if (kDebugMode) debugPrint('[Watchlist] searchTickers($query) error: $e\n$st');
      // Backend not deployed yet — fall back to local ticker list
      if (query.isEmpty) return fakeSearchResults;
      final q = query.toUpperCase();
      return fakeSearchResults
          .where((t) =>
              t.symbol.contains(q) || t.companyName.toUpperCase().contains(q))
          .toList();
    }
  }

  Ticker _symbolToTicker(String symbol) {
    return Ticker(
      symbol: symbol,
      companyName: symbol,
      sentimentScore: 0,
      trend: TickerTrend.flat,
    );
  }
}
