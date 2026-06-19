import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'presentation/providers/providers.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge: content renders behind status and gesture bars
  // (required behavior on Android 15+, standard on iOS).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ponytail: ONLY Firebase core is awaited (fast, reliable). Push init can
  // HANG on iOS waiting for an APNs token that never arrives — a hang isn't
  // caught by try/catch and leaves a permanent white screen. So it runs
  // fire-and-forget AFTER first paint; the UI never waits on it.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('[boot] Firebase init failed: $e');
  }

  runApp(const ProviderScope(child: ProfitAlertsApp()));

  // Push setup, off the critical path — failure or hang can't blank the app.
  NotificationService.instance
      .init()
      .catchError((Object e) => debugPrint('[boot] Notification init failed: $e'));
}

class _SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child; // remove glow effect on Android
}

class ProfitAlertsApp extends ConsumerWidget {
  const ProfitAlertsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'ProfitAlerts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      scrollBehavior: _SmoothScrollBehavior(),
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
