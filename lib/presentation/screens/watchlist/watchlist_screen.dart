import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/news_item.dart';
import '../../../domain/entities/ticker.dart';
import '../../providers/providers.dart';
import '../../widgets/sparkline_widget.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(watchlistProvider.notifier).search(q);
    });
  }

  String _friendlyError(Object e) {
    if (e is ApiException) {
      if (e.statusCode == 401) return 'Session expired — please log in again.';
      if (e.statusCode == 400) return 'Invalid ticker symbol.';
      if (e.statusCode == 0) return 'No connection. Check your internet.';
      return 'Error ${e.statusCode}: ${e.message}';
    }
    return 'Something went wrong. Try again.';
  }

  void _showUpgradeDialog() {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.upgradeToPro,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          l.watchlistLimitReached(kFreeWatchlistMax),
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          // hidden on iOS — App Store guideline 3.1.1 (external billing)
          if (kShowExternalBilling)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/plans');
              },
              child: Text(l.seePlans,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final user = ref.read(authProvider);
    final currentList = ref.read(watchlistProvider).value ?? [];
    if (user != null &&
        user.isFree &&
        currentList.length >= kFreeWatchlistMax) {
      _showUpgradeDialog();
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _AddTickerSheet(
        onAdd: (symbol) async {
          try {
            await ref.read(watchlistProvider.notifier).add(symbol);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)!.tickerAdded),
                backgroundColor: AppColors.primaryDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            }
          } catch (e) {
            if (mounted) {
              final msg = _friendlyError(e);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg),
                backgroundColor: AppColors.negativeLight,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Image.asset(
                    isDark ? 'assets/icons/l2.png' : 'assets/icons/l1.png',
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        isDark ? AppColors.darkCard : AppColors.lightBorder,
                    child: Text('A',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primary)),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(l.watchlist,
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700))
                  .animate(delay: 60.ms).fadeIn(duration: 280.ms),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: l.searchTickers,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: GestureDetector(
                    onTap: _showAddDialog,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(6)),
                      child: Icon(Icons.add,
                          color: isDark ? AppColors.black : AppColors.white,
                          size: 18),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: _search,
              ),
            ).animate(delay: 60.ms).fadeIn(duration: 280.ms),
            const SizedBox(height: 12),
            Expanded(
              child: watchlist.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (tickers) {
                  if (tickers.isEmpty) {
                    return _EmptyState(
                            l: l, primary: primary, onAdd: _showAddDialog)
                        .animate()
                        .fadeIn(duration: 400.ms);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: tickers.length,
                    itemBuilder: (_, i) => _TickerRow(
                      ticker: tickers[i],
                      isDark: isDark,
                      primary: primary,
                      onTap: () {
                        ref.read(alertTickerFilterProvider.notifier).state = tickers[i].symbol;
                        context.go('/alerts');
                      },
                      onRemove: () async {
                        try {
                          await ref
                              .read(watchlistProvider.notifier)
                              .remove(tickers[i].symbol);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(_friendlyError(e)),
                              backgroundColor: AppColors.negativeLight,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ));
                          }
                          return;
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text(l.tickerRemoved),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ));
                        }
                      },
                    )
                        .animate(
                          delay: Duration(
                              milliseconds: (i * 60).clamp(0, 400)),
                        )
                        .fadeIn(duration: 300.ms)
                        .slideX(
                          begin: 0.06,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TickerRow extends StatefulWidget {
  final Ticker ticker;
  final bool isDark;
  final Color primary;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _TickerRow({
    required this.ticker,
    required this.isDark,
    required this.primary,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<_TickerRow> createState() => _TickerRowState();
}

class _TickerRowState extends State<_TickerRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final ticker = widget.ticker;

    final trendColor = ticker.trend == TickerTrend.up
        ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
        : ticker.trend == TickerTrend.down
            ? (isDark ? AppColors.negativeDark : AppColors.negativeLight)
            : AppColors.textMutedDark;

    final direction = ticker.trend == TickerTrend.up
        ? SentimentDirection.positive
        : ticker.trend == TickerTrend.down
            ? SentimentDirection.negative
            : SentimentDirection.neutral;

    final isUp = ticker.trend == TickerTrend.up;
    final isDown = ticker.trend == TickerTrend.down;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed
                  ? trendColor.withValues(alpha: 0.4)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: _pressed ? 1.5 : 1,
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 3)),
                    BoxShadow(color: trendColor.withValues(alpha: 0.04), blurRadius: 16, spreadRadius: -2),
                  ]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              // Avatar with gradient
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      trendColor.withValues(alpha: 0.25),
                      trendColor.withValues(alpha: 0.10),
                    ],
                  ),
                  border: Border.all(color: trendColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    ticker.symbol[0],
                    style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: trendColor),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Symbol + company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticker.symbol,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.black)),
                    const SizedBox(height: 2),
                    Text(
                      ticker.companyName.isNotEmpty ? ticker.companyName : ticker.symbol,
                      style: GoogleFonts.inter(fontSize: 11,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                          fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Sparkline
              SparklineWidget(ticker: ticker.symbol, direction: direction, width: 72, height: 36),

              const SizedBox(width: 10),

              // Percentage badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: isDark ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: trendColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        isUp ? Icons.arrow_drop_up : isDown ? Icons.arrow_drop_down : Icons.remove,
                        size: 14, color: trendColor,
                      ),
                      Text(ticker.displayScore,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: trendColor)),
                    ]),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Remove button
              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.negativeDark : AppColors.negativeLight).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isDark ? AppColors.negativeDark : AppColors.negativeLight).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(Icons.close_rounded, size: 14,
                      color: (isDark ? AppColors.negativeDark : AppColors.negativeLight).withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  final Color primary;
  final VoidCallback onAdd;

  const _EmptyState(
      {required this.l, required this.primary, required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_outlined,
                size: 64, color: primary.withValues(alpha: 0.5)),
            const SizedBox(height: 20),
            Text(l.watchlistEmpty,
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(l.watchlistEmptySubtitle,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l.addTicker),
              ),
            ),
          ],
        ),
      );
}

