import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/news_item.dart';
import '../../providers/providers.dart';
import '../../widgets/confidence_bar.dart';
import '../../widgets/price_chart_widget.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;
  final bool fromNotification;
  const ItemDetailScreen({super.key, required this.itemId, this.fromNotification = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final item = ref.watch(itemDetailProvider(itemId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: item.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(isDark: isDark),
        data: (news) => _DetailBody(
          news: news, isDark: isDark, primary: primary, l: l,
          fromNotification: fromNotification,
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final bool isDark;
  const _ErrorState({required this.isDark});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.article_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('Article not available',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text('This article may have been removed or is not yet indexed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted.withValues(alpha: 0.7))),
        ]),
      ),
    ),
  );
}

// ── Main body ─────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  final NewsItem news;
  final bool isDark;
  final Color primary;
  final dynamic l;
  final bool fromNotification;

  const _DetailBody({required this.news, required this.isDark, required this.primary, required this.l, this.fromNotification = false});

  Color get _dirColor {
    if (news.direction == SentimentDirection.positive) return isDark ? AppColors.primaryDark : AppColors.primaryLight;
    if (news.direction == SentimentDirection.negative) return isDark ? AppColors.negativeDark : AppColors.negativeLight;
    return AppColors.warning;
  }

  IconData get _dirIcon {
    if (news.direction == SentimentDirection.positive) return Icons.trending_up_rounded;
    if (news.direction == SentimentDirection.negative) return Icons.trending_down_rounded;
    return Icons.remove_rounded;
  }

  String get _dirLabel {
    if (news.direction == SentimentDirection.positive) return 'BULLISH';
    if (news.direction == SentimentDirection.negative) return 'BEARISH';
    return 'NEUTRAL';
  }

  @override
  Widget build(BuildContext context) {
    final dirColor = _dirColor;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero header ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Stack(
            children: [
              // Glow background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        dirColor.withValues(alpha: isDark ? 0.15 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + meta
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => fromNotification
                                ? context.go('/alerts')
                                : context.pop(),
                            child: fromNotification
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: border),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.arrow_back_ios_new_rounded, size: 12,
                                          color: isDark ? Colors.white70 : AppColors.black),
                                      const SizedBox(width: 4),
                                      Text('Alerts', style: GoogleFonts.inter(
                                        fontSize: 12, fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : AppColors.black,
                                      )),
                                    ]),
                                  )
                                : Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: border),
                                    ),
                                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                                        color: isDark ? Colors.white70 : AppColors.black),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          if (news.ticker.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: dirColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: dirColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(news.ticker,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: dirColor)),
                            ),
                          const SizedBox(width: 8),
                          // Direction badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: dirColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(_dirIcon, size: 12, color: isDark ? AppColors.black : Colors.white),
                              const SizedBox(width: 4),
                              Text(_dirLabel,
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.black : Colors.white, letterSpacing: 0.5)),
                            ]),
                          ),
                          const Spacer(),
                          Text(news.timeAgo,
                              style: GoogleFonts.inter(fontSize: 12,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                        ],
                      ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 16),

                      // Headline
                      Text(news.headline,
                          style: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w800,
                              height: 1.3, color: isDark ? Colors.white : AppColors.black))
                          .animate(delay: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),

                      const SizedBox(height: 8),

                      // Source
                      Row(children: [
                        Icon(Icons.article_outlined, size: 13,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                        const SizedBox(width: 5),
                        Text(news.source,
                            style: GoogleFonts.inter(fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                                fontWeight: FontWeight.w500)),
                      ]).animate(delay: 80.ms).fadeIn(duration: 280.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Signal summary bar ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dirColor.withValues(alpha: isDark ? 0.10 : 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dirColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  // Direction
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text('SIGNAL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMuted, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_dirIcon, size: 20, color: dirColor),
                        const SizedBox(width: 6),
                        Text(_dirLabel, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800,
                            color: dirColor)),
                      ]),
                    ]),
                  ),
                  Container(width: 1, height: 40, color: dirColor.withValues(alpha: 0.25)),
                  // Confidence
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text('CONFIDENCE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMuted, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text('${news.confidence}%', style: GoogleFonts.inter(fontSize: 22,
                          fontWeight: FontWeight.w800, color: dirColor)),
                    ]),
                  ),
                  Container(width: 1, height: 40, color: dirColor.withValues(alpha: 0.25)),
                  // Impact
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text('IMPACT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMuted, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text('${news.confidence >= 70 ? "HIGH" : news.confidence >= 50 ? "MED" : "LOW"}',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800,
                              color: dirColor)),
                    ]),
                  ),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
          ),
        ),

        // ── Confidence bar ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('AI Confidence', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                Text('${news.confidence}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                    color: dirColor)),
              ]),
              const SizedBox(height: 6),
              ConfidenceBar(confidence: news.confidence, direction: news.direction),
            ]),
          ).animate(delay: 140.ms).fadeIn(duration: 320.ms),
        ),

        // ── Price chart ───────────────────────────────────────────
        if (news.ticker.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _Card(isDark: isDark, primary: primary,
                child: PriceChartWidget(ticker: news.ticker, direction: news.direction),
              ).animate(delay: 160.ms).fadeIn(duration: 380.ms),
            ),
          ),

        // ── AI Rationale ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _Card(
              isDark: isDark, primary: primary,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.psychology_rounded, size: 16, color: primary),
                  const SizedBox(width: 6),
                  Text('AI RATIONALE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted, letterSpacing: 1)),
                ]),
                const SizedBox(height: 10),
                Text(news.rationale,
                    style: GoogleFonts.inter(fontSize: 14, height: 1.65,
                        color: isDark ? Colors.white.withValues(alpha: 0.88) : const Color(0xFF1E293B))),
              ]),
            ).animate(delay: 200.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
          ),
        ),

        // ── Affected tickers ──────────────────────────────────────
        if (news.affectedTickers.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _Card(
                isDark: isDark, primary: primary,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.hub_outlined, size: 16, color: primary),
                    const SizedBox(width: 6),
                    Text('AFFECTED TICKERS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted, letterSpacing: 1)),
                  ]),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: news.affectedTickers.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(t, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
                    )).toList(),
                  ),
                ]),
              ).animate(delay: 240.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
            ),
          ),

        // ── Read article ──────────────────────────────────────────
        if (news.url != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: GestureDetector(
                onTap: () async {
                  try {
                    await launchUrl(Uri.parse(news.url!), mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, primary.withValues(alpha: 0.75)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.open_in_new_rounded, size: 17,
                        color: isDark ? AppColors.black : Colors.white),
                    const SizedBox(width: 8),
                    Text('Read Full Article', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.black : Colors.white)),
                  ]),
                ),
              ).animate(delay: 280.ms).fadeIn(duration: 320.ms),
            ),
          ),
      ],
    );
  }
}

// ── Reusable card ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color primary;

  const _Card({required this.child, required this.isDark, required this.primary});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      boxShadow: isDark
          ? [
              BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4)),
              BoxShadow(color: primary.withValues(alpha: 0.04), blurRadius: 18, spreadRadius: -2),
            ]
          : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: child,
  );
}
