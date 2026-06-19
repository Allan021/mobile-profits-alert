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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final user = ref.watch(authProvider);
    final alerts = ref.watch(alertsProvider);
    final filter = ref.watch(alertsProvider.notifier).filter;

    final tabs = [l.allAlerts, l.positive, l.negative, l.earnings];
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
                children: List.generate(tabs.length, (i) {
                  final filterVal = AlertFilter.values[i];
                  final selected = filter == filterVal;
                  return GestureDetector(
                    onTap: () =>
                        ref.read(alertsProvider.notifier).setFilter(filterVal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                      ),
                      child: Text(
                        tabs[i],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? (isDark ? AppColors.black : AppColors.white)
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }),
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

                  final filtered = selectedTicker == null
                      ? items
                      : items.where((a) => a.ticker.toUpperCase() == selectedTicker.toUpperCase()).toList();
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Text(
                'Not financial advice. Profit Alerts provides AI-generated market signal summaries for informational purposes only. '
                'Not a recommendation to buy, sell, or hold any security. Consult a qualified financial advisor before making investment decisions.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  height: 1.5,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ),
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

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final bool isDark;
  final Color primary;

  const _AlertCard(
      {required this.alert, required this.isDark, required this.primary});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${alert.receivedAt.hour.toString().padLeft(2, '0')}:${alert.receivedAt.minute.toString().padLeft(2, '0')} ${alert.receivedAt.hour < 12 ? 'AM' : 'PM'}';
    return GestureDetector(
      onTap: () => context.push('/item/${alert.id}'),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
        ],
      ),
      ),
    );
  }
}
