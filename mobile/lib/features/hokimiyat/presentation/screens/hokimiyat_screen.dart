import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/tashkilotlar/presentation/screens/place_list_screen.dart';
import 'rahbariyat_screen.dart';
import 'mahallalar_screen.dart';
import 'yer_maydonlari_screen.dart';

class HokimiyatScreen extends StatelessWidget {
  const HokimiyatScreen({super.key});

  static const _items = [
    _MenuItem("Hokimiyat to'g'risida", Icons.info_outline, '/hokimiyat/about'),
    _MenuItem('Rahbariyat', Icons.people_outline, '/hokimiyat/rahbariyat'),
    _MenuItem('Apparat', Icons.supervised_user_circle_outlined, '/hokimiyat/apparat'),
    _MenuItem('Kengash', Icons.account_balance_outlined, '/hokimiyat/kengash'),
    _MenuItem('Mahallalar', Icons.home_work_outlined, '/hokimiyat/mahallalar'),
    _MenuItem('Yer maydonlari', Icons.terrain_outlined, '/hokimiyat/yer'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tuman hokimligi')),
      backgroundColor: kColorCream,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _items[index];
          return _MenuTile(item: item);
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kColorStone, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kColorPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: kColorPrimary, size: 20),
        ),
        title: Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: kColorTextMuted, size: 20),
        onTap: () => _navigate(context),
      ),
    );
  }

  void _navigate(BuildContext context) {
    switch (item.route) {
      case '/hokimiyat/rahbariyat':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const RahbariyatScreen(title: 'Rahbariyat', category: 'rahbariyat'),
        ));
      case '/hokimiyat/apparat':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const RahbariyatScreen(title: 'Apparat', category: 'apparat'),
        ));
      case '/hokimiyat/kengash':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const RahbariyatScreen(title: 'Kengash', category: 'kotibiyat'),
        ));
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
  const _MenuItem(this.label, this.icon, this.route);
}
