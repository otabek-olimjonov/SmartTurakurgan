import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_turakurgan/shared/widgets/person_card.dart';
import 'package:smart_turakurgan/shared/widgets/loading_widgets.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/core/locale/locale_provider.dart';
import 'package:smart_turakurgan/features/hokimiyat/data/repositories/hokimiyat_repository.dart';
import 'package:smart_turakurgan/shared/models/rahbariyat_model.dart';

const int _kPageSize = 20;

class RahbariyatScreen extends ConsumerStatefulWidget {
  final String title;
  final String category;
  const RahbariyatScreen({super.key, required this.title, required this.category});

  @override
  ConsumerState<RahbariyatScreen> createState() => _RahbariyatScreenState();
}

class _RahbariyatScreenState extends ConsumerState<RahbariyatScreen> {
  final ScrollController _sc = ScrollController();
  final List<RahbariyatModel> _items = [];
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

    if (_initialLoad) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        backgroundColor: kColorCream,
        body: const LoadingCardList(),
      );
    }

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        backgroundColor: kColorCream,
        body: const EmptyView(message: "Ma'lumot topilmadi"),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
          final item = _items[index];
          return PersonCard(
            fullName: item.localizedName(lang),
            position: item.localizedPosition(lang),
            photoUrl: item.photoUrl,
            phone: item.phone,
            biography: item.localizedBiography(lang),
            receptionDays: item.receptionDays,
            onCallTap: item.phone != null
                ? () => launchUrl(Uri.parse('tel:${item.phone}'))
                : null,
          );
        },
      ),
    );
  }
}
