# ProfitAlerts Mobile — Demo Guide

## Prerequisites

- Flutter 3.x (`flutter --version`)
- Android Studio or Xcode (for device/emulator)
- Java 11+ for Android builds (`java -version`)

## Run Demo (fastest)

```bash
cd mobile

# Install deps
flutter pub get

# Run on connected device or emulator
flutter run
```

## Demo Credentials

| Field | Value |
|-------|-------|
| Email | `demo@profitalerts.app` |
| Password | `demo123` |

Or tap **Continue with Google** — enters directly.

## Demo Flow

```
1. Login screen → enter credentials → Sign In
2. Plans screen → choose Free / Pro / Elite
   - "Start Free" → enters app
   - "Subscribe" → shows "Payment coming soon" snackbar
3. Feed (Market Feed)
   - News cards: ticker + POSITIVE/NEGATIVE badge + AI Confidence bar
   - Tap any card → Item Detail with full AI analysis
4. Watchlist
   - Shows MSFT, GOOGL, NVDA, TSLA with sentiment scores
   - Tap + → search and add more tickers (AMD, AAPL, NFLX, etc.)
   - Swipe remove icon to remove ticker
5. Alerts
   - Free tier banner: "2 of 3 alerts used this month"
   - Filter tabs: All / Positive / Negative / Earnings
6. Settings
   - Toggle Push / Email notifications
   - Change Appearance: Dark / Light / System
   - Switch language: English / Español
   - Log Out → back to login
```

## Language Switch

Settings → LANGUAGE → select Español. Full UI switches immediately. Switch back to English same way.

## Theme Switch

Settings → PREFERENCES → Appearance → choose Dark / Light / System.

## Build for Android (requires Java 11+)

```bash
# Install Java 11 (if needed)
# Windows: https://adoptium.net/

# Debug APK
flutter build apk --debug

# Release APK (needs signing config)
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

## Build for iOS (macOS + Xcode required)

```bash
# Debug
flutter build ios --debug --no-codesign

# Release (requires Apple Developer account + certificates)
flutter build ios --release
```

## Play Store Deployment

1. `flutter build appbundle --release`
2. Output: `build/app/outputs/bundle/release/app-release.aab`
3. Upload to Google Play Console → Production track

## App Store Deployment

1. macOS with Xcode 15+
2. `flutter build ios --release`
3. Open `mobile/ios/Runner.xcworkspace` in Xcode
4. Product → Archive → Distribute App → App Store Connect

## App IDs

| Platform | Bundle ID |
|----------|-----------|
| Android | `com.profitalerts.profitalerts` |
| iOS | `com.profitalerts.profitalerts` |

## Architecture

```
mobile/lib/
├── core/
│   ├── theme/        — AppTheme (dark + light), AppColors
│   ├── router/       — GoRouter with auth redirect
│   ├── l10n/         — ARB files (EN, ES) + generated Dart
│   └── constants/    — Demo credentials, quota limits
├── domain/
│   ├── entities/     — NewsItem, Ticker, Alert, AppUser
│   ├── repositories/ — Abstract interfaces
│   └── usecases/     — (ready for use cases)
├── data/
│   ├── fake/         — Fake news, watchlist, alerts data
│   └── repositories/ — Fake implementations
└── presentation/
    ├── providers/    — Riverpod state (auth, feed, watchlist, alerts, theme, locale)
    ├── screens/      — Login, Register, Plans, Feed, Item, Watchlist, Alerts, Settings
    └── widgets/      — NewsCard, SentimentBadge, ConfidenceBar
```

## Backend Integration (next step)

Replace fake repositories in `data/repositories/` with real API calls:

```dart
// data/repositories/news_repository_impl.dart
// Replace FakeNewsRepository with:
class ApiNewsRepository implements NewsRepository {
  final Dio _dio;
  
  @override
  Future<List<NewsItem>> getFeed({int page = 0, int pageSize = 20}) async {
    final response = await _dio.get('/api/v1/feed', queryParameters: {'page': page});
    return (response.data['items'] as List).map(NewsItemModel.fromJson).toList();
  }
}
```

Auth: replace `AuthNotifier.login()` with `supabase_flutter` calls.
