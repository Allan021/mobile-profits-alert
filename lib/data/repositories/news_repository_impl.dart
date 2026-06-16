import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../fake/fake_news_data.dart';

class FakeNewsRepository implements NewsRepository {
  @override
  Future<List<NewsItem>> getFeed({int page = 0, int pageSize = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final start = page * pageSize;
    if (start >= fakeNewsFeed.length) return [];
    return fakeNewsFeed.skip(start).take(pageSize).toList();
  }

  @override
  Future<NewsItem> getItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return fakeNewsFeed.firstWhere((n) => n.id == id);
  }

  @override
  Future<List<NewsItem>> getByTicker(String ticker) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return fakeNewsFeed.where((n) => n.affectedTickers.contains(ticker)).toList();
  }
}
