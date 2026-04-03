import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const LoadingShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: kColorStone,
      highlightColor: kColorCream,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: kColorStone,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class LoadingCardList extends StatelessWidget {
  final int count;

  const LoadingCardList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 90,
        decoration: BoxDecoration(
          color: kColorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kColorStone, width: 0.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: kColorStone,
          highlightColor: kColorCream,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 14, width: double.infinity, color: kColorStone, margin: const EdgeInsets.only(right: 40)),
              const SizedBox(height: 8),
              Container(height: 12, width: 160, color: kColorStone),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: kColorTextMuted),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: kColorTextMuted)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Qayta urinib ko\'ring')),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;

  const EmptyView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: kColorTextMuted),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: kColorTextMuted)),
          ],
        ),
      ),
    );
  }
}
