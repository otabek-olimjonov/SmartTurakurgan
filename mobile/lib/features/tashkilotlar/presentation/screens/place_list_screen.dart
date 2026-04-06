import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/widgets/place_card.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/features/tashkilotlar/data/repositories/places_repository.dart';
import 'place_detail_screen.dart';

class PlaceListScreen extends ConsumerWidget {
  final String title;
  final List<String> categories;

  const PlaceListScreen({
    super.key,
    required this.title,
    required this.categories,
  });

  static String tabLabelForCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'diqqat_joy': return l10n.tabAttractions;
      case 'ovqatlanish': return l10n.tabRestaurants;
      case 'mexmonxona': return l10n.tabHotels;
      case 'oquv_markaz': return l10n.tabLearningCenters;
      case 'maktabgacha': return l10n.tabPreschools;
      case 'maktab': return l10n.tabSchools;
      case 'texnikum': return l10n.tabColleges;
      case 'oliy_talim': return l10n.tabUniversities;
      case 'davlat_tibbiyot': return l10n.tabStateHospitals;
      case 'xususiy_tibbiyot': return l10n.tabPrivateClinics;
      case 'davlat_tashkilot': return l10n.tabStateOrgs;
      case 'xususiy_korxona': return l10n.tabPrivateEnterprises;
      default: return category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
            tabs: categories
                .map((cat) => Tab(text: tabLabelForCategory(cat, l10n)))
                .toList(),
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
    final locale = ref.watch(localeProvider);
    final lang = localeKey(locale);
    final l10n = AppLocalizations.of(context);
    return placesAsync.when(
      loading: () => const LoadingCardList(),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (places) {
        if (places.isEmpty) return EmptyView(message: l10n.empty);
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: places.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final place = places[index];
            return PlaceCard(
              name: place.localizedName(lang),
              imageUrl: place.imageUrls.isNotEmpty ? place.imageUrls.first : null,
              phone: place.phone,
              description: place.localizedDescription(lang),
              rating: place.rating,
              callLabel: l10n.call,
              mapLabel: l10n.mapLabel,
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
