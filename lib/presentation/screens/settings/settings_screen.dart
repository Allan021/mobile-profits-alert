import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profitalerts/core/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user.dart';
import '../../../services/notification_service.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final user = ref.watch(authProvider)!;
    final prefs = ref.watch(prefsProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    final themeName = themeMode == ThemeMode.dark
        ? l.darkMode
        : themeMode == ThemeMode.light
            ? l.lightMode
            : l.systemMode;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            // Profile header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primary.withOpacity(0.15),
                    child: Text(
                      user.displayName[0],
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(user.displayName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          _PlanBadge(tier: user.tier),
                        ]),
                        Text(user.email, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showEditProfile(context, ref, user.displayName, user.email, isDark, primary),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        border: Border.all(color: primary.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(l.edit, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primary)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferences
            _SectionLabel(label: l.preferences),
            _SettingsCard(isDark: isDark, children: [
              _ToggleTile(
                icon: Icons.notifications_outlined,
                title: l.pushNotifications,
                subtitle: user.canUsePushNotifications
                    ? l.pushNotificationsSubtitle
                    : 'Pro plan required',
                value: user.canUsePushNotifications && (prefs['pushEnabled'] ?? false),
                onChanged: user.canUsePushNotifications
                    ? (val) async {
                        ref.read(prefsProvider.notifier).toggle('pushEnabled');
                        if (val) {
                          await NotificationService.instance.registerToken(apiClient);
                        } else {
                          await NotificationService.instance.unregisterToken(apiClient);
                        }
                      }
                    : (_) => _showUpgradePrompt(context, l, isDark, primary),
              ),
              const Divider(height: 1),
              _ToggleTile(
                icon: Icons.email_outlined,
                title: l.emailSummaries,
                subtitle: l.emailSummariesSubtitle,
                value: prefs['emailEnabled'] ?? false,
                onChanged: (_) async {
                  ref.read(prefsProvider.notifier).toggle('emailEnabled');
                  try {
                    await apiClient.post(ApiEndpoints.userPreferences, data: {
                      'email_alerts': !(prefs['emailEnabled'] ?? false),
                    });
                  } catch (_) {}
                },
              ),
              const Divider(height: 1),
              _NavTile(
                icon: Icons.dark_mode_outlined,
                title: l.appearance,
                trailing: themeName,
                onTap: () => _showThemePicker(context, ref, l, isDark, primary),
              ),
            ]),
            const SizedBox(height: 20),

            // Account
            _SectionLabel(label: l.account),
            _SettingsCard(isDark: isDark, children: [
              _NavTile(icon: Icons.security_outlined, iconColor: const Color(0xFF6366F1), title: l.security,
                  onTap: () => _showChangePassword(context, isDark, primary)),
              const Divider(height: 1),
              _NavTile(
                icon: Icons.credit_card_outlined, iconColor: const Color(0xFFF59E0B),
                title: l.billingSubscriptions,
                trailing: user.tier == UserTier.pro ? 'Pro' : 'Free',
                onTap: () => _showBillingInfo(context, user, isDark, primary),
              ),
              // hidden on iOS — App Store guideline 3.1.1 (external billing)
              if (user.isFree && kShowExternalBilling) ...[
                const Divider(height: 1),
                _NavTile(
                  icon: Icons.rocket_launch_outlined,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Upgrade a Pro',
                  trailing: '\$29.99/mes',
                  onTap: () => context.push('/plans'),
                ),
              ],
              const Divider(height: 1),
              _NavTile(
                icon: Icons.support_agent_rounded,
                iconColor: const Color(0xFF22C55E),
                title: l.helpSupport,
                onTap: () => launchUrl(
                  Uri.parse('mailto:support@profitalerts.app'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Language
            _SectionLabel(label: l.language),
            _SettingsCard(isDark: isDark, children: [
              _LangTile(
                title: 'English',
                selected: locale.languageCode == 'en',
                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                primary: primary,
              ),
              const Divider(height: 1),
              _LangTile(
                title: 'Español',
                selected: locale.languageCode == 'es',
                onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('es')),
                primary: primary,
              ),
            ]),
            const SizedBox(height: 20),

            // About
            _SectionLabel(label: l.about),
            _SettingsCard(isDark: isDark, children: [
              _NavTile(icon: Icons.info_outline, iconColor: const Color(0xFF3B82F6), title: l.version, trailing: kAppVersion, onTap: () {}),
              const Divider(height: 1),
              _NavTile(icon: Icons.description_outlined, iconColor: const Color(0xFF8B5CF6), title: l.termsOfService, onTap: () {}),
              const Divider(height: 1),
              _NavTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF06B6D4),
                title: l.privacyPolicy,
                onTap: () {
                  final lang = ref.read(localeProvider)?.languageCode ?? 'en';
                  launchUrl(Uri.parse('https://www.profitalerts.app/privacy?lang=$lang'), mode: LaunchMode.externalApplication);
                },
              ),
              const Divider(height: 1),
              _NavTile(
                icon: Icons.gavel_outlined,
                iconColor: const Color(0xFFF97316),
                title: (ref.read(localeProvider)?.languageCode == 'es') ? 'Términos y Condiciones' : 'Terms & Conditions',
                onTap: () {
                  final lang = ref.read(localeProvider)?.languageCode ?? 'en';
                  launchUrl(Uri.parse('https://www.profitalerts.app/terms?lang=$lang'), mode: LaunchMode.externalApplication);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Danger zone — account deletion (App Store guideline 5.1.1(v))
            _SectionLabel(
                label: ref.read(localeProvider)?.languageCode == 'es'
                    ? 'Zona de peligro'
                    : 'Danger zone'),
            _SettingsCard(isDark: isDark, children: [
              _NavTile(
                icon: Icons.delete_forever_outlined,
                iconColor: isDark ? AppColors.negativeDark : AppColors.negativeLight,
                title: ref.read(localeProvider)?.languageCode == 'es'
                    ? 'Eliminar cuenta'
                    : 'Delete account',
                onTap: () => _confirmDeleteAccount(context, ref, isDark),
              ),
            ]),
            const SizedBox(height: 20),

            // Logout
            GestureDetector(
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.negativeDark : AppColors.negativeLight).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isDark ? AppColors.negativeDark : AppColors.negativeLight).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 18,
                        color: isDark ? AppColors.negativeDark : AppColors.negativeLight),
                    const SizedBox(width: 8),
                    Text(l.logOut,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.negativeDark : AppColors.negativeLight)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref, bool isDark) {
    final es = ref.read(localeProvider)?.languageCode == 'es';
    final danger = isDark ? AppColors.negativeDark : AppColors.negativeLight;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          es ? '¿Eliminar tu cuenta?' : 'Delete your account?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          es
              ? 'Esta acción es permanente. Se borrarán tu perfil, watchlist, alertas e historial. No se puede deshacer.'
              : 'This is permanent. Your profile, watchlist, alerts and history will be erased. This cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(es ? 'Cancelar' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await apiClient.delete(ApiEndpoints.deleteAccount);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              } on ApiException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message)),
                  );
                }
              }
            },
            child: Text(
              es ? 'Eliminar definitivamente' : 'Delete permanently',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradePrompt(BuildContext context, AppLocalizations l, bool isDark, Color primary) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.upgradeToProTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text(
          l.upgradeToProSubtitle,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.learnMore, style: GoogleFonts.inter(color: primary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, String currentName, String currentEmail, bool isDark, Color primary) {
    final nameCtrl = TextEditingController(text: currentName);
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Edit Profile', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text('Display Name', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(controller: nameCtrl,
              decoration: InputDecoration(hintText: 'Your name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await apiClient.post(ApiEndpoints.userProfile, data: {'display_name': nameCtrl.text.trim()});
                } catch (_) {}
              },
              child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isDark ? AppColors.black : Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showChangePassword(BuildContext context, bool isDark, Color primary) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Change Password', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(controller: currentCtrl, obscureText: true,
              decoration: InputDecoration(labelText: 'Current password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 10),
          TextField(controller: newCtrl, obscureText: true,
              decoration: InputDecoration(labelText: 'New password (min 8)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 10),
          TextField(controller: confirmCtrl, obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm new password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.negativeDark)),
          ],
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) { setS(() => error = 'Passwords do not match'); return; }
                if (newCtrl.text.length < 8) { setS(() => error = 'Min 8 characters'); return; }
                try {
                  await apiClient.post(ApiEndpoints.userChangePassword, data: {
                    'current_password': currentCtrl.text,
                    'new_password': newCtrl.text,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                } on ApiException catch (e) {
                  setS(() => error = e.message == 'wrong_current_password' ? 'Incorrect current password' : e.message);
                }
              },
              child: Text('Update Password', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isDark ? AppColors.black : Colors.white)),
            ),
          ),
        ]),
      )),
    );
  }

  void _showBillingInfo(BuildContext context, dynamic user, bool isDark, Color primary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 56, height: 56,
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(Icons.workspace_premium_rounded, size: 28, color: primary)),
          const SizedBox(height: 16),
          Text('Your Plan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(
                user.tier == UserTier.pro ? 'Pro' : 'Free',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: primary),
              )),
          const SizedBox(height: 12),
          Text('Real-time alerts • Unlimited watchlist • AI analysis',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, AppLocalizations l, bool isDark, Color primary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.appearance, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...{ThemeMode.system: l.systemMode, ThemeMode.dark: l.darkMode, ThemeMode.light: l.lightMode}.entries.map(
              (e) => ListTile(
                title: Text(e.value, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                trailing: ref.watch(themeProvider) == e.key ? Icon(Icons.check, color: primary) : null,
                onTap: () {
                  ref.read(themeProvider.notifier).setMode(e.key);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
  );
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
    ),
    child: Column(children: children),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, size: 20),
    title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
    subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
    trailing: Switch(value: value, onChanged: onChanged),
  );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _NavTile({required this.icon, this.iconColor, required this.title, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: iconColor != null
          ? Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: iconColor!.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            )
          : Icon(icon, size: 20),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14,
          color: isDark ? Colors.white : AppColors.black)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _LangTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  const _LangTile({required this.title, required this.selected, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
    trailing: selected ? Icon(Icons.check, color: primary, size: 18) : null,
    onTap: onTap,
  );
}

class _PlanBadge extends StatelessWidget {
  final UserTier tier;
  const _PlanBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (tier) {
      case UserTier.pro:
        color = const Color(0xFF0EA5E9);
        label = 'Pro';
        break;
      case UserTier.free:
        color = AppColors.textMuted;
        label = 'Free';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
