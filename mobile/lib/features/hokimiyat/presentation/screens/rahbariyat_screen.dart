import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/widgets/person_card.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/hokimiyat/data/repositories/hokimiyat_repository.dart';

class RahbariyatScreen extends ConsumerWidget {
  final String title;
  final String category;
  const RahbariyatScreen({super.key, required this.title, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(rahbariyatByCategoryProvider(category));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: kColorCream,
      body: listAsync.when(
        loading: () => const LoadingCardList(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (list) {
          if (list.isEmpty) return const EmptyView(message: "Ma'lumot topilmadi");
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = list[index];
              return PersonCard(
                fullName: item.fullName,
                position: item.position,
                photoUrl: item.photoUrl,
                phone: item.phone,
                biography: item.biography,
                receptionDays: item.receptionDays,
                onCallTap: item.phone != null
                    ? () => launchUrl(Uri.parse('tel:${item.phone}'))
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
