import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';

class HokimiyatAboutScreen extends StatelessWidget {
  const HokimiyatAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.hokimiyatAbout)),
      backgroundColor: kColorCream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kColorWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF30B0C7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance, color: Color(0xFF30B0C7), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.hokimiyatOrgName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk)),
                            const SizedBox(height: 2),
                            Text(s.hokimiyatRegion,
                                style: const TextStyle(fontSize: 13, color: kColorTextMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: s.address,
                    value: s.addressValue,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: s.receptionOffice,
                    value: '+998 73 394 00 00',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: s.emailLabel,
                    value: 'hokimiyat@turakurgan.uz',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    label: s.workHours,
                    value: s.workHoursValue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kColorWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.districtAboutTitle,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
                  const SizedBox(height: 12),
                  Text(
                    s.districtAboutBody,
                    style: const TextStyle(fontSize: 14, color: kColorTextMuted, height: 1.7),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kColorPrimary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: kColorTextMuted, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 14, color: kColorInk, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
