import 'package:flutter/foundation.dart';

import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../services/feed_service.dart';

class ApiNewsRepository implements NewsRepository {
  final FeedService _feed;

  ApiNewsRepository(this._feed);

  @override
  Future<List<NewsItem>> getFeed({int page = 0, int pageSize = 20}) async {
    try {
      final items = await _feed.getFeed(page: page + 1, perPage: pageSize);
      return items.map((m) => m.toNewsItem()).toList();
    } catch (e, st) {
      if (kDebugMode) debugPrint('[News] getFeed error: $e\n$st');
      return [];
    }
  }

  @override
  Future<NewsItem?> getItem(String id) async {
    try {
      final item = await _feed.getItem(id);
      return item?.toNewsItem();
    } catch (e, st) {
      if (kDebugMode) debugPrint('[News] getItem($id) error: $e\n$st');
      return null;
    }
  }

  @override
  Future<List<NewsItem>> getByTicker(String ticker) async {
    try {
      final items = await _feed.getFeed(ticker: ticker, perPage: 30);
      return items.map((m) => m.toNewsItem()).toList();
    } catch (e, st) {
      if (kDebugMode) debugPrint('[News] getByTicker($ticker) error: $e\n$st');
      return [];
    }
  }
}
