import 'package:flutter/material.dart';
import 'package:smart_turakurgan/core/db/local_database.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';

class _SearchResult {
  final String id;
  final String name;
  final String category;
  final String type; // 'place' | 'rahbariyat' | 'mahalla' | 'news'
  const _SearchResult({required this.id, required this.name, required this.category, required this.type});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<_SearchResult> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final db = await LocalDatabase.instance;
    final like = '%$q%';

    final places = await db.query(
      'places',
      where: "(name LIKE ? OR description LIKE ? OR director LIKE ?) AND is_published = 1",
      whereArgs: [like, like, like],
      limit: 20,
    );

    final rahbariyat = await db.query(
      'rahbariyat',
      where: "(full_name LIKE ? OR position LIKE ?) AND is_published = 1",
      whereArgs: [like, like],
      limit: 10,
    );

    final mahallalar = await db.query(
      'mahallalar',
      where: "(name LIKE ? OR description LIKE ?) AND is_published = 1",
      whereArgs: [like, like],
      limit: 10,
    );

    final news = await db.query(
      'yangiliklar',
      where: "(title LIKE ? OR body LIKE ?) AND is_published = 1",
      whereArgs: [like, like],
      limit: 10,
    );

    final results = [
      ...places.map((r) => _SearchResult(
            id: r['id'] as String,
            name: r['name'] as String,
            category: _categoryLabel(r['category'] as String),
            type: 'place',
          )),
      ...rahbariyat.map((r) => _SearchResult(
            id: r['id'] as String,
            name: r['full_name'] as String,
            category: 'Hokimiyat xodimi',
            type: 'rahbariyat',
          )),
      ...mahallalar.map((r) => _SearchResult(
            id: r['id'] as String,
            name: r['name'] as String,
            category: 'Mahalla',
            type: 'mahalla',
          )),
      ...news.map((r) => _SearchResult(
            id: r['id'] as String,
            name: r['title'] as String,
            category: 'Yangilik',
            type: 'news',
          )),
    ];

    if (mounted) setState(() { _results = results; _loading = false; });
  }

  String _categoryLabel(String cat) {
    const labels = {
      'diqqat_joy': 'Diqqatga sazovor',
      'ovqatlanish': 'Restoran',
      'mexmonxona': 'Mehmonxona',
      'oquv_markaz': 'Oquv markazi',
      'maktabgacha': 'Maktabgacha ta\'lim',
      'maktab': 'Maktab',
      'texnikum': 'Texnikum',
      'oliy_talim': 'Oliy ta\'lim',
      'davlat_tibbiyot': 'Davlat tibbiyot',
      'xususiy_tibbiyot': 'Xususiy klinika',
      'davlat_tashkilot': 'Davlat tashkiloti',
      'xususiy_korxona': 'Xususiy korxona',
    };
    return labels[cat] ?? cat;
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'rahbariyat': return Icons.person_outline;
      case 'mahalla': return Icons.home_work_outlined;
      case 'news': return Icons.newspaper_outlined;
      default: return Icons.business_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'rahbariyat': return const Color(0xFFFF9500);
      case 'mahalla': return const Color(0xFFFF6B6B);
      case 'news': return kColorPrimary;
      default: return const Color(0xFF007AFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _search,
          decoration: const InputDecoration(
            hintText: 'Qidiring...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: kColorTextMuted),
          ),
          style: const TextStyle(fontSize: 16, color: kColorInk),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                _search('');
              },
            ),
        ],
      ),
      backgroundColor: kColorCream,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kColorPrimary))
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, size: 48, color: kColorStone),
                      const SizedBox(height: 12),
                      Text(
                        _ctrl.text.trim().isEmpty
                            ? 'Qidiruv so\'zini kiriting'
                            : 'Natija topilmadi',
                        style: const TextStyle(fontSize: 14, color: kColorTextMuted),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = _results[index];
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
                            color: _colorFor(r.type).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_iconFor(r.type), color: _colorFor(r.type), size: 20),
                        ),
                        title: Text(r.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kColorInk),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(r.category,
                            style: const TextStyle(fontSize: 12, color: kColorTextMuted)),
                        trailing: const Icon(Icons.chevron_right, color: kColorTextMuted, size: 18),
                        onTap: () => _navigate(context, r),
                      ),
                    );
                  },
                ),
    );
  }

  void _navigate(BuildContext context, _SearchResult r) {
    switch (r.type) {
      case 'news':
        Navigator.pop(context);
        Navigator.pushNamed(context, '/news');
      case 'rahbariyat':
        Navigator.pop(context);
        Navigator.pushNamed(context, '/hokimiyat');
      case 'mahalla':
        Navigator.pop(context);
        Navigator.pushNamed(context, '/hokimiyat');
      default:
        // Navigate to place detail — use pushNamed with place_id
        Navigator.pop(context);
    }
  }
}
