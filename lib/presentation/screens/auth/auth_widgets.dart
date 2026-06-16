import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

// ── Brand mark ───────────────────────────────────────────────────────────────

class AuthBrandMark extends StatelessWidget {
  final Color primary;
  const AuthBrandMark({super.key, required this.primary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark ? 'assets/icons/l2.png' : 'assets/icons/l1.png';

    return Image.asset(
      logoAsset,
      height: 36,
      fit: BoxFit.contain,
    );
  }
}

// ── Animated text field ───────────────────────────────────────────────────────

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isFocused;
  final bool isDark;
  final bool hasError;
  final Color primary;
  final Color cardBg;
  final Color border;
  final IconData prefixIcon;
  final Widget? suffix;

  const AuthField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    required this.isFocused,
    required this.isDark,
    required this.primary,
    required this.cardBg,
    required this.border,
    this.hasError = false,
    required this.prefixIcon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor =
        isDark ? AppColors.negativeDark : AppColors.negativeLight;
    final activeBorder = hasError ? errorColor : primary;

    return AnimatedContainer(
      duration: 200.ms,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused
              ? activeBorder.withValues(alpha: 0.7)
              : hasError
                  ? errorColor.withValues(alpha: 0.4)
                  : border,
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: activeBorder.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            color: isFocused ? activeBorder : AppColors.textMuted,
            fontWeight: isFocused ? FontWeight.w600 : FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              prefixIcon,
              size: 19,
              color: isFocused ? activeBorder : AppColors.textMuted,
            ),
          ),
          suffixIcon: suffix,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ── Password visibility toggle ────────────────────────────────────────────────

class AuthPasswordToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onTap;

  const AuthPasswordToggle({
    super.key,
    required this.obscure,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: AnimatedSwitcher(
          duration: 200.ms,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            key: ValueKey(obscure),
            size: 20,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Primary CTA button ────────────────────────────────────────────────────────

class AuthPrimaryButton extends StatefulWidget {
  final bool loading;
  final VoidCallback? onTap;
  final Color primary;
  final bool isDark;
  final String label;

  const AuthPrimaryButton({
    super.key,
    required this.loading,
    required this.onTap,
    required this.primary,
    required this.isDark,
    required this.label,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: 120.ms,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: 200.ms,
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: enabled
                ? widget.primary
                : widget.primary.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            boxShadow: (_pressed || widget.loading || !enabled)
                ? null
                : [
                    BoxShadow(
                      color: widget.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: 220.ms,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: widget.loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      key: const ValueKey('label'),
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark ? AppColors.black : Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shake wrapper ─────────────────────────────────────────────────────────────

class AuthShakeWrapper extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AuthShakeWrapper({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, c) {
        final dx =
            math.sin(animation.value * math.pi * 5) * 10 * (1 - animation.value);
        return Transform.translate(offset: Offset(dx, 0), child: c);
      },
      child: child,
    );
  }
}

// ── Error message ─────────────────────────────────────────────────────────────

class AuthError extends StatelessWidget {
  final String? error;
  final bool isDark;

  const AuthError({super.key, required this.error, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: 280.ms,
      curve: Curves.easeOutCubic,
      child: error != null
          ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.negativeDark
                          : AppColors.negativeLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.negativeDark
                            : AppColors.negativeLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 250.ms)
                  .slideY(begin: -0.3, end: 0),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ── Google logo painter ───────────────────────────────────────────────────────

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 20, height: 20, child: CustomPaint(painter: _Painter()));
}

class _Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final segs = [
      (const Color(0xFF4285F4), 0.0, 1.57),
      (const Color(0xFF34A853), 1.57, 3.14),
      (const Color(0xFFFBBC05), 3.14, 4.19),
      (const Color(0xFFEA4335), 4.19, 6.28),
    ];
    for (final s in segs) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), s.$2, s.$3 - s.$2,
          true, Paint()..color = s.$1);
    }
    canvas.drawCircle(c, r * 0.65, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}
