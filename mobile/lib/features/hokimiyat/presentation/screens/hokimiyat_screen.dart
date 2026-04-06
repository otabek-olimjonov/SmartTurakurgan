import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'rahbariyat_screen.dart';
import 'mahallalar_screen.dart';
import 'yer_maydonlari_screen.dart';
import 'tuman_about_screen.dart';

class HokimiyatScreen extends StatelessWidget {
  const HokimiyatScreen({super.key});

  List<_MenuItem> _buildItems(AppLocalizations l10n) => [
    _MenuItem(l10n.tumanAbout, Icons.landscape_rounded, '/hokimiyat/tuman', const Color(0xFF5856D6)),
    _MenuItem(l10n.hokimiyatAbout, Icons.info_rounded, '/hokimiyat/about', const Color(0xFF30B0C7)),
    _MenuItem(l10n.rahbariyat, Icons.people_rounded, '/hokimiyat/rahbariyat', const Color(0xFFFF9500)),
    _MenuItem(l10n.apparat, Icons.supervised_user_circle_rounded, '/hokimiyat/apparat', const Color(0xFF34C759)),
    _MenuItem(l10n.kengash, Icons.account_balance_rounded, '/hokimiyat/kengash', const Color(0xFF007AFF)),
    _MenuItem(l10n.mahallalar, Icons.home_work_rounded, '/hokimiyat/mahallalar', const Color(0xFFFF6B6B)),
    _MenuItem(l10n.yerMaydon, Icons.terrain_rounded, '/hokimiyat/yer', const Color(0xFFAF52DE)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _buildItems(l10n);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.hokimiyat)),
      backgroundColor: kColorCream,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return _MenuTile(item: item, l10n: l10n);
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final AppLocalizations l10n;
  const _MenuTile({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.color, size: 22),
        ),
        title: Text(item.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kColorInk)),
        trailing: const Icon(Icons.chevron_right, color: kColorTextMuted, size: 20),
        onTap: () => _navigate(context),
      ),
    );
  }

  void _navigate(BuildContext context) {
    switch (item.route) {
      case '/hokimiyat/rahbariyat':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => RahbariyatScreen(title: l10n.rahbariyat, category: 'rahbariyat'),
        ));
      case '/hokimiyat/apparat':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => RahbariyatScreen(title: l10n.apparat, category: 'apparat'),
        ));
      case '/hokimiyat/kengash':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => RahbariyatScreen(title: l10n.kengash, category: 'kotibiyat'),
        ));
      case '/hokimiyat/tuman':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TumanAboutScreen()));
      case '/hokimiyat/mahallalar':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MahallalarScreen()));
      case '/hokimiyat/yer':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const YerMaydonlariScreen()));
      default:
        Navigator.pushNamed(context, item.route);
    }
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  const _MenuItem(this.label, this.icon, this.route, this.color);
}
