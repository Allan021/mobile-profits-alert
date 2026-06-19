import '../../core/constants/app_constants.dart';

enum UserTier { free, pro }

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final UserTier tier;
  final int alertsUsedThisMonth;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.tier,
    required this.alertsUsedThisMonth,
  });

  bool get isFree => tier == UserTier.free;
  bool get isPro => tier == UserTier.pro;

  int get alertQuota => isFree ? kFreeAlertQuota : 999999;
  int get watchlistLimit => isFree ? kFreeWatchlistMax : 999999;
  bool get quotaExceeded => isFree && alertsUsedThisMonth >= kFreeAlertQuota;
  // Free tier can enable push too; the daily cap is enforced server-side.
  bool get canUsePushNotifications => true;
  bool get canUseRealTimeAlerts => isPro;
  bool get canUseAdvancedFilters => isPro;
}
