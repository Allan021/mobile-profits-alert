import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding/onboarding_tour.dart';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _showTour = false;

  @override
  void initState() {
    super.initState();
    shouldShowTour().then((show) {
      if (show && mounted) setState(() => _showTour = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.brandDark : AppColors.brandLight;

    final labels = [l.feed, l.watchlist, l.alerts, l.settings];
    final icons = [
      Icons.grid_view_outlined,
      Icons.remove_red_eye_outlined,
      Icons.notifications_outlined,
      Icons.settings_outlined,
    ];
    final activeIcons = [
      Icons.grid_view,
      Icons.remove_red_eye,
      Icons.notifications,
      Icons.settings,
    ];

    return Stack(
      children: [
        Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ]
              : null,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(4, (i) {
                final selected = navigationShell.currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      navigationShell.goBranch(
                        i,
                        initialLocation:
                            i == navigationShell.currentIndex,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOutCubic,
                          padding: selected
                              ? const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4)
                              : const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: selected
                                ? primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(
                                    scale: anim, child: child),
                            child: Icon(
                              selected ? activeIcons[i] : icons[i],
                              key: ValueKey(selected),
                              size: 20,
                              color: selected
                                  ? primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? primary
                                : AppColors.textMuted,
                          ),
                          child: Text(labels[i]),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ).animate().slideY(
            begin: 0.3,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          ),
        ),
        if (_showTour)
          OnboardingTour(onDone: () => setState(() => _showTour = false)),
      ],
    );
  }
}
