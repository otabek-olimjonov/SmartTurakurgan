import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/yangiliklar/data/repositories/yangilik_repository.dart';
import 'package:smart_turakurgan/features/yangiliklar/presentation/screens/news_screen.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _kPageBg = Color(0xFFF2F2F7);

BoxDecoration _cardShadow() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
      ],
    );

// ── Data models ────────────────────────────────────────────────────────────────
class _BannerData {
  final Color color;
  final Color accent;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final String route;
  const _BannerData({
    required this.color,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.route,
  });
}

class _CategoryData {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _CategoryData({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

// ── HomeScreen ─────────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerCtrl = PageController(viewportFraction: 0.92);
  Timer? _bannerTimer;
  int _bannerPage = 0;

  static const _banners = [
    _BannerData(
      color: Color(0xFF1D9E75),
      accent: Color(0xFF0D6B4E),
      title: "Murojaat yo'llang",
      subtitle: "Muammolaringizni rasman ro'yxatdan o'tkaring",
      buttonLabel: "Ko'rish",
      icon: Icons.mail_outline_rounded,
      route: '/boglanish',
    ),
    _BannerData(
      color: Color(0xFF1A3A6B),
      accent: Color(0xFF0D1F3C),
      title: "AI Yordamchi",
      subtitle: "Sun'iy intellekt sizning savollaringizga javob beradi",
      buttonLabel: "Boshlash",
      icon: Icons.auto_awesome_rounded,
      route: '/ai',
    ),
    _BannerData(
      color: Color(0xFF7C3AED),
      accent: Color(0xFF4C1D95),
      title: "Interaktiv Xarita",
      subtitle: "Barcha ob'ektlar xaritada ko'rsatilgan",
      buttonLabel: "Ochish",
      icon: Icons.map_rounded,
      route: '/map',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _bannerPage = (_bannerPage + 1) % _banners.length;
      _bannerCtrl.animateToPage(
        _bannerPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  List<_CategoryData> _buildCategories(AppLocalizations l10n) => [
        _CategoryData(
            label: l10n.hokimiyat,
            icon: Icons.account_balance_rounded,
            color: const Color(0xFFFF9500),
            route: '/hokimiyat'),
        _CategoryData(
            label: l10n.turizm,
            icon: Icons.landscape_rounded,
            color: const Color(0xFFFF6B6B),
            route: '/turizm'),
        _CategoryData(
            label: l10n.talim,
            icon: Icons.school_rounded,
            color: const Color(0xFF34C759),
            route: '/talim'),
        _CategoryData(
            label: l10n.tibbiyot,
            icon: Icons.local_hospital_rounded,
            color: const Color(0xFFFF3B30),
            route: '/tibbiyot'),
        _CategoryData(
            label: l10n.tashkilotlar,
            icon: Icons.business_rounded,
            color: const Color(0xFF007AFF),
            route: '/tashkilotlar'),
        _CategoryData(
            label: l10n.aiAssistant,
            icon: Icons.auto_awesome_rounded,
            color: kColorPrimary,
            route: '/ai'),
        _CategoryData(
            label: l10n.boglanish,
            icon: Icons.contact_phone_rounded,
            color: const Color(0xFFAF52DE),
            route: '/boglanish'),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _buildCategories(l10n);
    final newsAsync = ref.watch(newsProvider);
    final lang = localeKey(ref.watch(localeProvider));

    return Scaffold(
      backgroundColor: _kPageBg,
      body: CustomScrollView(
        slivers: [
          // ── App bar + search bar ─────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 56,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset('assets/images/logo.png',
                      width: 28, height: 28, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.appName,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: kColorInk),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: kColorInk),
                onPressed: () =>
                    Navigator.pushNamed(context, '/notifications'),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _kPageBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: kColorTextMuted, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.search,
                          style: const TextStyle(
                              fontSize: 15, color: kColorTextMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Banner ads carousel ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 152,
                  child: PageView.builder(
                    controller: _bannerCtrl,
                    onPageChanged: (i) =>
                        setState(() => _bannerPage = i),
                    itemCount: _banners.length,
                    itemBuilder: (_, i) => _BannerCard(
                      data: _banners[i],
                      onTap: () =>
                          Navigator.pushNamed(context, _banners[i].route),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _banners.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _bannerPage == i ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _bannerPage == i
                            ? kColorPrimary
                            : kColorStone,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Category label ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
              child: Text(
                l10n.services,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kColorInk),
              ),
            ),
          ),

          // ── Category chips (horizontal scroll) ──────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (_, i) =>
                    _CategoryTile(data: categories[i]),
              ),
            ),
          ),

          // ── News section header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.navNews,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kColorInk),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/news'),
                    child: Row(
                      children: const [
                        Text(
                          'Hammasi',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: kColorPrimary),
                        ),
                        Icon(Icons.chevron_right,
                            color: kColorPrimary, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── News 2-column grid ───────────────────────────────────────────
          newsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: Center(
                    child: CircularProgressIndicator(
                        color: kColorPrimary, strokeWidth: 2)),
              ),
            ),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (news) {
              if (news.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              final items = news.take(6).toList();
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.76,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _NewsGridCard(
                      item: items[i],
                      lang: lang,
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) =>
                              NewsDetailScreen(newsId: items[i].id),
                        ),
                      ),
                    ),
                    childCount: items.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── _BannerCard ────────────────────────────────────────────────────────────────
class _BannerCard extends StatelessWidget {
  final _BannerData data;
  final VoidCallback onTap;
  const _BannerCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [data.color, data.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data.buttonLabel,
                      style: TextStyle(
                        color: data.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(data.icon,
                color: Colors.white.withValues(alpha: 0.2), size: 76),
          ],
        ),
      ),
    );
  }
}

// ── _CategoryTile ──────────────────────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final _CategoryData data;
  const _CategoryTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, data.route),
      child: SizedBox(
        width: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(data.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 7),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: kColorInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _NewsGridCard ──────────────────────────────────────────────────────────────
class _NewsGridCard extends StatelessWidget {
  final dynamic item;
  final String lang;
  final VoidCallback onTap;
  const _NewsGridCard(
      {required this.item, required this.lang, required this.onTap});

  String _timeAgo(String? dt) {
    if (dt == null) return '';
    try {
      return timeago.format(DateTime.parse(dt), locale: 'uz');
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = item.localizedTitle(lang) as String;
    final imageUrl = item.coverImageUrl as String?;
    final category = item.category as String;
    final publishedAt = item.publishedAt as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _cardShadow(),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: kColorStone),
                      errorWidget: (_, __, ___) => Container(
                        color: kColorStone,
                        child: const Center(
                          child: Icon(Icons.article_outlined,
                              color: kColorTextMuted, size: 28),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: kColorStone,
                      child: const Center(
                        child: Icon(Icons.article_outlined,
                            color: kColorTextMuted, size: 28),
                      ),
                    ),
                  // Category badge on image
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: kColorPrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kColorInk,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (publishedAt != null)
                      Text(
                        _timeAgo(publishedAt),
                        style: const TextStyle(
                            fontSize: 11, color: kColorTextMuted),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