class _AddTickerSheet extends ConsumerStatefulWidget {
  final Future<void> Function(String symbol) onAdd;
  const _AddTickerSheet({required this.onAdd});

  @override
  ConsumerState<_AddTickerSheet> createState() => _AddTickerSheetState();
}

class _AddTickerSheetState extends ConsumerState<_AddTickerSheet> {
  final _ctrl = TextEditingController();
  List<Ticker> _results = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final r = await ref.read(watchlistProvider.notifier).search('');
    if (mounted) setState(() => _results = r);
  }

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final r = await ref.read(watchlistProvider.notifier).search(q);
      if (mounted) setState(() => _results = r);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final owned = ref.watch(watchlistProvider).maybeWhen(
      data: (tickers) => tickers.map((t) => t.symbol.toUpperCase()).toSet(),
      orElse: () => <String>{},
    );

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 480,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l.searchTickers,
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
                onChanged: _search,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final t = _results[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primary.withValues(alpha: 0.15),
                      child: Text(t.symbol[0],
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: primary)),
                    ),
                    title: Text(t.symbol,
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    subtitle: Text(t.companyName,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textMuted)),
                    trailing: owned.contains(t.symbol.toUpperCase())
                        ? Icon(Icons.check_circle, color: primary)
                        : IconButton(
                            icon: Icon(Icons.add_circle_outline, color: primary),
                            // Stay open so several tickers can be added in a row.
                            onPressed: () => widget.onAdd(t.symbol),
                          ),
                  )
                      .animate(
                          delay: Duration(
                              milliseconds: (i * 40).clamp(0, 300)))
                      .fadeIn(duration: 250.ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
