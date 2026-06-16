import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/news_item.dart';

class ConfidenceBar extends StatelessWidget {
  final int confidence;
  final SentimentDirection direction;

  const ConfidenceBar({super.key, required this.confidence, required this.direction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = direction == SentimentDirection.positive
        ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
        : direction == SentimentDirection.negative
            ? (isDark ? AppColors.negativeDark : AppColors.negativeLight)
            : AppColors.warning;

    return Row(
      children: [
        Text(
          'AI Confidence',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: confidence / 100,
              backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$confidence%',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
