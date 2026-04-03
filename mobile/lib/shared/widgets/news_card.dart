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
        child: Row(
          children: [
            if (coverImageUrl != null)
              CachedNetworkImage(
                imageUrl: coverImageUrl!,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(width: 90, height: 90, color: kColorStone),
                errorWidget: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: kColorStone,
                  child: const Icon(Icons.image_outlined, color: kColorTextMuted),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: kColorPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(category,
                          style: const TextStyle(fontSize: 10, color: kColorPrimary, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 6),
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kColorInk, height: 1.4)),
                    if (publishedAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(publishedAt!),
                        style: const TextStyle(fontSize: 11, color: kColorTextMuted),
                      ),
                    ],
                  ],
                ),
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
