import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/news_item.dart';
import '../../providers/providers.dart';
import '../../widgets/news_card.dart';
import '../../widgets/shimmer_loading.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.brandDark : AppColors.brandLight;
    final feed = ref.watch(feedProvider);
    final filter = ref.watch(feedFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 4, 8),
              child: Row(
                children: [
                  Image.asset(
                    isDark ? 'assets/icons/l2.png' : 'assets/icons/l1.png',
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Alerts',
                    onPressed: () => context.push('/alerts'),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.marketFeed,
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        l.latestSentiment,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (filter.hasFilter)
                    GestureDetector(
                      onTap: () => ref.read(feedFilterProvider.notifier).state =
                          const FeedFilter(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_filterLabel(filter),
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: primary)),
                            const SizedBox(width: 4),
                            Icon(Icons.close, size: 12, color: primary),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.85, 0.85)),
                  IconButton(
                    icon: Icon(
                      Icons.tune,
                      size: 20,
                      color: filter.hasFilter ? primary : null,
                    ),
                    tooltip: 'Filter',
                    onPressed: () => _showFilterSheet(context, ref, isDark, primary),
                  ),
                ],
              ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
            ),
            // Search bar — filters the feed by ticker / headline
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _FeedSearchBar(isDark: isDark, primary: primary),
            ).animate(delay: 90.ms).fadeIn(duration: 280.ms),
            Expanded(
              child: feed.when(
                loading: () => ListView.builder(
                  itemCount: 6,
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) => ShimmerNewsCard()
                      .animate(delay: Duration(milliseconds: i * 80))
                      .fadeIn(duration: 300.ms),
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
                            Icon(Icons.newspaper_outlined,
                                size: 48,
                                color: AppColors.textMuted
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text(
                              filter.hasFilter
                                  ? 'No results for this filter'
                                  : 'No news yet',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted),
                            ),
                            if (filter.hasFilter) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => ref
                                    .read(feedFilterProvider.notifier)
                                    .state = const FeedFilter(),
                                child: const Text('Clear filter'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms);
                  }
                  return RefreshIndicator.adaptive(
                    onRefresh: () {
                      HapticFeedback.mediumImpact();
                      return ref.refresh(feedProvider.future);
                    },
                    color: primary,
                    child: ListView.builder(
                      itemCount: items.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      cacheExtent: 400,
                      addRepaintBoundaries: false,
                      itemBuilder: (ctx, i) {
                        final card = NewsCard(
                          item: items[i],
                          onTap: () => context.push('/item/${items[i].id}'),
                        );
                        if (i < 8) {
                          return card
                              .animate(delay: Duration(milliseconds: i * 50))
                              .fadeIn(duration: 280.ms)
                              .slideY(begin: 0.10, end: 0, curve: Curves.easeOutCubic, duration: 280.ms);
                        }
                        return card;
                      },
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

  String _filterLabel(FeedFilter f) {
    final parts = <String>[];
    if (f.direction != null) {
      parts.add(f.direction == SentimentDirection.positive
          ? '📈 Bullish'
          : f.direction == SentimentDirection.negative
              ? '📉 Bearish'
              : '➡️ Neutral');
    }
    if (f.ticker != null && f.ticker!.isNotEmpty) parts.add(f.ticker!);
    return parts.join(' · ');
  }

  void _showFilterSheet(
      BuildContext context, WidgetRef ref, bool isDark, Color primary) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(isDark: isDark, primary: primary),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  final bool isDark;
  final Color primary;
  const _FilterSheet({required this.isDark, required this.primary});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late SentimentDirection? _direction;
  late TextEditingController _tickerCtrl;
  late bool _watchlistOnly;
  final _tickerFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final current = ref.read(feedFilterProvider);
    _direction = current.direction;
    _watchlistOnly = current.watchlistOnly;
    _tickerCtrl = TextEditingController(text: current.ticker ?? '');
    _tickerFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tickerCtrl.dispose();
    _tickerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final primary = widget.primary;
    final negColor = isDark ? AppColors.negativeDark : AppColors.negativeLight;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    // Bullish keeps the signal green even though actions are brand teal
    final posColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final filters = [
      (null, 'All Signals', Icons.bar_chart_rounded, primary),
      (SentimentDirection.positive, 'Bullish', Icons.trending_up_rounded, posColor),
      (SentimentDirection.negative, 'Bearish', Icons.trending_down_rounded, negColor),
      (SentimentDirection.neutral, 'Neutral', Icons.remove_rounded, AppColors.textMutedDark),
    ];

    final watchlistSymbols = ref.watch(watchlistProvider).maybeWhen(
      data: (tickers) => tickers.map((t) => t.symbol).toList(),
      orElse: () => <String>[],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: primary),
              const SizedBox(width: 8),
              Text('Filter Feed',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.black)),
            ],
          ),
          const SizedBox(height: 20),

          // Direction label
          Text('SIGNAL TYPE',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppColors.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 10),

          // Direction pills — 2x2 grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3.2,
            children: filters.map((f) {
              final selected = _direction == f.$1;
              final fColor = f.$4;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _direction = f.$1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: selected
                        ? fColor.withValues(alpha: 0.12)
                        : (isDark ? AppColors.darkBg : AppColors.lightBg),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? fColor.withValues(alpha: 0.6) : border,
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: fColor.withValues(alpha: 0.15), blurRadius: 10)]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(f.$3, size: 16,
                          color: selected ? fColor : AppColors.textMutedDark),
                      const SizedBox(width: 7),
                      Text(f.$2,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? fColor : AppColors.textMutedDark,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Watchlist Only toggle
          if (watchlistSymbols.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _watchlistOnly = !_watchlistOnly),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _watchlistOnly
                      ? primary.withValues(alpha: 0.12)
                      : (isDark ? AppColors.darkBg : AppColors.lightBg),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _watchlistOnly ? primary.withValues(alpha: 0.6) : border,
                    width: _watchlistOnly ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Icon(Icons.remove_red_eye_outlined, size: 16,
                      color: _watchlistOnly ? primary : AppColors.textMutedDark),
                  const SizedBox(width: 8),
                  Expanded(child: Text('My Watchlist Only',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                          color: _watchlistOnly ? primary : AppColors.textMutedDark))),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: _watchlistOnly ? primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: _watchlistOnly ? primary : border),
                    ),
                    child: _watchlistOnly
                        ? Icon(Icons.check_rounded, size: 13, color: isDark ? AppColors.black : Colors.white)
                        : null,
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            // Watchlist ticker chips — quick select
            Wrap(
              spacing: 8, runSpacing: 8,
              children: watchlistSymbols.map((sym) {
                final isSelected = _tickerCtrl.text.toUpperCase() == sym;
                return GestureDetector(
                  onTap: () => setState(() {
                    _tickerCtrl.text = isSelected ? '' : sym;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? primary.withValues(alpha: 0.14) : (isDark ? AppColors.darkBg : AppColors.lightBg),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? primary.withValues(alpha: 0.6) : border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(sym, style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: isSelected ? primary : AppColors.textMutedDark,
                    )),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),

          // Ticker label
          Text('TICKER',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppColors.textMuted, letterSpacing: 1.2)),
          const SizedBox(height: 10),

          // Ticker input
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _tickerFocus.hasFocus
                    ? primary.withValues(alpha: 0.6)
                    : border,
                width: _tickerFocus.hasFocus ? 1.5 : 1,
              ),
              boxShadow: _tickerFocus.hasFocus
                  ? [BoxShadow(color: primary.withValues(alpha: 0.10), blurRadius: 10)]
                  : null,
            ),
            child: TextField(
              controller: _tickerCtrl,
              focusNode: _tickerFocus,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.black,
                  letterSpacing: 1),
              decoration: InputDecoration(
                hintText: 'AAPL, NVDA, TSLA...',
                hintStyle: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 14,
                    fontWeight: FontWeight.w400, letterSpacing: 0),
                prefixIcon: Icon(Icons.search_rounded, size: 18,
                    color: _tickerFocus.hasFocus ? primary : AppColors.textMuted),
                suffixIcon: _tickerCtrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () { _tickerCtrl.clear(); setState(() {}); },
                        child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(feedFilterProvider.notifier).state = const FeedFilter();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Center(
                      child: Text('Clear',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(feedFilterProvider.notifier).state = FeedFilter(
                      direction: _direction,
                      ticker: _tickerCtrl.text.trim().toUpperCase().isEmpty
                          ? null
                          : _tickerCtrl.text.trim().toUpperCase(),
                      watchlistOnly: _watchlistOnly,
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.35),
                          blurRadius: 16, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, size: 16,
                              color: isDark ? AppColors.black : Colors.white),
                          const SizedBox(width: 6),
                          Text('Apply Filter',
                              style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.black : Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

/// Feed search bar — debounced free-text filter over ticker/headline.
class _FeedSearchBar extends ConsumerStatefulWidget {
  final bool isDark;
  final Color primary;
  const _FeedSearchBar({required this.isDark, required this.primary});

  @override
  ConsumerState<_FeedSearchBar> createState() => _FeedSearchBarState();
}

class _FeedSearchBarState extends ConsumerState<_FeedSearchBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl.text = ref.read(feedSearchProvider);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final primary = widget.primary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final focused = _focus.hasFocus;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? primary.withValues(alpha: 0.6) : border,
          width: focused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18,
              color: focused ? primary : AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.black,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: 'Search news — Tesla, NVDA…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textMuted),
                border: InputBorder.none,
              ),
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  ref.read(feedSearchProvider.notifier).state = v;
                });
                setState(() {});
              },
            ),
          ),
          if (_ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _debounce?.cancel();
                _ctrl.clear();
                ref.read(feedSearchProvider.notifier).state = '';
                setState(() {});
              },
              child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
