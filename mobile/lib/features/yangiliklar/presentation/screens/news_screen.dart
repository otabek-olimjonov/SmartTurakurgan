import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_turakurgan/shared/widgets/news_card.dart';
import 'package:smart_turakurgan/shared/widgets/image_carousel.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/yangiliklar/data/repositories/yangilik_repository.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
    final lang = localeKey(ref.watch(localeProvider));
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navNews)),
      backgroundColor: kColorCream,
      body: newsAsync.when(
        loading: () => const LoadingCardList(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (news) {
          if (news.isEmpty) return const EmptyView(message: 'Yangiliklar topilmadi');
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: news.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final n = news[index];
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
