import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/widgets/person_card.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/features/hokimiyat/data/repositories/hokimiyat_repository.dart';

const int _kPageSize = 20;

class MahallalarScreen extends ConsumerStatefulWidget {
  const MahallalarScreen({super.key});

  @override
  ConsumerState<MahallalarScreen> createState() => _MahallalarScreenState();
}

class _MahallalarScreenState extends ConsumerState<MahallalarScreen> {
  final ScrollController _sc = ScrollController();
  final List<MahallalarModel> _items = [];
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
    final repo = ref.read(hokimiyatRepositoryProvider);
    final items = await repo.getMahallalar(limit: _kPageSize, offset: _offset);
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

    if (_initialLoad) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.mahallalar)),
        backgroundColor: kColorCream,
        body: const LoadingCardList(),
      );
    }

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.mahallalar)),
        backgroundColor: kColorCream,
        body: EmptyView(message: l10n.neighborhoodsNotFound),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mahallalar)),
      backgroundColor: kColorCream,
      body: ListView.separated(
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
          final m = _items[index];
          return Container(
            decoration: BoxDecoration(
              color: kColorWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_outlined, color: Color(0xFFFF6B6B), size: 20),
              ),
              title: Text(m.localizedName(lang),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: m.localizedDescription(lang) != null
                  ? Text(m.localizedDescription(lang)!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: kColorTextMuted))
                  : null,
              trailing: const Icon(Icons.chevron_right, color: kColorTextMuted, size: 20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => _MahallalarDetailScreen(mahalla: m, lang: lang, l10n: l10n)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MahallalarDetailScreen extends ConsumerWidget {
  final MahallalarModel mahalla;
  final String lang;
  final AppLocalizations l10n;
  const _MahallalarDetailScreen({required this.mahalla, required this.lang, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(
      FutureProvider.family((ref, String id) =>
          ref.read(hokimiyatRepositoryProvider).getMahallaxodimlari(id))(mahalla.id),
    );
    return Scaffold(
      appBar: AppBar(title: Text(mahalla.localizedName(lang))),
      backgroundColor: kColorCream,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (mahalla.localizedDescription(lang) != null) ...[
            Text(mahalla.localizedDescription(lang)!,
                style: const TextStyle(fontSize: 14, color: kColorTextMuted, height: 1.5)),
            const SizedBox(height: 16),
          ],
          Text(l10n.workers,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: kColorInk)),
          const SizedBox(height: 10),
          staffAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: kColorPrimary)),
            error: (e, _) => ErrorView(message: e.toString()),
            data: (staff) => Column(
              children: staff
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PersonCard(
                          fullName: s.localizedName(lang),
                          position: s.localizedPosition(lang),
                          photoUrl: s.photoUrl,
                          phone: s.phone,
                          biography: s.localizedBiography(lang),
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
