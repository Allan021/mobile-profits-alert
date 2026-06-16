import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import 'auth_widgets.dart';
// ignore: unused_import
import '../../../data/services/google_auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  String? _error;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _googleSignIn(BuildContext context, WidgetRef ref) async {
    setState(() { _loading = true; _error = null; });
    final googleSvc = ref.read(googleAuthServiceProvider);
    final err = await ref.read(authProvider.notifier).loginWithGoogle(googleSvc);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err == null) {
      context.go('/');
    } else if (err != 'cancelled') {
      setState(() => _error = err);
    }
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err == null) {
      context.go('/onboarding');
    } else {
      setState(() => _error = err);
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  primary.withValues(alpha: 0.07),
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
                  const SizedBox(height: 48),

                  // Brand
                  AuthBrandMark(primary: primary)
                      .animate()
                      .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.15, end: 0, duration: 400.ms),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    l.loginTitle,
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                  )
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.18, end: 0),

                  const SizedBox(height: 6),

                  Text(
                    l.loginSubtitle,
                    style: GoogleFonts.inter(
                        fontSize: 15, color: AppColors.textMuted, height: 1.5),
                  )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 36),

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
                            .animate(delay: 160.ms)
                            .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
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
                            .animate(delay: 210.ms)
                            .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),

                  AuthError(error: _error, isDark: isDark),

                  const SizedBox(height: 24),

                  AuthPrimaryButton(
                    loading: _loading,
                    onTap: _loading ? null : _login,
                    primary: primary,
                    isDark: isDark,
                    label: l.signIn,
                  )
                      .animate(delay: 260.ms)
                      .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.22, end: 0),

                  const SizedBox(height: 14),

                  // Google login — Android/web only (App Store guideline 4.8:
                  // would require Sign in with Apple alongside it on iOS)
                  if (kShowGoogleSignIn) ...[
                    Row(
                      children: [
                        Expanded(
                            child: Divider(color: border, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500)),
                        ),
                        Expanded(
                            child: Divider(color: border, thickness: 1)),
                      ],
                    ).animate(delay: 300.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 14),

                    _SocialButton(
                      label: l.continueWithGoogle,
                      isDark: isDark,
                      cardBg: cardBg,
                      border: border,
                      icon: const GoogleLogo(),
                      onTap: _loading ? null : () => _googleSignIn(context, ref),
                    )
                        .animate(delay: 330.ms)
                        .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                        .slideY(begin: 0.18, end: 0),
                  ],

                  const SizedBox(height: 36),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.noAccount,
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted, fontSize: 14)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text(
                          l.signUp,
                          style: GoogleFonts.inter(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ).animate(delay: 370.ms).fadeIn(duration: 300.ms),

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

class _SocialButton extends StatefulWidget {
  final String label;
  final bool isDark;
  final Color cardBg;
  final Color border;
  final Widget icon;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.icon,
    this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: 100.ms,
        child: AnimatedOpacity(
          duration: 150.ms,
          opacity: widget.onTap == null ? 0.45 : 1.0,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: widget.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.icon,
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
