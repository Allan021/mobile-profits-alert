import '../../domain/entities/alert.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../fake/fake_alerts_data.dart';

class FakeAlertsRepository implements AlertsRepository {
  @override
  Future<List<Alert>> getAlerts({SentimentDirection? filter}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (filter == null) return fakeAlerts;
    return fakeAlerts.where((a) => a.direction == filter).toList();
  }

  @override
  Future<int> getAlertsUsedThisMonth() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 2;
  }
}
