import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _localeName(Locale locale) {
    for (final entry in localeNames) {
      if (entry.$1 == locale) return entry.$2;
    }
    return locale.toLanguageTag();
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final current = ref.read(localeProvider);
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(l10n.selectLanguage,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0A0A0A))),
                ],
              ),
            ),
            const Divider(height: 1),
            ...localeNames.map((entry) {
              final isSelected = entry.$1 == current;
              return ListTile(
                title: Text(entry.$2,
                    style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? kColorPrimary : const Color(0xFF0A0A0A),
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal)),
                trailing: isSelected
                    ? const Icon(Icons.check, color: kColorPrimary, size: 18)
                    : null,
                onTap: () => Navigator.pop(ctx, entry.$1),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) {
      ref.read(localeProvider.notifier).setLocale(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      backgroundColor: kColorCream,
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kColorPrimary)),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (auth) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: kColorWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kColorStone, width: 0.5),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: kColorPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.person, color: kColorPrimary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.fullName ?? auth.userId ?? l10n.notLoggedIn,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk),
                        ),
                        const SizedBox(height: 2),
                        if (auth.phoneNumber != null && auth.phoneNumber!.isNotEmpty)
                          Text(auth.phoneNumber!,
                              style: const TextStyle(fontSize: 13, color: kColorTextMuted))
                        else
                          Text(auth.role ?? '',
                              style: const TextStyle(fontSize: 13, color: kColorTextMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.language,
              title: l10n.languageSetting,
              subtitle: _localeName(locale),
              onTap: () => _pickLanguage(context, ref),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.info_outline,
              title: l10n.appAbout,
              subtitle: 'v1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout, size: 18, color: kColorDanger),
              label: Text(l10n.logout, style: const TextStyle(color: kColorDanger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kColorDanger),
                foregroundColor: kColorDanger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kColorStone, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: kColorPrimary, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
        trailing: const Icon(Icons.chevron_right, color: kColorTextMuted, size: 18),
        onTap: onTap,
      ),
    );
  }
}
