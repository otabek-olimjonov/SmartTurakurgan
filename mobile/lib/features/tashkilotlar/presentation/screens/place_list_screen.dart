import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/models/place_model.dart';
import 'package:smart_turakurgan/shared/widgets/place_card.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/tashkilotlar/data/repositories/places_repository.dart';
import 'place_detail_screen.dart';

class PlaceListScreen extends ConsumerWidget {
  final String title;
  final List<String> categories;
  final List<String>? tabLabels;

  const PlaceListScreen({
    super.key,
    required this.title,
    required this.categories,
    this.tabLabels,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.length == 1) {
      return _SingleTab(title: title, category: categories.first);
    }
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: TabBar(
            isScrollable: true,
            tabs: List.generate(
              categories.length,
              (i) => Tab(text: tabLabels?[i] ?? categories[i]),
            ),
          ),
        ),
        body: TabBarView(
          children: categories.map((cat) => _CategoryList(category: cat)).toList(),
        ),
      ),
    );
  }
}

class _SingleTab extends StatelessWidget {
  final String title;
  final String category;
  const _SingleTab({required this.title, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _CategoryList(category: category),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final String category;
  const _CategoryList({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesByCategoryProvider(category));
    return placesAsync.when(
      loading: () => const LoadingCardList(),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (places) {
        if (places.isEmpty) return const EmptyView(message: "Ma'lumot topilmadi");
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: places.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final place = places[index];
            return PlaceCard(
              name: place.name,
              imageUrl: place.imageUrls.isNotEmpty ? place.imageUrls.first : null,
              phone: place.phone,
              description: place.description,
              rating: place.rating,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id)),
              ),
              onCallTap: place.phone != null
                  ? () => launchUrl(Uri.parse('tel:${place.phone}'))
                  : null,
              onMapTap: (place.locationLat != null && place.locationLng != null)
                  ? () => launchUrl(Uri.parse(
                      'https://maps.google.com/maps?q=${place.locationLat},${place.locationLng}'))
                  : null,
            );
          },
        );
      },
    );
  }
}
