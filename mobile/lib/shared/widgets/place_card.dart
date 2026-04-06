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
  final String callLabel;
  final String mapLabel;

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
    this.callLabel = "Qo'ng'iroq",
    this.mapLabel = 'Xarita',
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
            // Cover image — always shown, 4:3 ratio like Airbnb
            AspectRatio(
              aspectRatio: 4 / 3,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: kColorStone),
                      errorWidget: (_, __, ___) => _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: kColorInk,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (rating > 0) ...[
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: kColorGold),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: kColorInk,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (description != null && description!.isNotEmpty) ...[  
                    const SizedBox(height: 5),
                    Text(
                      description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kColorTextMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (phone != null) ...[  
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.phone_outlined,
                            label: callLabel,
                            onTap: onCallTap,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.map_outlined,
                          label: mapLabel,
                          onTap: onMapTap,
                        ),
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

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kColorStone,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 36, color: kColorTextMuted),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: kColorStone, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
