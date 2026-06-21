import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../services/notification_service.dart';
import '../../data/services/google_auth_service.dart';
import '../../data/repositories/api_news_repository.dart';
import '../../data/repositories/api_watchlist_repository.dart';
import '../../data/repositories/api_alerts_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/feed_service.dart';
import '../../data/services/watchlist_service.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/ticker.dart';
import '../../domain/entities/alert.dart';
import '../../domain/entities/user.dart';

// ── API infrastructure ─────────────────────────────────────────────────────────

final apiClientProvider = Provider((_) => apiClient);

final authServiceProvider = Provider((ref) => AuthService(ref.watch(apiClientProvider)));
final googleAuthServiceProvider = Provider((ref) => GoogleAuthService(ref.watch(apiClientProvider)));
final feedServiceProvider = Provider((ref) => FeedService(ref.watch(apiClientProvider)));
final watchlistServiceProvider = Provider((ref) => WatchlistService(ref.watch(apiClientProvider)));

// ── Repositories ──────────────────────────────────────────────────────────────

final newsRepoProvider = Provider((ref) => ApiNewsRepository(ref.watch(feedServiceProvider)));
final watchlistRepoProvider = Provider((ref) => ApiWatchlistRepository(ref.watch(watchlistServiceProvider)));
final alertsRepoProvider = Provider((ref) => ApiAlertsRepository(ref.watch(feedServiceProvider)));

// ── Auth ──────────────────────────────────────────────────────────────────────

const _demoEmail = 'demo@profitalerts.app';
const _demoPassword = 'demo123';
const _demoUser = AppUser(
  id: 'demo-user-1',
  email: _demoEmail,
  displayName: 'Alex Mercer',
  tier: UserTier.pro,
  alertsUsedThisMonth: 0,
);

// ── Auth init notifier — fires once session restore completes ─────────────────

class AuthInitNotifier extends ChangeNotifier {
  bool _ready = false;
  bool get ready => _ready;

  void setReady() {
    if (_ready) return;
    _ready = true;
    notifyListeners();
  }
}

final authInitProvider = ChangeNotifierProvider((_) => AuthInitNotifier());

// ── Auth ──────────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AppUser?> {
  final AuthService _auth;
  final VoidCallback _onReady;

  AuthNotifier(this._auth, this._onReady) : super(null) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      if (!await _auth.isLoggedIn()) {
        if (kDebugMode) debugPrint('[Auth] no stored token, skipping restore');
        return;
      }
      if (kDebugMode) debugPrint('[Auth] restoring session from stored token...');
      final response = await _auth.me();
      if (response.ok && response.user != null) {
        state = response.user!.toEntity();
        if (kDebugMode) debugPrint('[Auth] session restored: ${state?.email}');
        await _restoreSessionPushToken();
      } else {
        if (kDebugMode) debugPrint('[Auth] /me returned ok=${response.ok} error=${response.error}');
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[Auth] _restoreSession error: $e\n$st');
    } finally {
      _onReady();
    }
  }

  // Returns null on success, error message string on failure.
  Future<String?> login(String email, String password) async {
    if (email == _demoEmail && password == _demoPassword) {
      if (kDebugMode) debugPrint('[Auth] demo login — no API call, no token set');
      state = _demoUser;
      return null;
    }
    try {
      if (kDebugMode) debugPrint('[Auth] login attempt for $email');
      final response = await _auth.login(email, password);
      if (response.ok && response.user != null) {
        state = response.user!.toEntity();
        if (kDebugMode) debugPrint('[Auth] login OK: ${state?.email} tier=${state?.tier}');
        // Register FCM push token only for Pro users
        if (state?.canUsePushNotifications == true) {
          await NotificationService.instance.registerToken(apiClient);
        }
        return null;
      }
      final err = response.error ?? response.message ?? 'Login failed';
      if (kDebugMode) debugPrint('[Auth] login failed: ok=${response.ok} error=$err');
      return err;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[Auth] login error: $e\n$st');
      return e is ApiException ? e.message : e.toString();
    }
  }

  Future<void> _restoreSessionPushToken() async {
    // Re-register push token on session restore only for Pro users
    if (state?.canUsePushNotifications == true) {
      await NotificationService.instance.registerToken(apiClient);
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      final response = await _auth.register(email, password);
      if (response.ok && response.user != null) {
        state = response.user!.toEntity();
        if (state?.canUsePushNotifications == true) {
          await NotificationService.instance.registerToken(apiClient);
        }
        return null;
      }
      return response.error ?? response.message ?? 'Registration failed';
    } catch (e) {
      return e is ApiException ? e.message : e.toString();
    }
  }

  Future<String?> loginWithGoogle(GoogleAuthService googleAuth) async {
    try {
      final response = await googleAuth.signIn();
      if (response == null) return 'cancelled';
      if (response.ok && response.user != null) {
        state = response.user!.toEntity();
        if (state?.canUsePushNotifications == true) {
          await NotificationService.instance.registerToken(apiClient);
        }
        if (kDebugMode) debugPrint('[Auth] Google login OK: ${state?.email}');
        return null;
      }
      return response.error ?? response.message ?? 'Google sign-in failed';
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] Google login error: $e');
      return e is ApiException ? e.message : e.toString();
    }
  }

  Future<void> logout() async {
    // Unregister push token before clearing session
    await NotificationService.instance.unregisterToken(apiClient);
    try {
      await _auth.logout();
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] logout error: $e');
    }
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>(
  (ref) => AuthNotifier(
    ref.watch(authServiceProvider),
    () => ref.read(authInitProvider).setReady(),
  ),
);

