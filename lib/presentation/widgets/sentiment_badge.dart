import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/news_item.dart';

class SentimentBadge extends StatelessWidget {
  final SentimentDirection direction;
  final String label;
  final bool small;

  const SentimentBadge({
    super.key,
    required this.direction,
    required this.label,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color fg;
    IconData icon;

    switch (direction) {
      case SentimentDirection.positive:
        bg = isDark ? AppColors.positiveBadgeDark : AppColors.positiveBadgeLight;
        fg = isDark ? AppColors.primaryDark : AppColors.primaryLight;
        icon = Icons.arrow_upward;
        break;
      case SentimentDirection.negative:
        bg = isDark ? AppColors.negativeBadgeDark : AppColors.negativeBadgeLight;
        fg = isDark ? AppColors.negativeDark : AppColors.negativeLight;
        icon = Icons.arrow_downward;
        break;
      case SentimentDirection.neutral:
        bg = isDark ? const Color(0xFF1C1500) : const Color(0xFFFEF3C7);
        fg = AppColors.warning;
        icon = Icons.remove;
        break;
    }

    final fontSize = small ? 10.0 : 11.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 10 : 12, color: fg),
          const SizedBox(width: 3),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
