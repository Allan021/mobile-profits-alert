import '../entities/news_item.dart';

abstract class NewsRepository {
  Future<List<NewsItem>> getFeed({int page = 0, int pageSize = 20});
  Future<NewsItem?> getItem(String id);
  Future<List<NewsItem>> getByTicker(String ticker);
}
