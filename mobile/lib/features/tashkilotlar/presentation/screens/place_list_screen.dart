import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/widgets/place_card.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/features/tashkilotlar/data/repositories/places_repository.dart';
import 'package:smart_turakurgan/shared/models/place_model.dart';
import 'place_detail_screen.dart';

const int _kPageSize = 20;

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
      return _CategoryList(title: title, category: categories.first);
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
          children: categories.map((cat) => _CategoryList(title: title, category: cat)).toList(),
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerStatefulWidget {
  final String title;
  final String category;
  const _CategoryList({required this.title, required this.category});

  @override
  ConsumerState<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<_CategoryList> {
  final ScrollController _sc = ScrollController();
  final List<PlaceModel> _items = [];
  int _offset = 0;
  bool _hasMore = true;
  bool _loading = false;
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _sc.addListener(() {
      if (_sc.position.pixels >= _sc.position.maxScrollExtent - 150 &&
          !_loading && _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    setState(() => _loading = true);
    final repo = ref.read(placesRepositoryProvider);
    final items = await repo.getByCategory(widget.category, limit: _kPageSize, offset: _offset);
    setState(() {
      _items.addAll(items);
      _offset += items.length;
      _hasMore = items.length == _kPageSize;
      _loading = false;
      _initialLoad = false;
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = localeKey(ref.watch(localeProvider));
    final l10n = AppLocalizations.of(context);

    if (_initialLoad) return const LoadingCardList();

    if (_items.isEmpty) return EmptyView(message: l10n.empty);

    return ListView.separated(
      controller: _sc,
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: kColorPrimary, strokeWidth: 2)),
          );
        }
        final place = _items[index];
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
  }
}
