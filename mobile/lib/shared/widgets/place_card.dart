import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class PlaceCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String? phone;
  final String? description;
  final double rating;
  final VoidCallback? onTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onMapTap;

  const PlaceCard({
    super.key,
    required this.name,
    this.imageUrl,
    this.phone,
    this.description,
    this.rating = 0,
    this.onTap,
    this.onCallTap,
    this.onMapTap,
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
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(height: 160, color: kColorStone),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: kColorStone,
                  child: const Icon(Icons.image_outlined, color: kColorTextMuted),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
                      ),
                      if (rating > 0) ...[
                        const Icon(Icons.star, size: 14, color: kColorGold),
                        const SizedBox(width: 2),
                        Text(rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
                      ],
                    ],
                  ),
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: kColorTextMuted, height: 1.5)),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (phone != null)
                        _ActionButton(
                          icon: Icons.phone_outlined,
                          label: 'Qo\'ng\'iroq',
                          onTap: onCallTap,
                        ),
                      if (phone != null) const SizedBox(width: 8),
                      _ActionButton(
                        icon: Icons.map_outlined,
                        label: 'Xarita',
                        onTap: onMapTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: kColorStone, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kColorPrimary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: kColorPrimary)),
          ],
        ),
      ),
    );
  }
}
