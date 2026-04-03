import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/tashkilotlar/data/repositories/places_repository.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(
      FutureProvider.family((ref, String id) =>
          ref.read(placesRepositoryProvider).getById(id))(placeId),
    );

    return Scaffold(
      backgroundColor: kColorCream,
      body: placeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kColorPrimary)),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (place) {
          if (place == null) {
            return const ErrorView(message: "Ma'lumot topilmadi");
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
                      Text(place.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: kColorInk)),
                      if (place.director != null) ...[
                        const SizedBox(height: 4),
                        Text('Rahbar: ${place.director}',
                            style: const TextStyle(fontSize: 14, color: kColorTextMuted)),
                      ],
                      const SizedBox(height: 16),
                      // Rating
                      if (place.rating > 0)
                        Row(children: [
                          const Icon(Icons.star, color: kColorGold, size: 16),
                          const SizedBox(width: 4),
                          Text('${place.rating.toStringAsFixed(1)} (${place.commentCount} izoh)',
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
                              label: const Text("Qo'ng'iroq"),
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
                              label: const Text("Yo'nalish"),
                            ),
                          ),
                      ]),
                      if (place.description != null && place.description!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text('Tavsif', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
                        const SizedBox(height: 8),
                        Text(place.description!,
                            style: const TextStyle(fontSize: 14, color: kColorTextMuted, height: 1.6)),
                      ],
                      if (place.locationLat != null && place.locationLng != null) ...[
                        const SizedBox(height: 20),
                        const Text('Joylashuv',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
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
