import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkCard : const Color(0xFFE8EDF2);
    final highlight = isDark ? AppColors.darkBorder : const Color(0xFFF5F7FA);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: highlight,
          curve: Curves.easeInOut,
        );
  }
}

class ShimmerNewsCard extends StatelessWidget {
  const ShimmerNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 48, height: 14, radius: 6),
              const SizedBox(width: 8),
              ShimmerBox(width: 72, height: 14, radius: 6),
              const Spacer(),
              ShimmerBox(width: 64, height: 22, radius: 6),
            ],
          ),
          const SizedBox(height: 10),
          const ShimmerBox(height: 15),
          const SizedBox(height: 6),
          ShimmerBox(width: 220, height: 15),
          const SizedBox(height: 10),
          Row(
            children: [
              ShimmerBox(width: 80, height: 11, radius: 5),
              const Spacer(),
              ShimmerBox(width: 72, height: 32, radius: 6),
            ],
          ),
          const SizedBox(height: 8),
          const ShimmerBox(height: 6, radius: 3),
        ],
      ),
    );
  }
}
