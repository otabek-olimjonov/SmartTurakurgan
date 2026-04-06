import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:smart_turakurgan/core/theme/colors.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String? coverImageUrl;
  final String category;
  final String? publishedAt;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.title,
    this.coverImageUrl,
    this.category = 'general',
    this.publishedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kColorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kColorStone, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-width cover image — 16:9
            AspectRatio(
              aspectRatio: 16 / 9,
              child: coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: coverImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: kColorStone),
                      errorWidget: (_, __, ___) => Container(
                        color: kColorStone,
                        child: const Center(
                          child: Icon(Icons.article_outlined, size: 36, color: kColorTextMuted),
                        ),
                      ),
                    )
                  : Container(
                      color: kColorStone,
                      child: const Center(
                        child: Icon(Icons.article_outlined, size: 36, color: kColorTextMuted),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: kColorPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: kColorPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (publishedAt != null) ...[
                        const Spacer(),
                        Text(
                          _formatTime(publishedAt!),
                          style: const TextStyle(fontSize: 11, color: kColorTextMuted),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: kColorInk,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return timeago.format(dt, locale: 'uz');
  }
}
