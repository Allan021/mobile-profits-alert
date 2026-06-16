import '../entities/alert.dart';
import '../entities/news_item.dart';

abstract class AlertsRepository {
  Future<List<Alert>> getAlerts({SentimentDirection? filter});
  Future<int> getAlertsUsedThisMonth();
}
