import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/news_item.dart';
import 'sparkline_widget.dart';

class NewsCard extends StatefulWidget {
  final NewsItem item;
  final VoidCallback onTap;

  const NewsCard({super.key, required this.item, required this.onTap});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _pressed = false;

  Color _dirColor(bool isDark) {
    switch (widget.item.direction) {
      case SentimentDirection.positive:
        return isDark ? AppColors.primaryDark : AppColors.primaryLight;
      case SentimentDirection.negative:
        return isDark ? AppColors.negativeDark : AppColors.negativeLight;
      case SentimentDirection.neutral:
        return AppColors.warning;
    }
  }

  IconData get _dirIcon {
    switch (widget.item.direction) {
      case SentimentDirection.positive: return Icons.trending_up_rounded;
      case SentimentDirection.negative: return Icons.trending_down_rounded;
      case SentimentDirection.neutral: return Icons.remove_rounded;
    }
  }

  String get _dirLabel {
    switch (widget.item.direction) {
      case SentimentDirection.positive: return 'POSITIVE';
      case SentimentDirection.negative: return 'NEGATIVE';
      case SentimentDirection.neutral: return 'NEUTRAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dirColor = _dirColor(isDark);
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.972 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: cardBg,
              // direction reads through a soft tint, not a side stripe
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    dirColor.withValues(alpha: isDark ? 0.055 : 0.035),
                    cardBg,
                  ),
                  cardBg,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _pressed
                    ? dirColor.withValues(alpha: 0.5)
                    : Color.alphaBlend(
                        dirColor.withValues(alpha: isDark ? 0.16 : 0.10),
                        border,
                      ),
                width: _pressed ? 1.5 : 1,
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: _pressed ? 0.5 : 0.3),
                        blurRadius: _pressed ? 20 : 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: dirColor.withValues(alpha: _pressed ? 0.10 : 0.04),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 12, offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: ticker + time + badge
                            Row(
                              children: [
                                // Ticker chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: dirColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: dirColor.withValues(alpha: 0.35)),
                                  ),
                                  child: Text(
                                    widget.item.ticker,
                                    style: GoogleFonts.inter(
                                      fontSize: 12, fontWeight: FontWeight.w800,
                                      color: dirColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  '· ${widget.item.timeAgo}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                                  ),
                                ),
                                const Spacer(),
                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: dirColor.withValues(alpha: isDark ? 0.18 : 0.10),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(_dirIcon, size: 11, color: dirColor),
                                    const SizedBox(width: 3),
                                    Text(_dirLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 10, fontWeight: FontWeight.w800,
                                          color: dirColor, letterSpacing: 0.3,
                                        )),
                                  ]),
                                ),
                              ],
                            ),

                            const SizedBox(height: 9),

                            // Headline
                            Text(
                              widget.item.headline,
                              style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.black,
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 10),

                            // Source + sparkline
                            Row(
                              children: [
                                Icon(Icons.article_outlined, size: 12,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.item.source,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (widget.item.ticker.isNotEmpty)
                                  SparklineWidget(
                                    ticker: widget.item.ticker,
                                    direction: widget.item.direction,
                                    width: 76, height: 34,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 9),

                            // Confidence bar — thicker + labeled
                            Row(children: [
                              Text('AI',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                                      color: dirColor, letterSpacing: 0.5)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: widget.item.confidence / 100,
                                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                    valueColor: AlwaysStoppedAnimation<Color>(dirColor),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text('${widget.item.confidence}%',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                                      color: dirColor)),
                            ]),
                          ],
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
