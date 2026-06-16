import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

const _kOnboardingDone = 'pa_onboarding_v2';

// Internal palette — always dark, matches the app's aurora aesthetic
const _bg      = Color(0xFF060811);
const _card    = Color(0xFF0F1B2E);
const _border  = Color(0xFF1D2E47);
const _txBase  = Colors.white;
const _txMuted = Color(0xFF94A3B8);
const _txDim   = Color(0xFF475569);
const _green   = Color(0xFF22C55E);
const _blue    = Color(0xFF3B82F6);
const _purple  = Color(0xFFA855F7);
const _amber   = Color(0xFFF59E0B);
const _red     = Color(0xFFEF4444);

// ── Main screen ─────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;
  static const _total = 5;

  void _next() {
    if (_page < _total - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skip() => _done(upgrade: false);

  Future<void> _done({required bool upgrade}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
    if (!mounted) return;
    context.go(upgrade ? '/plans' : '/');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // Aurora ambient blobs
            Positioned(
              top: -120, left: -80,
              child: _GlowCircle(color: _green, radius: 220, opacity: 0.10),
            ),
            Positioned(
              bottom: 60, right: -100,
              child: _GlowCircle(color: _blue, radius: 200, opacity: 0.07),
            ),
            SafeArea(
              child: Column(
                children: [
                  // ── Top bar ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/l2.png',
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Spacer(),
                        if (_page < _total - 1)
                          TextButton(
                            onPressed: _skip,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: Text(
                              'Omitir',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: _txMuted),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // ── Pages ─────────────────────────────────────────────
                  Expanded(
                    child: PageView(
                      controller: _ctrl,
                      onPageChanged: (p) => setState(() => _page = p),
                      physics: const ClampingScrollPhysics(),
                      children: [
                        const _WelcomePage(),
                        const _HowAlertsPage(),
                        const _WatchlistPage(),
                        const _DailyRoutinePage(),
                        _PlanChoicePage(
                          onFree: () => _done(upgrade: false),
                          onPro: () => _done(upgrade: true),
                        ),
                      ],
                    ),
                  ),
                  // ── Bottom: dots + CTA ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 34),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_total, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _page ? 22 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _page ? _green : _border,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                        if (_page < _total - 1) ...[
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _page == 0 ? 'Comenzar  →' : 'Siguiente  →',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1 — Welcome ─────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          // Hero radar icon
          Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _green.withValues(alpha: 0.22),
                _green.withValues(alpha: 0.03),
              ]),
              border: Border.all(
                  color: _green.withValues(alpha: 0.28), width: 1.5),
            ),
            child: const Icon(Icons.radar, size: 54, color: _green),
          )
              .animate()
              .scale(
                begin: const Offset(0.62, 0.62),
                duration: 700.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 30),
          Text(
            'Tu radar de mercado\ncon inteligencia artificial',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: _txBase,
              height: 1.22,
            ),
          )
              .animate(delay: 150.ms)
              .fadeIn(duration: 360.ms)
              .slideY(begin: 0.12, end: 0),
          const SizedBox(height: 14),
          Text(
            'Profit Alerts analiza miles de noticias financieras con IA y te entrega solo las señales que importan para tu portafolio — sin ruido, sin FOMO.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.68,
              color: _txMuted,
            ),
          ).animate(delay: 260.ms).fadeIn(duration: 360.ms),
          const SizedBox(height: 32),
          // Feature pills
          Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _Pill(
                icon: Icons.psychology_outlined,
                label: 'IA en tiempo real',
                color: _green,
              ),
              _Pill(
                icon: Icons.analytics_outlined,
                label: 'Score de confianza',
                color: _blue,
              ),
              _Pill(
                icon: Icons.notifications_active_outlined,
                label: 'Alertas push',
                color: _amber,
              ),
              _Pill(
                icon: Icons.filter_alt_outlined,
                label: 'Sin ruido de mercado',
                color: _purple,
              ),
            ],
          ).animate(delay: 380.ms).fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Page 2 — How alerts work ─────────────────────────────────────────────────

class _HowAlertsPage extends StatelessWidget {
  const _HowAlertsPage();