// ── Theme ─────────────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark);

  void setMode(ThemeMode mode) => state = mode;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

// ── Language ──────────────────────────────────────────────────────────────────

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) => state = locale;
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());

// ── Preferences ───────────────────────────────────────────────────────────────

class PrefsNotifier extends StateNotifier<Map<String, bool>> {
  PrefsNotifier() : super({'pushEnabled': true, 'emailEnabled': false});

  void toggle(String key) {
    state = {...state, key: !(state[key] ?? false)};
  }
}

final prefsProvider = StateNotifierProvider<PrefsNotifier, Map<String, bool>>((ref) => PrefsNotifier());

// ── Feed ──────────────────────────────────────────────────────────────────────

class FeedFilter {
  final SentimentDirection? direction;
  final String? ticker;
  final bool watchlistOnly;
  const FeedFilter({this.direction, this.ticker, this.watchlistOnly = false});
  bool get hasFilter => direction != null || (ticker != null && ticker!.isNotEmpty) || watchlistOnly;
  FeedFilter copyWith({Object? direction = _sentinel, Object? ticker = _sentinel, bool? watchlistOnly}) => FeedFilter(
    direction: direction == _sentinel ? this.direction : direction as SentimentDirection?,
    ticker: ticker == _sentinel ? this.ticker : ticker as String?,
    watchlistOnly: watchlistOnly ?? this.watchlistOnly,
  );
}
const _sentinel = Object();

final feedFilterProvider = StateProvider<FeedFilter>((ref) => const FeedFilter());

// Free-text search over the feed (ticker / headline / affected tickers).
final feedSearchProvider = StateProvider<String>((ref) => '');

