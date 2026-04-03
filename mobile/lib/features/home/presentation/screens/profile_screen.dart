import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/auth/secure_storage.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/home/presentation/screens/login_screen.dart';
import 'package:smart_turakurgan/features/home/presentation/screens/onboarding_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      backgroundColor: kColorCream,
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kColorPrimary)),
        error: (_, __) => const Center(child: Text('Xatolik')),
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
                          auth.userId != null ? 'Foydalanuvchi' : 'Kirish amalga oshirilmagan',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk),
                        ),
                        const SizedBox(height: 2),
                        Text(auth.role ?? '',
                            style: const TextStyle(fontSize: 13, color: kColorTextMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Language setting placeholder
            _SettingsTile(
              icon: Icons.language,
              title: 'Til',
              subtitle: "O'zbek",
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'Ilova haqida',
              subtitle: 'v1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout, size: 18, color: kColorDanger),
              label: const Text('Chiqish', style: TextStyle(color: kColorDanger)),
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
