import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import 'auth_widgets.dart';
// ignore: unused_import
import '../../../data/services/google_auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  bool _termsAccepted = false;
  String? _error;

  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
    _confirmFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final isEs = ref.read(localeProvider)?.languageCode == 'es';

    if (!_termsAccepted) {
      setState(() => _error = isEs
          ? 'Acepta los Términos y la Política de Privacidad.'
          : 'Accept the Terms & Privacy Policy.');
      _shakeCtrl.forward(from: 0);
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = isEs
          ? 'Las contraseñas no coinciden.'
          : 'Passwords do not match.');
      _shakeCtrl.forward(from: 0);
      return;
    }
    if (_passCtrl.text.length < 8) {
      setState(() => _error = isEs
          ? 'La contraseña debe tener al menos 8 caracteres.'
          : 'Password must be at least 8 characters.');
      _shakeCtrl.forward(from: 0);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final err = await ref
        .read(authProvider.notifier)
        .register(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (err == null) {
      context.go('/onboarding');
    } else {
      setState(() => _error = err);
      _shakeCtrl.forward(from: 0);
    }
  }

  void _openUrl(String path) {
    final lang = ref.read(localeProvider)?.languageCode ?? 'en';
    launchUrl(
      Uri.parse('https://www.profitalerts.app$path?lang=$lang'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final isEs = ref.watch(localeProvider)?.languageCode == 'es';

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  primary.withValues(alpha: 0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Back + brand
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: isDark ? Colors.white70 : AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AuthBrandMark(primary: primary),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.12, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 36),

                  Text(
                    l.registerTitle,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                  )
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.18, end: 0),

                  const SizedBox(height: 6),

                  Text(
                    l.registerSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 32),

                  // Fields with shake
                  AuthShakeWrapper(
                    animation: _shakeCtrl,
                    child: Column(
                      children: [
                        AuthField(
                          controller: _emailCtrl,
                          focusNode: _emailFocus,
                          label: l.emailLabel,
                          keyboardType: TextInputType.emailAddress,
                          isFocused: _emailFocus.hasFocus,
                          isDark: isDark,
                          primary: primary,
                          cardBg: cardBg,
                          border: border,
                          hasError: _error != null,
                          prefixIcon: Icons.mail_outline_rounded,
                        )
                            .animate(delay: 150.ms)
                            .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 12),

                        AuthField(
                          controller: _passCtrl,
                          focusNode: _passFocus,
                          label: l.passwordLabel,
                          obscureText: _obscure,
                          isFocused: _passFocus.hasFocus,
                          isDark: isDark,
                          primary: primary,
                          cardBg: cardBg,
                          border: border,
                          hasError: _error != null,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffix: AuthPasswordToggle(
                            obscure: _obscure,
                            onTap: () => setState(() => _obscure = !_obscure),
                          ),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 12),

                        AuthField(
                          controller: _confirmCtrl,
                          focusNode: _confirmFocus,
                          label: l.confirmPassword,
                          obscureText: _obscure,
                          isFocused: _confirmFocus.hasFocus,
                          isDark: isDark,
                          primary: primary,
                          cardBg: cardBg,
                          border: border,
                          hasError: _error != null,
                          prefixIcon: Icons.lock_outline_rounded,
                        )
                            .animate(delay: 250.ms)
                            .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms checkbox
                  GestureDetector(
                    onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: 180.ms,
                          curve: Curves.easeOutCubic,
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: _termsAccepted
                                ? primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _termsAccepted ? primary : border,
                              width: 1.5,
                            ),
                            boxShadow: _termsAccepted
                                ? [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                    )
                                  ]
                                : null,
                          ),
                          child: _termsAccepted
                              ? const Icon(Icons.check_rounded,
                                  size: 13, color: Colors.white)
                                  .animate()
                                  .scale(
                                    begin: const Offset(0.3, 0.3),
                                    end: const Offset(1, 1),
                                    duration: 200.ms,
                                    curve: Curves.elasticOut,
                                  )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                height: 1.55,
                              ),
                              children: [
                                TextSpan(
                                  text: isEs
                                      ? 'He leído y acepto los '
                                      : 'I agree to the ',
                                ),
                                TextSpan(
                                  text: isEs
                                      ? 'Términos y Condiciones'
                                      : 'Terms & Conditions',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: primary,
                                    fontWeight: FontWeight.w700,
                                    height: 1.55,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _openUrl('/terms'),
                                ),
                                TextSpan(
                                    text: isEs ? ' y la ' : ' and '),
                                TextSpan(
                                  text: isEs
                                      ? 'Política de Privacidad'
                                      : 'Privacy Policy',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: primary,
                                    fontWeight: FontWeight.w700,
                                    height: 1.55,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _openUrl('/privacy'),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 290.ms)
                      .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic),

                  AuthError(error: _error, isDark: isDark),

                  const SizedBox(height: 20),

                  AuthPrimaryButton(
                    loading: _loading,
                    onTap: (_loading || !_termsAccepted) ? null : _register,
                    primary: primary,
                    isDark: isDark,
                    label: l.createAccount,
                  )
                      .animate(delay: 330.ms)
                      .fadeIn(duration: 330.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Google sign-up — Android/web only (App Store guideline 4.8:
                  // would require Sign in with Apple alongside it on iOS)
                  if (kShowGoogleSignIn) ...[
                    Row(children: [
                      Expanded(child: Divider(color: border, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(child: Divider(color: border, thickness: 1)),
                    ]).animate(delay: 350.ms).fadeIn(duration: 280.ms),

                    const SizedBox(height: 14),

                    _GoogleButton(
                      isDark: isDark, cardBg: cardBg, border: border,
                      loading: _loading,
                      onTap: _loading ? null : () async {
                        setState(() { _loading = true; _error = null; });
                        final googleSvc = ref.read(googleAuthServiceProvider);
                        final err = await ref.read(authProvider.notifier).loginWithGoogle(googleSvc);
                        if (!mounted) return;
                        setState(() => _loading = false);
                        if (err == null) context.go('/');
                        else if (err != 'cancelled') setState(() => _error = err);
                      },
                    ).animate(delay: 370.ms).fadeIn(duration: 300.ms),
                  ],

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.alreadyHaveAccount,
                        style: GoogleFonts.inter(
                            color: AppColors.textMuted, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          l.signIn,
                          style: GoogleFonts.inter(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate(delay: 370.ms)
                      .fadeIn(duration: 300.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatefulWidget {
  final bool isDark;
  final Color cardBg;
  final Color border;
  final bool loading;
  final VoidCallback? onTap;

  const _GoogleButton({required this.isDark, required this.cardBg, required this.border,
      required this.loading, this.onTap});

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
    onTapUp: widget.onTap != null ? (_) { setState(() => _pressed = false); widget.onTap?.call(); } : null,
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: 100.ms,
      child: AnimatedOpacity(
        duration: 150.ms,
        opacity: widget.onTap == null ? 0.45 : 1.0,
        child: Container(
          width: double.infinity, height: 52,
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.border),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const GoogleLogo(),
            const SizedBox(width: 10),
            Text('Continue with Google',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : AppColors.black)),
          ]),
        ),
      ),
    ),
  );
}
