import 'package:flutter/material.dart'
    show
        Listenable,
        CurvedAnimation,
        Curves,
        FadeTransition,
        SlideTransition,
        Offset,
        Tween;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/plans_screen.dart';
import '../../presentation/screens/shell/main_shell.dart';
import '../../presentation/screens/feed/feed_screen.dart';
import '../../presentation/screens/feed/item_detail_screen.dart';
import '../../presentation/screens/watchlist/watchlist_screen.dart';
import '../../presentation/screens/alerts/alerts_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/providers/providers.dart';
import '../../services/notification_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authProvider);
  ref.watch(authInitProvider);
  final ns = NotificationService.instance;
  final authInit = ref.read(authInitProvider);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([ns, authInit]),
    redirect: (context, state) {
      final ready = ref.read(authInitProvider).ready;
      final isSplash = state.matchedLocation == '/splash';

      if (!ready) return isSplash ? null : '/splash';

      final auth = ref.read(authProvider);
      final loggedIn = auth != null;
      final isAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (isSplash) return loggedIn ? '/' : '/login';
      if (!loggedIn && !isAuth) return '/login';
      if (loggedIn && isAuth) return '/';

      if (loggedIn && ns.pendingNavigationItemId != null) {
        final id = ns.pendingNavigationItemId!;
        ns.clearPendingNavigation();
        return '/item/$id?from=notification';
      }
      if (loggedIn && ns.pendingNavigationToAlerts) {
        ns.clearPendingNavigation();
        return '/alerts';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/plans', builder: (_, __) => const PlansScreen()),
      GoRoute(
        path: '/item/:id',
        // News detail enters like a sheet: slight rise + fade, exits fast.
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 340),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          child: ItemDetailScreen(
            itemId: state.pathParameters['id']!,
            fromNotification: state.uri.queryParameters['from'] == 'notification',
          ),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuint,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, __) => const FeedScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/watchlist', builder: (_, __) => const WatchlistScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/alerts', builder: (_, __) => const AlertsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen())]),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
