import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';
import 'package:smart_turakurgan/features/hokimiyat/data/repositories/hokimiyat_repository.dart';

const int _kPageSize = 20;

class YerMaydonlariScreen extends ConsumerStatefulWidget {
  const YerMaydonlariScreen({super.key});

  @override
  ConsumerState<YerMaydonlariScreen> createState() => _YerMaydonlariScreenState();
}

class _YerMaydonlariScreenState extends ConsumerState<YerMaydonlariScreen> {
  final ScrollController _sc = ScrollController();
  final List<YerMaydonModel> _items = [];
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
    final items = await repo.getYerMaydonlari(limit: _kPageSize, offset: _offset);
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
        appBar: AppBar(title: Text(l10n.yerMaydon)),
        backgroundColor: kColorCream,
        body: const LoadingCardList(),
      );
    }

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.yerMaydon)),
        backgroundColor: kColorCream,
        body: EmptyView(message: l10n.landPlotsNotFound),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.yerMaydon)),
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
          final yer = _items[index];
          return Container(
            decoration: BoxDecoration(
              color: kColorWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(yer.localizedTitle(lang),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kColorInk)),
                    ),
                    _StatusBadge(status: yer.status, l10n: l10n),
                  ],
                ),
                if (yer.areaHectares != null) ...[
                  const SizedBox(height: 4),
                  Text('${yer.areaHectares} ${l10n.hectares}',
                      style: const TextStyle(fontSize: 13, color: kColorTextMuted)),
                ],
                if (yer.localizedDescription(lang) != null && yer.localizedDescription(lang)!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(yer.localizedDescription(lang)!,
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
                    label: Text(l10n.eAuction, style: const TextStyle(fontSize: 12)),
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
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;
  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => (l10n.statusActive, kColorSuccess),
      'sold' => (l10n.statusSold, kColorDanger),
      'pending' => (l10n.statusPending, kColorWarning),
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
