import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/models/place_model.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/features/tashkilotlar/data/repositories/places_repository.dart';

const _allCategories = [
  ('Hammasi', null),
  ('Maktablar', 'maktab'),
  ("MTM", 'maktabgacha'),
  ('Shifoxona', 'davlat_tibbiyot'),
  ('Klinika', 'xususiy_tibbiyot'),
  ('Restoran', 'ovqatlanish'),
  ("Mehmonxona", 'mexmonxona'),
  ("Attraksion", 'diqqat_joy'),
];

// Turakurgan district center
const _turakurganCenter = LatLng(41.0, 71.6);

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? _selectedCategory;
  PlaceModel? _selectedPlace;

  @override
  Widget build(BuildContext context) {
    final allPlacesAsync = ref.watch(
      FutureProvider.family<List<PlaceModel>, String?>((ref, cat) async {
        if (cat == null) {
          // Return all by fetching multiple categories
          final repo = ref.read(placesRepositoryProvider);
          final results = await Future.wait(_allCategories
              .skip(1)
              .map((c) => repo.getByCategory(c.$2!)));
          return results.expand((i) => i).toList();
        }
        return ref.read(placesRepositoryProvider).getByCategory(cat);
      })(_selectedCategory),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Map
          allPlacesAsync.when(
            loading: () => FlutterMap(
              options: MapOptions(initialCenter: _turakurganCenter, initialZoom: 12),
              children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png')],
            ),
            error: (_, __) => const Center(child: Text('Xarita yuklanmadi')),
            data: (places) => FlutterMap(
              options: MapOptions(
                initialCenter: _turakurganCenter,
                initialZoom: 12,
                onTap: (_, __) => setState(() => _selectedPlace = null),
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                MarkerLayer(
                  markers: places
                      .where((p) => p.locationLat != null && p.locationLng != null)
                      .map((p) => Marker(
                            point: LatLng(p.locationLat!, p.locationLng!),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPlace = p),
                              child: const Icon(Icons.location_pin, color: kColorPrimary, size: 32),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          // Category filter chips
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _allCategories.map((c) {
                  final selected = _selectedCategory == c.$2;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(c.$1),
                      selected: selected,
                      onSelected: (_) => setState(
                          () => _selectedCategory = selected ? null : c.$2),
                      backgroundColor: kColorWhite,
                      selectedColor: kColorPrimary,
                      checkmarkColor: kColorWhite,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selected ? kColorWhite : kColorInk,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Selected place mini-card
          if (_selectedPlace != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: _PlaceMiniCard(
                place: _selectedPlace!,
                onClose: () => setState(() => _selectedPlace = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceMiniCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onClose;

  const _PlaceMiniCard({required this.place, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kColorStone, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kColorInk.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
                const SizedBox(height: 2),
                Text(place.category,
                    style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
              ],
            ),
          ),
          if (place.phone != null)
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('tel:${place.phone}')),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kColorPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_outlined, color: kColorPrimary, size: 18),
              ),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: kColorTextMuted, size: 20),
          ),
        ],
      ),
    );
  }
}