  static const _steps = [
    _StepData(
      icon: Icons.feed_outlined,
      color: _blue,
      title: 'Monitoreo 24/7',
      desc: 'Escaneamos fuentes financieras en tiempo real — noticias, reportes, earnings y filings.',
    ),
    _StepData(
      icon: Icons.psychology_outlined,
      color: _purple,
      title: 'Análisis con IA',
      desc: 'Detectamos sentimiento, relevancia e impacto potencial para cada ticker en tu watchlist.',
    ),
    _StepData(
      icon: Icons.bar_chart_rounded,
      color: _green,
      title: 'Señal generada',
      desc: 'Recibes un score de confianza, dirección del mercado (alcista/bajista) y contexto resumido.',
    ),
    _StepData(
      icon: Icons.phone_android_outlined,
      color: _amber,
      title: 'Te llega a ti',
      desc: 'Push notification al instante (Pro) o disponible en tu feed cuando abres la app (Free).',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cómo funcionan\nlas alertas',
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: _txBase,
              height: 1.22,
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.07, end: 0),
          const SizedBox(height: 6),
          Text(
            'De la noticia al insight — en segundos.',
            style: GoogleFonts.inter(fontSize: 14, color: _txMuted),
          ).animate(delay: 70.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 24),
          ...List.generate(_steps.length, (i) {
            return _StepRow(
              step: _steps[i],
              isLast: i == _steps.length - 1,
            )
                .animate(
                    delay: Duration(milliseconds: 80 + i * 80))
                .fadeIn(duration: 320.ms)
                .slideX(begin: -0.05, end: 0);
          }),
          const SizedBox(height: 14),
          _InfoNote(
            color: _green,
            text:
                'Plan Free: hasta 50 análisis por mes  ·  Plan Pro: análisis ilimitados',
          ).animate(delay: 420.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Page 3 — Watchlist ───────────────────────────────────────────────────────

class _WatchlistPage extends StatelessWidget {
  const _WatchlistPage();

  static const _popularTickers = [
    'AAPL', 'TSLA', 'NVDA', 'MSFT', 'AMZN',
    'GOOGL', 'META', 'SPY', 'QQQ', 'BRK.B',
  ];

  static const _mockPrices = [
    _MockTicker('AAPL', '+2.3%', true),
    _MockTicker('TSLA', '-1.1%', false),
    _MockTicker('NVDA', '+4.7%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arma tu watchlist',
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: _txBase,
              height: 1.22,
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.07, end: 0),
          const SizedBox(height: 6),
          Text(
            'Los tickers que sigues — monitoreados 24/7 por IA.',
            style: GoogleFonts.inter(fontSize: 14, color: _txMuted),
          ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 18),
          // Mock watchlist preview
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: List.generate(_mockPrices.length, (i) {
                final t = _mockPrices[i];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i < _mockPrices.length - 1 ? 12 : 0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (t.positive ? _green : _red)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          t.positive
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 17,
                          color: t.positive ? _green : _red,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.symbol,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _txBase,
                          ),
                        ),
                      ),
                      Text(
                        t.change,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: t.positive ? _green : _red,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 380.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: 20),
          Text(
            'TICKERS POPULARES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _txDim,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTickers
                .map((sym) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _border),
                      ),
                      child: Text(
                        sym,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _txBase,
                        ),
                      ),
                    ))
                .toList(),
          ).animate(delay: 240.ms).fadeIn(duration: 380.ms),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LimitCard(
                  icon: Icons.lock_outline,
                  label: 'Plan Free',
                  value: 'Hasta 5 tickers',
                  color: _txMuted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LimitCard(
                  icon: Icons.all_inclusive,
                  label: 'Plan Pro',
                  value: 'Ilimitado',
                  color: _green,
                ),
              ),
            ],
          ).animate(delay: 320.ms).fadeIn(duration: 350.ms),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Page 4 — Daily routine ───────────────────────────────────────────────────

class _DailyRoutinePage extends StatelessWidget {
  const _DailyRoutinePage();

