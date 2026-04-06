import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/features/yangiliklar/data/repositories/yangilik_repository.dart';
import 'package:smart_turakurgan/features/yangiliklar/presentation/screens/news_screen.dart';
import 'package:smart_turakurgan/shared/widgets/news_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  List<_Section> _buildSections(AppLocalizations l10n) => [
    _Section(l10n.hokimiyat, Icons.account_balance_outlined, '/hokimiyat'),
    _Section(l10n.turizm, Icons.landscape_outlined, '/turizm'),
    _Section(l10n.talim, Icons.school_outlined, '/talim'),
    _Section(l10n.tibbiyot, Icons.local_hospital_outlined, '/tibbiyot'),
    _Section(l10n.tashkilotlar, Icons.business_outlined, '/tashkilotlar'),
    _Section(l10n.aiAssistant, Icons.auto_awesome_outlined, '/ai'),
    _Section(l10n.boglanish, Icons.contact_phone_outlined, '/boglanish'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sections = _buildSections(l10n);
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
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 8),
                Text(l10n.appName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk)),
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
                  Text(l10n.services,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kColorInk)),
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
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final s = sections[index];
                      return _SectionTile(section: s);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Quick news preview header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.navNews,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/news'),
                    child: const Text('›', style: TextStyle(color: kColorPrimary, fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
          // News preview cards
          _NewsPreview(onShowAll: () => Navigator.pushNamed(context, '/news')),
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

class _SectionTile extends StatelessWidget {  final _Section section;
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

class _NewsPreview extends ConsumerWidget {
  final VoidCallback onShowAll;
  const _NewsPreview({required this.onShowAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
    final lang = localeKey(ref.watch(localeProvider));
    return SliverToBoxAdapter(
      child: newsAsync.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(color: kColorPrimary, strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (news) {
          if (news.isEmpty) return const SizedBox.shrink();
          final preview = news.take(3).toList();
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: preview
                  .map((n) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NewsCard(
                          title: n.localizedTitle(lang),
                          coverImageUrl: n.coverImageUrl,
                          category: n.category,
                          publishedAt: n.publishedAt,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NewsDetailScreen(newsId: n.id),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
