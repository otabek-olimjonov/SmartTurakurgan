import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _sections = [
    _Section('Tuman hokimligi', Icons.account_balance_outlined, '/hokimiyat'),
    _Section('Turizm', Icons.landscape_outlined, '/turizm'),
    _Section("Ta'lim", Icons.school_outlined, '/talim'),
    _Section('Tibbiyot', Icons.local_hospital_outlined, '/tibbiyot'),
    _Section('Tashkilotlar', Icons.business_outlined, '/tashkilotlar'),
    _Section('AI Yordamchi', Icons.auto_awesome_outlined, '/ai'),
    _Section("Bog'lanish", Icons.contact_phone_outlined, '/boglanish'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kColorCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: kColorWhite,
            title: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: kColorPrimary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.location_city, color: kColorWhite, size: 16),
                ),
                const SizedBox(width: 8),
                const Text('Smart Turakurgan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: kColorInk),
                onPressed: () => Navigator.pushNamed(context, '/search'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: kColorInk),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xizmatlar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kColorInk)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      final s = _sections[index];
                      return _SectionTile(section: s);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Quick news preview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('So\'nggi yangiliklar',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/news'),
                    child: const Text('Barchasi', style: TextStyle(color: kColorPrimary, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  final String label;
  final IconData icon;
  final String route;
  const _Section(this.label, this.icon, this.route);
}

class _SectionTile extends StatelessWidget {
  final _Section section;
  const _SectionTile({required this.section});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, section.route),
      child: Container(
        decoration: BoxDecoration(
          color: kColorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kColorStone, width: 0.5),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kColorPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(section.icon, color: kColorPrimary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              section.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kColorInk),
            ),
          ],
        ),
      ),
    );
  }
}