  static const _routine = [
    _RoutineData(
      emoji: '🌅',
      time: 'Pre-mercado · 7 – 9 AM',
      title: 'Señales overnight',
      desc:
          'Revisa el feed para ver qué pasó mientras dormías — earnings, noticias, movimientos internacionales.',
    ),
    _RoutineData(
      emoji: '📈',
      time: 'Mercado abierto · 9:30 AM – 4 PM',
      title: 'Alertas en tiempo real',
      desc:
          'Con Pro, recibes push notifications al instante cuando un ticker de tu lista genera una señal fuerte.',
    ),
    _RoutineData(
      emoji: '🌙',
      time: 'Cierre de mercado · 4 PM',
      title: 'Resumen del día',
      desc:
          'Abre la sección Alerts para un recap completo de todas las señales generadas durante la jornada.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Así se integra\na tu día a día',
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: _txBase,
              height: 1.22,
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.07, end: 0),
          const SizedBox(height: 6),
          Text(
            'Una rutina simple que te mantiene informado sin distracciones.',
            style: GoogleFonts.inter(fontSize: 14, color: _txMuted),
          ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 22),
          ...List.generate(_routine.length, (i) {
            return _RoutineCard(
              item: _routine[i],
              isLast: i == _routine.length - 1,
            )
                .animate(delay: Duration(milliseconds: 100 + i * 90))
                .fadeIn(duration: 320.ms)
                .slideX(begin: -0.05, end: 0);
          }),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  '"Los mejores inversores no leen todo.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _txBase,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                Text(
                  'Solo lo que importa para su portafolio."',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _green,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate(delay: 380.ms).fadeIn(duration: 360.ms),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Page 5 — Plan choice ─────────────────────────────────────────────────────

class _PlanChoicePage extends StatelessWidget {
  final VoidCallback onFree;
  final VoidCallback onPro;

  const _PlanChoicePage({required this.onFree, required this.onPro});

  static const _rows = [
    _CompareRow('Análisis mensuales', '50 / mes', 'Ilimitados'),
    _CompareRow('Watchlist', 'Hasta 5', 'Ilimitado'),
    _CompareRow('Push notifications', '✗', '✓'),
    _CompareRow('Alertas en tiempo real', '✗', '✓'),
    _CompareRow('Historial completo', '✗', '✓'),
    _CompareRow('Filtros avanzados', '✗', '✓'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elige tu plan',
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: _txBase,
              height: 1.22,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 6),
          Text(
            'Empieza gratis. Upgrade cuando lo necesites.',
            style: GoogleFonts.inter(fontSize: 14, color: _txMuted),
          ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 20),
          // Comparison table
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _border.withValues(alpha: 0.6),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(13)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(flex: 3, child: SizedBox()),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Free',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _txMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Pro',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Rows
                ...List.generate(_rows.length, (i) {
                  final r = _rows[i];
                  final isLast = i == _rows.length - 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom:
                                  BorderSide(color: _border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            r.feature,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _txMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            r.free,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: r.free == '✗' ? _txDim : _txBase,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            r.pro,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: r.pro == '✓' ? _green : _txBase,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // Price footer
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _border.withValues(alpha: 0.35),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(13)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(flex: 3, child: SizedBox()),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '\$0 / mes',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _txMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '\$29.99/mes',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 380.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: 20),
          // Pro CTA — hidden on iOS (App Store guideline 3.1.1)
          if (kShowExternalBilling) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onPro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Upgrade a Pro — \$29.99/mes',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ).animate(delay: 280.ms).fadeIn(duration: 350.ms),
            const SizedBox(height: 10),
          ],
          // Free CTA
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onFree,
              style: OutlinedButton.styleFrom(
                foregroundColor: _txMuted,
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Continuar con el plan Free',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate(delay: 330.ms).fadeIn(duration: 350.ms),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Puedes hacer upgrade en cualquier momento desde Configuración.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _txDim,
                height: 1.5,
              ),
            ),
          ).animate(delay: 380.ms).fadeIn(duration: 350.ms),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────────────────────

class _StepData {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _StepData({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}

class _MockTicker {
  final String symbol;
  final String change;
  final bool positive;

  const _MockTicker(this.symbol, this.change, this.positive);
}

class _RoutineData {
  final String emoji;
  final String time;
  final String title;
  final String desc;

  const _RoutineData({
    required this.emoji,
    required this.time,
    required this.title,
    required this.desc,
  });
}

class _CompareRow {
  final String feature;
  final String free;
  final String pro;

  const _CompareRow(this.feature, this.free, this.pro);
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double radius;
  final double opacity;

  const _GlowCircle({
    required this.color,
    required this.radius,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ]),
        ),
      );
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
}

class _StepRow extends StatelessWidget {
  final _StepData step;
  final bool isLast;

  const _StepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: step.color.withValues(alpha: 0.30)),
                ),
                child: Icon(step.icon, size: 18, color: step.color),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: _border,
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _txBase,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.desc,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _txMuted,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _InfoNote extends StatelessWidget {
  final Color color;
  final String text;

  const _InfoNote({required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 15, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: color,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );
}

class _LimitCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _LimitCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _txMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _RoutineCard extends StatelessWidget {
  final _RoutineData item;
  final bool isLast;

  const _RoutineCard({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.time,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _txDim,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _txBase,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.desc,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _txMuted,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
