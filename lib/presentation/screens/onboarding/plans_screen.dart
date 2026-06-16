import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  int _selected = 1;

  final _plans = const [
    _Plan(
      name: 'Free',
      price: '\$0',
      period: '',
      features: [
        '50 AI analyses per month',
        'Delayed financial news',
        'Max 5 tickers in watchlist',
        'Basic sentiment analysis',
        'No push notifications',
        'No real-time alerts',
      ],
      highlight: false,
    ),
    _Plan(
      name: 'Pro',
      price: '\$29.99',
      period: '/mo',
      features: [
        'Unlimited AI analyses',
        'Push notifications',
        'Unlimited watchlist',
        'Real-time ticker alerts',
        'Advanced filters',
        'Full analysis history',
        'Priority beta access',
      ],
      highlight: true,
    ),
  ];

  void _subscribe() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.paymentComingSoon,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    isDark ? 'assets/icons/l2.png' : 'assets/icons/l1.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(l.choosePlan, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                l.choosePlanSubtitle,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ...List.generate(_plans.length, (i) => _PlanCard(
                plan: _plans[i],
                selected: _selected == i,
                onTap: () => setState(() => _selected = i),
                isDark: isDark,
                primary: primary,
              )),
              const SizedBox(height: 24),
              if (_selected == 0 || !kShowExternalBilling)
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: Text(l.startFree),
                )
              else
                // hidden on iOS — App Store guideline 3.1.1
                ElevatedButton(
                  onPressed: _subscribe,
                  child: Text('${l.subscribe} — ${_plans[_selected].price}${_plans[_selected].period}'),
                ),
              const SizedBox(height: 12),
              if (_selected != 0)
                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    l.startFree,
                    style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Plan {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool highlight;

  const _Plan({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.highlight,
  });
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  final Color primary;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final borderColor = selected ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    final bgColor = selected
        ? primary.withOpacity(0.08)
        : (isDark ? AppColors.darkCard : AppColors.lightCard);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(plan.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (plan.highlight)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l.mostPopular,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: primary),
                    ),
                  ),
                const SizedBox(width: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(plan.price, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
                    if (plan.period.isNotEmpty)
                      Text(plan.period, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: selected ? primary : AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(f, style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.white : AppColors.black)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
