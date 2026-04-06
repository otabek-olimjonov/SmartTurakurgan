import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/features/home/presentation/screens/home_screen.dart';
import 'package:smart_turakurgan/features/home/presentation/screens/map_screen.dart';
import 'package:smart_turakurgan/features/yangiliklar/presentation/screens/news_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    MapScreen(),
    NewsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: kColorWhite,
        indicatorColor: kColorPrimary.withValues(alpha: 0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: kColorPrimary),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map, color: kColorPrimary),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.newspaper_outlined),
            selectedIcon: const Icon(Icons.newspaper, color: kColorPrimary),
            label: l10n.navNews,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: kColorPrimary),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
