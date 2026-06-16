import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

const _kTourKey = 'pa_tour_done_v1';

Future<bool> shouldShowTour() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_kTourKey) ?? false);
}

Future<void> markTourDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kTourKey, true);
}

class OnboardingTour extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingTour({super.key, required this.onDone});

  @override
  State<OnboardingTour> createState() => _OnboardingTourState();
}

class _OnboardingTourState extends State<OnboardingTour> {
  int _step = 0;

  static const _steps = [
    _TourStep(
      icon: Icons.bar_chart_rounded,
      title: 'Market Feed',
      body: 'See the latest AI-analyzed news for every market signal. Bullish 📈 and Bearish 📉 moves in real time.',
      highlight: Alignment.bottomCenter,
      arrowDown: false,
    ),
    _TourStep(
      icon: Icons.notifications_rounded,
      title: 'Smart Alerts',
      body: 'Get push notifications the moment a high-confidence signal is detected for your watchlist tickers.',
      highlight: Alignment.bottomCenter,
      arrowDown: false,
    ),
    _TourStep(
      icon: Icons.remove_red_eye_outlined,
      title: 'Your Watchlist',
      body: 'Add tickers like AAPL, NVDA, TSLA. The AI monitors them 24/7 and alerts you when something moves.',
      highlight: Alignment.bottomCenter,
      arrowDown: false,
    ),
    _TourStep(
      icon: Icons.tune_rounded,
      title: 'Filter the Feed',
      body: 'Tap the filter icon to show only Bullish or Bearish signals, or filter by a specific ticker.',
      highlight: Alignment.topRight,
      arrowDown: true,
    ),
  ];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      markTourDone();
      widget.onDone();
    }
  }

  void _skip() {
    markTourDone();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: SafeArea(
        child: Stack(
          children: [
            // Card centered
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: Icon(step.icon, size: 28, color: AppColors.primaryDark),
                    ).animate(key: ValueKey(_step)).scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack, duration: 350.ms),

                    const SizedBox(height: 20),

                    // Title
                    Text(step.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800,
                            color: Colors.white))
                        .animate(key: ValueKey('t$_step')).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 10),

                    // Body
                    Text(step.body,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 14, height: 1.6,
                            color: Colors.white.withValues(alpha: 0.8)))
                        .animate(key: ValueKey('b$_step')).fadeIn(duration: 300.ms, delay: 60.ms),

                    const SizedBox(height: 32),

                    // Step dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (i) => AnimatedContainer(
                        duration: 220.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _step ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _step
                              ? AppColors.primaryDark
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      )),
                    ),

                    const SizedBox(height: 28),

                    // Buttons
                    Row(children: [
                      // Skip
                      GestureDetector(
                        onTap: _skip,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('Skip',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.5))),
                        ),
                      ),
                      const Spacer(),
                      // Next/Done
                      GestureDetector(
                        onTap: _next,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.4),
                                blurRadius: 16, offset: const Offset(0, 4))],
                          ),
                          child: Text(_step == _steps.length - 1 ? "Let's go!" : 'Next',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700,
                                  color: AppColors.black)),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourStep {
  final IconData icon;
  final String title;
  final String body;
  final Alignment highlight;
  final bool arrowDown;
  const _TourStep({required this.icon, required this.title, required this.body,
      required this.highlight, required this.arrowDown});
}