final feedProvider = FutureProvider<List<NewsItem>>((ref) async {
  final repo = ref.watch(newsRepoProvider);
  final filter = ref.watch(feedFilterProvider);
  final query = ref.watch(feedSearchProvider).trim();
  final watchlist = ref.watch(watchlistProvider);
  // Backend resolves q -> ticker, ingests on demand, and matches. Trust it;
  // re-filtering client-side by literal substring dropped valid hits
  // (e.g. "nvidia" -> NVDA news whose headline lacks the literal word).
  final items = await repo.getFeed(pageSize: 50, q: query.isEmpty ? null : query);

  if (!filter.hasFilter) return items;
  final base = items;

  // Watchlist symbols for filtering
  final watchlistSymbols = watchlist.maybeWhen(
    data: (tickers) => tickers.map((t) => t.symbol.toUpperCase()).toSet(),
    orElse: () => <String>{},
  );

  return base.where((item) {
    if (filter.watchlistOnly && watchlistSymbols.isNotEmpty) {
      final itemTickers = {...item.affectedTickers.map((s) => s.toUpperCase()), item.ticker.toUpperCase()};
      if (itemTickers.intersection(watchlistSymbols).isEmpty) return false;
    }
    if (filter.direction != null && item.direction != filter.direction) return false;
    if (filter.ticker != null && filter.ticker!.isNotEmpty) {
      final t = filter.ticker!.toUpperCase();
      if (!item.affectedTickers.any((s) => s.toUpperCase() == t) &&
          item.ticker.toUpperCase() != t) return false;
    }
    return true;
  }).toList();
});

final itemDetailProvider = FutureProvider.family<NewsItem, String>((ref, id) async {
  final repo = ref.watch(newsRepoProvider);
  final item = await repo.getItem(id);
  if (item == null) throw Exception('Item not found');
  return item;
});

// ── Watchlist ─────────────────────────────────────────────────────────────────

class WatchlistNotifier extends StateNotifier<AsyncValue<List<Ticker>>> {
  final ApiWatchlistRepository _repo;

  WatchlistNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    final tickers = await _repo.getWatchlist();
    state = AsyncValue.data(tickers);
  }

  Future<void> add(String symbol) async {
    await _repo.addTicker(symbol);
    await _load();
  }

  Future<void> remove(String symbol) async {
    await _repo.removeTicker(symbol);
    await _load();
  }

  Future<List<Ticker>> search(String query) => _repo.searchTickers(query);
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<Ticker>>>((ref) {
  final repo = ref.watch(watchlistRepoProvider);
  return WatchlistNotifier(repo);
});

// ── Alerts ────────────────────────────────────────────────────────────────────

enum AlertFilter { all, positive, negative, earnings }

class AlertsNotifier extends StateNotifier<AsyncValue<List<Alert>>> {
  final ApiAlertsRepository _repo;
  AlertFilter _filter = AlertFilter.all;

  AlertsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  AlertFilter get filter => _filter;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    SentimentDirection? dir;
    if (_filter == AlertFilter.positive) dir = SentimentDirection.positive;
    if (_filter == AlertFilter.negative) dir = SentimentDirection.negative;
    final alerts = await _repo.getAlerts(filter: dir);
    state = AsyncValue.data(alerts);
  }

  void setFilter(AlertFilter f) {
    _filter = f;
    _load();
  }
}

final alertsProvider = StateNotifierProvider<AlertsNotifier, AsyncValue<List<Alert>>>((ref) {
  final repo = ref.watch(alertsRepoProvider);
  return AlertsNotifier(repo);
});

final alertsUsedProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(alertsRepoProvider);
  return repo.getAlertsUsedThisMonth();
});

// ── Read/unread alert state (local, persisted) ─────────────────────────────
// ponytail: local-only via shared_preferences. No backend column/endpoint —
// add server sync only if read state needs to follow the user across devices.
class ReadAlertsNotifier extends StateNotifier<Set<String>> {
  static const _key = 'read_alert_ids';
  ReadAlertsNotifier() : super(<String>{}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }

  void markRead(String id) {
    if (state.contains(id)) {
      return;
    }
    state = {...state, id};
    _save();
  }

  void toggle(String id) {
    state = state.contains(id) ? (state.toSet()..remove(id)) : {...state, id};
    _save();
  }
}

final readAlertsProvider =
    StateNotifierProvider<ReadAlertsNotifier, Set<String>>((ref) => ReadAlertsNotifier());

// Single client-side filter for the Alerts screen (one active chip at a time).
enum AlertView { all, unread, read, positive, negative }

final alertViewProvider = StateProvider<AlertView>((ref) => AlertView.all);

// Selected ticker filter for the Alerts screen.
final alertTickerFilterProvider = StateProvider<String?>((ref) => null);
