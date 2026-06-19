import 'package:flutter/material.dart';
import '../../widgets/shimmer_loading.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/alert.dart';
import '../../../domain/entities/news_item.dart' show SentimentDirection;
import '../../providers/providers.dart';
import '../../widgets/sentiment_badge.dart';

final _alertTickerFilterProvider = StateProvider<String?>((ref) => null);

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  Future<void> _sendTestPush(BuildContext context, WidgetRef ref, bool isDark) async {
    final user = ref.read(authProvider);
    if (user == null || user.isFree) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Push notifications require a Pro subscription.'),
        backgroundColor: AppColors.negativeLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await apiClient.post(ApiEndpoints.testPush);
      if (!context.mounted) return;
    } on ApiException catch (e) {
      if (!context.mounted) return;
      final msg = e.statusCode == 404
          ? 'No registered devices. Open the app fresh to register.'
          : e.statusCode == 503
              ? 'Push not configured on server yet.'
              : e.message;
      messenger.showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.negativeLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final es = Localizations.localeOf(context).languageCode == 'es';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final user = ref.watch(authProvider);
    final alerts = ref.watch(alertsProvider);
    final view = ref.watch(alertViewProvider);
    final readIds = ref.watch(readAlertsProvider);

    final watchlistSymbols = ref.watch(watchlistProvider).maybeWhen(
      data: (tickers) => tickers.map((t) => t.symbol).toList(),
      orElse: () => <String>[],
    );
    final selectedTicker = ref.watch(_alertTickerFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
              child: Row(
                children: [
                  Image.asset(
                    isDark ? 'assets/icons/l2.png' : 'assets/icons/l1.png',
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  if (user != null && !user.isFree)
                    IconButton(
                      icon: const Icon(Icons.notifications_active_outlined),
                      tooltip: 'Test push notification',
                      color: AppColors.textMutedDark,
                      onPressed: () => _sendTestPush(context, ref, isDark),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Clear all alerts',
                    color: AppColors.textMutedDark,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                          title: Text('Clear all alerts', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                          content: Text('This will remove all your alerts. Cannot be undone.',
                              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogCtx, false),
                                child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted))),
                            TextButton(onPressed: () => Navigator.pop(dialogCtx, true),
                                child: Text('Clear', style: GoogleFonts.inter(color: AppColors.negativeDark, fontWeight: FontWeight.w700))),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await apiClient.post(ApiEndpoints.alertsDismissAll);
                          ref.invalidate(alertsProvider);
                        } catch (_) {}
                      }
                    },
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(l.alerts,
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700))
                  .animate(delay: 60.ms).fadeIn(duration: 280.ms),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final v in AlertView.values) ...[
                    _FilterChip(
                      label: _viewLabel(l, v, es),
                      icon: v == AlertView.positive
                          ? Icons.trending_up
                          : v == AlertView.negative
                              ? Icons.trending_down
                              : v == AlertView.unread
                                  ? Icons.circle
                                  : null,
                      selected: view == v,
                      primary: primary,
                      isDark: isDark,
                      onTap: () =>
                          ref.read(alertViewProvider.notifier).state = v,
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 280.ms),

            // Watchlist ticker chips
            if (watchlistSymbols.isNotEmpty) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(_alertTickerFilterProvider.notifier).state = null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedTicker == null ? primary.withValues(alpha: 0.14) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedTicker == null ? primary.withValues(alpha: 0.6) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: selectedTicker == null ? 1.5 : 1,
                          ),
                        ),
                        child: Text('All', style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: selectedTicker == null ? primary : AppColors.textMutedDark,
                        )),
                      ),
                    ),
                    ...watchlistSymbols.map((sym) {
                      final isSelected = selectedTicker == sym;
                      return GestureDetector(
                        onTap: () => ref.read(_alertTickerFilterProvider.notifier).state = isSelected ? null : sym,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? primary.withValues(alpha: 0.14) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? primary.withValues(alpha: 0.6) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(sym, style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: isSelected ? primary : AppColors.textMutedDark,
                          )),
                        ),
                      );
                    }),
                  ],
                ),
              ).animate(delay: 120.ms).fadeIn(duration: 260.ms),
            ],

            const SizedBox(height: 12),
            Expanded(
              child: alerts.when(
                loading: () => ListView.builder(
                  itemCount: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ShimmerBox(height: 80, radius: 12)
                        .animate(delay: Duration(milliseconds: i * 70))
                        .fadeIn(duration: 280.ms),
                  ),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: primary.withValues(alpha: 0.25), width: 1.5),
                              ),
                              child: Icon(Icons.notifications_outlined,
                                  size: 32, color: primary),
                            ),
                            const SizedBox(height: 20),
                            Text('No alerts yet',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.black)),
                            const SizedBox(height: 10),
                            Text(
                              'Your market alerts will appear here once the pipeline processes your watchlist tickers.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  height: 1.55,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                  }

                  final filtered = items.where((a) {
                    if (selectedTicker != null &&
                        a.ticker.toUpperCase() != selectedTicker.toUpperCase()) {
                      return false;
                    }
                    switch (view) {
                      case AlertView.unread:
                        return !readIds.contains(a.id);
                      case AlertView.read:
                        return readIds.contains(a.id);
                      case AlertView.positive:
                        return a.direction == SentimentDirection.positive;
                      case AlertView.negative:
                        return a.direction == SentimentDirection.negative;
                      case AlertView.all:
                        return true;
                    }
                  }).toList();
                  final todayItems =
                      filtered.where((a) => _isToday(a.receivedAt)).toList();
                  final yesterdayItems =
                      filtered.where((a) => _isYesterday(a.receivedAt)).toList();

                  int cardIndex = 0;
                  final children = <Widget>[];

                  if (todayItems.isNotEmpty) {
                    children.add(const _SectionHeader(label: 'Today'));
                    for (final a in todayItems) {
                      final idx = cardIndex++;
                      children.add(
                        Dismissible(
                          key: Key(a.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.negativeDark.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.negativeDark, size: 22),
                          ),
                          onDismissed: (_) async {
                            try {
                              await apiClient.post(ApiEndpoints.alertsDismiss, data: {
                                'ticker': a.ticker,
                                'sent_at': a.receivedAt.toIso8601String(),
                              });
                              ref.invalidate(alertsProvider);
                            } catch (_) {}
                          },
                          child: _AlertCard(alert: a, isDark: isDark, primary: primary),
                        )
                            .animate(delay: Duration(milliseconds: (idx * 55).clamp(0, 400)))
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: -0.06, end: 0, curve: Curves.easeOutCubic),
                      );
                    }
                  }

                  if (yesterdayItems.isNotEmpty) {
                    children.add(const _SectionHeader(label: 'Yesterday'));
                    for (final a in yesterdayItems) {
                      final idx = cardIndex++;
                      children.add(
                        Dismissible(
                          key: Key('y_${a.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.negativeDark.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.negativeDark, size: 22),
                          ),
                          onDismissed: (_) async {
                            try {
                              await apiClient.post(ApiEndpoints.alertsDismiss, data: {
                                'ticker': a.ticker,
                                'sent_at': a.receivedAt.toIso8601String(),
                              });
                            } catch (_) {}
                          },
                          child: _AlertCard(alert: a, isDark: isDark, primary: primary),
                        )
                            .animate(delay: Duration(milliseconds: (idx * 55).clamp(0, 400)))
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: -0.06, end: 0, curve: Curves.easeOutCubic),
                      );
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: children,
                  );
                },
              ),
            ),
            _DisclaimerBar(isDark: isDark),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
  }

  bool _isYesterday(DateTime dt) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return dt.year == y.year && dt.month == y.month && dt.day == y.day;
  }
}


