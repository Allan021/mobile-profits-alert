const kApiBaseUrl = 'https://www.profitalerts.app';

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/api/mobile/auth/login';
  static const String register = '/api/mobile/auth/register';
  static const String googleAuth = '/api/mobile/auth/google';
  static const String me = '/api/mobile/auth/me';

  // User / settings
  static const String userSettings = '/api/mobile/user/settings';
  static const String userProfile = '/api/mobile/user/profile';
  static const String userChangePassword = '/api/mobile/user/change-password';
  static const String userPreferences = '/api/mobile/user/preferences';
  static const String deleteAccount = '/api/mobile/user/account';
  static const String watchlistAdd = '/api/mobile/user/watchlist/add';
  static const String watchlistRemove = '/api/mobile/user/watchlist/remove';

  // Mobile feed (dedicated — uses cross-user analyses, works for new users)
  static const String mobileFeed = '/api/mobile/feed';

  // Dashboard (authenticated — same endpoints as web)
  static const String dashboardInitial = '/api/dashboard/initial';
  static const String dashboardSecondary = '/api/dashboard/secondary';
  static const String dashboardLive = '/api/dashboard/live';

  // Alerts
  static const String alerts = '/api/mobile/alerts';
  static const String alertsDismiss = '/api/mobile/alerts/dismiss';
  static const String alertsDismissAll = '/api/mobile/alerts/dismiss-all';
  static const String testPush = '/api/mobile/alerts/test-push';
  static const String seedTestAlert = '/api/mobile/alerts/seed-test';

  // Device tokens (push notifications)
  static const String registerToken = '/api/mobile/device-tokens/register';
  static const String unregisterToken = '/api/mobile/device-tokens/unregister';

  // Ticker search (public)
  static String tickerSearch(String q) =>
      '/api/mobile/tickers/search${q.isEmpty ? '' : '?q=${Uri.encodeQueryComponent(q)}'}';

  // Item detail
  static String itemDetail(String itemId) => '/api/mobile/items/$itemId';

  // Health (public)
  static const String health = '/health';
}
