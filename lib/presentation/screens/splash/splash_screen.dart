import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/icons/l1.png'), context);
    precacheImage(const AssetImage('assets/icons/l2.png'), context);
  }

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo con glow pulsante ─────────────────────────────
            AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, child) {
                final glow = Curves.easeInOut.transform(_glowCtrl.value);
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(
                          alpha: 0.15 + 0.20 * glow,
                        ),
                        blurRadius: 60 + 30 * glow,
                        spreadRadius: 10 + 15 * glow,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/icons/l2.png',
                height: 130,
                fit: BoxFit.contain,
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1.0, 1.0),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 500.ms, curve: Curves.easeOut),
            ),

            const SizedBox(height: 56),

            // ── Dots de carga ──────────────────────────────────────
            _LoadingDots()
                .animate(delay: 600.ms)
                .fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * Curves.easeInOut.transform(
              t < 0.5 ? t * 2 : (1 - t) * 2,
            );
            final opacity = 0.3 + 0.7 * Curves.easeInOut.transform(
              t < 0.5 ? t * 2 : (1 - t) * 2,
            );
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
