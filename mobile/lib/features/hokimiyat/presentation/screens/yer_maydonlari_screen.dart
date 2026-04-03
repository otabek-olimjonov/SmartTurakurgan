import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/hokimiyat/data/repositories/hokimiyat_repository.dart';

class YerMaydonlariScreen extends ConsumerWidget {
  const YerMaydonlariScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(yerMaydonlariProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Yer maydonlari')),
      backgroundColor: kColorCream,
      body: listAsync.when(
        loading: () => const LoadingCardList(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (list) {
          if (list.isEmpty) return const EmptyView(message: "Yer maydonlari topilmadi");
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final yer = list[index];
              return Container(
                decoration: BoxDecoration(
                  color: kColorWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kColorStone, width: 0.5),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(yer.title,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kColorInk)),
                        ),
                        _StatusBadge(status: yer.status),
                      ],
                    ),
                    if (yer.areaHectares != null) ...[
                      const SizedBox(height: 4),
                      Text('${yer.areaHectares} gektar',
                          style: const TextStyle(fontSize: 13, color: kColorTextMuted)),
                    ],
                    if (yer.description != null && yer.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(yer.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
                    ],
                    if (yer.auctionUrl != null) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(yer.auctionUrl!),
                            mode: LaunchMode.externalApplication),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: const Text('E-auksion', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ("Aktiv", kColorSuccess),
      'sold' => ("Sotilgan", kColorDanger),
      'pending' => ("Kutilmoqda", kColorWarning),
      _ => (status, kColorTextMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
