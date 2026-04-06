import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 270,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _ctrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Container(
          color: kColorStone,
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined, size: 48, color: kColorTextMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.imageUrls.length,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: widget.imageUrls[i],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => Container(color: kColorStone),
              errorWidget: (_, __, ___) => Container(
                color: kColorStone,
                child: const Center(
                  child: Icon(Icons.broken_image_outlined, size: 40, color: kColorTextMuted),
                ),
              ),
            ),
          ),
          // Dots indicator
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _current == i ? Colors.white : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          // Counter badge
          if (widget.imageUrls.length > 1)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_current + 1} / ${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
