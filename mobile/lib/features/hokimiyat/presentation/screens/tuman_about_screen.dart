import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';

class TumanAboutScreen extends StatelessWidget {
  const TumanAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.tumanAbout)),
      backgroundColor: kColorCream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kColorWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kColorStone, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: kColorPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.map_outlined, color: kColorPrimary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Turakurgan tumani',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Namangan viloyati, O\'zbekiston',
                          style: TextStyle(fontSize: 13, color: kColorTextMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats grid
            _SectionTitle(title: s.tumanKeyFacts),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(label: s.tumanAreaLabel, value: '1 095 km²', icon: Icons.straighten_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: s.tumanPopulationLabel, value: '200 000+', icon: Icons.people_outline)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(label: s.tumanFoundedLabel, value: '1926', icon: Icons.history_outlined)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: s.tumanMahallalarLabel, value: '48', icon: Icons.home_work_outlined)),
              ],
            ),
            const SizedBox(height: 16),

            // Overview
            _TextCard(title: s.districtAboutTitle, body: s.districtAboutBody),
            const SizedBox(height: 12),

            // Geography
            _TextCard(title: s.tumanGeographyTitle, body: s.tumanGeographyBody),
            const SizedBox(height: 12),

            // Economy
            _TextCard(title: s.tumanEconomyTitle, body: s.tumanEconomyBody),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kColorTextMuted, letterSpacing: 0.3),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kColorStone, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kColorPrimary, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kColorInk)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  final String title;
  final String body;
  const _TextCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kColorStone, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
          const SizedBox(height: 12),
          Text(body,
              style: const TextStyle(fontSize: 14, color: kColorTextMuted, height: 1.7)),
        ],
      ),
    );
  }
}
