import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/features/tashkilotlar/data/repositories/places_repository.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeByIdProvider(placeId));
    final locale = ref.watch(localeProvider);
    final lang = localeKey(locale);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: kColorCream,
      body: placeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kColorPrimary)),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (place) {
          if (place == null) {
            return ErrorView(message: l10n.empty);
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: place.imageUrls.isNotEmpty ? 260 : 0,
                pinned: true,
                leading: const BackButton(),
                flexibleSpace: place.imageUrls.isNotEmpty
                    ? FlexibleSpaceBar(
                        background: PageView.builder(
                          itemCount: place.imageUrls.length,
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: place.imageUrls[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.localizedName(lang),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: kColorInk)),
                      if (place.localizedDirector(lang) != null) ...[
                        const SizedBox(height: 4),
                        Text('${l10n.directorLabel}: ${place.localizedDirector(lang)}',
                            style: const TextStyle(fontSize: 14, color: kColorTextMuted)),
                      ],
                      const SizedBox(height: 16),
                      // Rating
                      if (place.rating > 0)
                        Row(children: [
                          const Icon(Icons.star, color: kColorGold, size: 16),
                          const SizedBox(width: 4),
                          Text('${place.rating.toStringAsFixed(1)} (${place.commentCount} ${l10n.reviews})',
                              style: const TextStyle(fontSize: 13, color: kColorTextMuted)),
                        ]),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(children: [
                        if (place.phone != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => launchUrl(Uri.parse('tel:${place.phone}')),
                              icon: const Icon(Icons.phone, size: 16),
                              label: Text(l10n.call),
                            ),
                          ),
                        if (place.phone != null && place.locationLat != null)
                          const SizedBox(width: 10),
                        if (place.locationLat != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => launchUrl(Uri.parse(
                                  'https://maps.google.com/maps?q=${place.locationLat},${place.locationLng}')),
                              icon: const Icon(Icons.map_outlined, size: 16),
                              label: Text(l10n.directions),
                            ),
                          ),
                      ]),
                      if (place.localizedDescription(lang) != null && place.localizedDescription(lang)!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(l10n.descriptionLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
                        const SizedBox(height: 8),
                        Text(place.localizedDescription(lang)!,
                            style: const TextStyle(fontSize: 14, color: kColorTextMuted, height: 1.6)),
                      ],
                      if (place.locationLat != null && place.locationLng != null) ...[
                        const SizedBox(height: 20),
                        Text(l10n.locationLabel,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 180,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(place.locationLat!, place.locationLng!),
                                initialZoom: 15,
                              ),
                              children: [
                                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                                MarkerLayer(markers: [
                                  Marker(
                                    point: LatLng(place.locationLat!, place.locationLng!),
                                    child: const Icon(Icons.location_pin, color: kColorPrimary, size: 36),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