class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.8),
        ),
      );
}

class _AlertCard extends ConsumerWidget {
  final Alert alert;
  final bool isDark;
  final Color primary;

  const _AlertCard(
      {required this.alert, required this.isDark, required this.primary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final read = ref.watch(readAlertsProvider).contains(alert.id);
    final timeStr =
        '${alert.receivedAt.hour.toString().padLeft(2, '0')}:${alert.receivedAt.minute.toString().padLeft(2, '0')} ${alert.receivedAt.hour < 12 ? 'AM' : 'PM'}';
    return GestureDetector(
      onTap: () {
        ref.read(readAlertsProvider.notifier).markRead(alert.id);
        context.push('/item/${alert.id}');
      },
      // long-press toggles seen / unseen
      onLongPress: () => ref.read(readAlertsProvider.notifier).toggle(alert.id),
      child: AnimatedOpacity(
      opacity: read ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: read
                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: alert.direction == SentimentDirection.positive
                ? (isDark
                    ? AppColors.positiveBadgeDark
                    : AppColors.positiveBadgeLight)
                : alert.direction == SentimentDirection.negative
                    ? (isDark
                        ? AppColors.negativeBadgeDark
                        : AppColors.negativeBadgeLight)
                    : const Color(0xFF1C1500),
            child: Icon(
              alert.direction == SentimentDirection.positive
                  ? Icons.trending_up
                  : alert.direction == SentimentDirection.negative
                      ? Icons.trending_down
                      : Icons.remove,
              size: 16,
              color: alert.direction == SentimentDirection.positive
                  ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  : alert.direction == SentimentDirection.negative
                      ? (isDark
                          ? AppColors.negativeDark
                          : AppColors.negativeLight)
                      : AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(alert.ticker,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primary)),
                    const SizedBox(width: 8),
                    SentimentBadge(
                        direction: alert.direction,
                        label: alert.label,
                        small: true),
                    const Spacer(),
                    Text(timeStr,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.headline,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFCDD5E0)
                          : const Color(0xFF475569),
                      height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // unread dot
          if (!read) ...[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
      ),
      ),
    );
  }
}

/// Compact, tappable legal disclaimer. Collapsed to one line by default so it
/// stops eating half the Alerts screen; expands on tap. Can't be removed
/// entirely (App Store requires it on financial apps), but it can be tiny.
class _DisclaimerBar extends StatefulWidget {
  final bool isDark;
  const _DisclaimerBar({required this.isDark});

  @override
  State<_DisclaimerBar> createState() => _DisclaimerBarState();
}

class _DisclaimerBarState extends State<_DisclaimerBar> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted.withValues(alpha: 0.6);
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      behavior: HitTestBehavior.opaque,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 12, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _open
                      ? 'Not financial advice. Profit Alerts provides AI-generated market signal summaries for informational purposes only. '
                          'Not a recommendation to buy, sell, or hold any security. Consult a qualified financial advisor before making investment decisions.'
                      : 'Not financial advice — informational only. Tap to read more.',
                  maxLines: _open ? null : 1,
                  overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 10, height: 1.5, color: muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _viewLabel(AppLocalizations l, AlertView v, bool es) {
  switch (v) {
    case AlertView.all:
      return l.allAlerts;
    case AlertView.unread:
      return es ? 'Sin leer' : 'Unread';
    case AlertView.read:
      return es ? 'Leídas' : 'Read';
    case AlertView.positive:
      return l.positive;
    case AlertView.negative:
      return l.negative;
  }
}

/// Compact filter chip for the Alerts toolbar (one active at a time).
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.primary,
    required this.isDark,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primary.withValues(alpha: 0.6) : border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: selected ? primary : AppColors.textMutedDark),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? primary : AppColors.textMutedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
