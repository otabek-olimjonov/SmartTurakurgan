import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/widgets/person_card.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/hokimiyat/data/repositories/hokimiyat_repository.dart';

class MahallalarScreen extends ConsumerWidget {
  const MahallalarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(mahallalarProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mahallalar')),
      backgroundColor: kColorCream,
      body: listAsync.when(
        loading: () => const LoadingCardList(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (list) {
          if (list.isEmpty) return const EmptyView(message: "Mahallalar topilmadi");
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final m = list[index];
              return Container(
                decoration: BoxDecoration(
                  color: kColorWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kColorStone, width: 0.5),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kColorPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.home_outlined, color: kColorPrimary, size: 20),
                  ),
                  title: Text(m.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: m.description != null
                      ? Text(m.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: kColorTextMuted))
                      : null,
                  trailing: const Icon(Icons.chevron_right, color: kColorTextMuted, size: 20),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => _MahallalarDetailScreen(mahalla: m)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MahallalarDetailScreen extends ConsumerWidget {
  final MahallalarModel mahalla;
  const _MahallalarDetailScreen({required this.mahalla});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(
      FutureProvider.family((ref, String id) =>
          ref.read(hokimiyatRepositoryProvider).getMahallaxodimlari(id))(mahalla.id),
    );
    return Scaffold(
      appBar: AppBar(title: Text(mahalla.name)),
      backgroundColor: kColorCream,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (mahalla.description != null) ...[
            Text(mahalla.description!,
                style: const TextStyle(fontSize: 14, color: kColorTextMuted, height: 1.5)),
            const SizedBox(height: 16),
          ],
          const Text('Xodimlar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
          const SizedBox(height: 10),
          staffAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: kColorPrimary)),
            error: (e, _) => ErrorView(message: e.toString()),
            data: (staff) => Column(
              children: staff
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PersonCard(
                          fullName: s.fullName,
                          position: s.position,
                          photoUrl: s.photoUrl,
                          phone: s.phone,
                          biography: s.biography,
                          onCallTap: s.phone != null
                              ? () => launchUrl(Uri.parse('tel:${s.phone}'))
                              : null,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
