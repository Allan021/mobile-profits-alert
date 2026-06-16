import 'package:flutter/material.dart';

class AppColors {
  // Dark theme
  static const darkBg = Color(0xFF060811);
  static const darkSurface = Color(0xFF0C1220);
  static const darkCard = Color(0xFF0F1B2E);
  static const darkBorder = Color(0xFF1D2E47);

  // Light theme
  static const lightBg = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);

  // Signal colors (sentiment) — green/red are reserved for market direction
  static const primaryDark = Color(0xFF22C55E);
  static const negativeDark = Color(0xFFEF4444);
  static const blueDark = Color(0xFF3B82F6);

  static const primaryLight = Color(0xFF16A34A);
  static const negativeLight = Color(0xFFDC2626);
  static const blueLight = Color(0xFF2563EB);

  // Brand — aurora teal, matches the web identity. Use for actions,
  // selection and navigation so green can mean only one thing: bullish.
  static const brandDark = Color(0xFF0EA5E9);
  static const brandLight = Color(0xFF0284C7);
  static const violet = Color(0xFF8B5CF6);

  // Shared
  static const textMuted = Color(0xFF64748B);
  static const textMutedDark = Color(0xFF8EA3C0);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF0A0F1E);

  // Sentiment badge backgrounds
  static const positiveBadgeDark = Color(0xFF14532D);
  static const negativeBadgeDark = Color(0xFF450A0A);
  static const positiveBadgeLight = Color(0xFFDCFCE7);
  static const negativeBadgeLight = Color(0xFFFEE2E2);

  // Warning / quota
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFF1C1500);
}
