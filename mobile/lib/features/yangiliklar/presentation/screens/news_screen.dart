import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/shared/widgets/news_card.dart';
import 'package:smart_turakurgan/shared/widgets/image_carousel.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/yangiliklar/data/repositories/yangilik_repository.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/shared/models/yangilik_model.dart';

const int _kPageSize = 20;

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final ScrollController _sc = ScrollController();
  final List<YangilikModel> _items = [];
  int _offset = 0;
  bool _hasMore = true;
  bool _loading = false;
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _sc.addListener(() {
      if (_sc.position.pixels >= _sc.position.maxScrollExtent - 150 &&
          !_loading && _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    setState(() => _loading = true);
    final repo = ref.read(yangilikRepositoryProvider);
    final items = await repo.getNews(limit: _kPageSize, offset: _offset);
    setState(() {
      _items.addAll(items);
      _offset += items.length;
      _hasMore = items.length == _kPageSize;
      _loading = false;
      _initialLoad = false;
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = localeKey(ref.watch(localeProvider));
    final l10n = AppLocalizations.of(context);

    if (_initialLoad) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navNews)),
        backgroundColor: kColorCream,
        body: const LoadingCardList(),
      );
    }

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navNews)),
        backgroundColor: kColorCream,
        body: const EmptyView(message: 'Yangiliklar topilmadi'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navNews)),
      backgroundColor: kColorCream,
      body: ListView.separated(
        controller: _sc,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: kColorPrimary, strokeWidth: 2)),
            );
          }
          final n = _items[index];
          return NewsCard(
            title: n.localizedTitle(lang),
            coverImageUrl: n.coverImageUrl,
            category: n.category,
            publishedAt: n.publishedAt,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NewsDetailScreen(newsId: n.id)),
            ),
          );
        },
      ),
    );
  }
}

class NewsDetailScreen extends ConsumerWidget {
  final String newsId;
  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(yangilikByIdProvider(newsId));
    final lang = localeKey(ref.watch(localeProvider));
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: newsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kColorPrimary)),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (news) {
          if (news == null) return const ErrorView(message: "Yangilik topilmadi");
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: const BackButton(),
                backgroundColor: Colors.white,
                foregroundColor: kColorInk,
                elevation: 0.5,
                expandedHeight: 0,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageCarousel(
                      imageUrls: news.imageUrls.isNotEmpty
                          ? news.imageUrls
                          : (news.coverImageUrl != null ? [news.coverImageUrl!] : []),
                      height: 250,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: kColorPrimary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(news.category,
                                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(height: 12),
                          Text(news.localizedTitle(lang),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: kColorInk, height: 1.4)),
                          if (news.publishedAt != null) ...[
                            const SizedBox(height: 8),
                            Text(_formatDate(news.publishedAt!),
                                style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
                          ],
                          if (news.localizedBody(lang) != null && news.localizedBody(lang)!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(news.localizedBody(lang)!,
                                style: const TextStyle(fontSize: 15, color: kColorInk, height: 1.7)),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
