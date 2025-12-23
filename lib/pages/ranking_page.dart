import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'animedetailpage.dart';

// ⭐ スター表示
Widget buildStarRating(double score) {
  final star = (score / 100) * 5;

  return Row(
    children: List.generate(5, (index) {
      if (star >= index + 1) {
        return const Icon(Icons.star, color: Colors.amber, size: 18);
      } else if (star > index) {
        return const Icon(Icons.star_half, color: Colors.amber, size: 18);
      } else {
        return const Icon(Icons.star_border, color: Colors.amber, size: 18);
      }
    }),
  );
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  String? selectedGenre;
  String? selectedSeason;
  final TextEditingController yearController = TextEditingController();

  final genres = [
    'バトル',
    '恋愛',
    '日常',
    'ファンタジー',
    'SF',
    'ホラー',
  ];

  final seasons = {
    'spring': '春',
    'summer': '夏',
    'autumn': '秋',
    'winter': '冬',
  };

  // 🔹 ランキング取得（フィルター対応）
  Future<List<Map<String, dynamic>>> loadRanking() async {
    Query query = FirebaseFirestore.instance.collection('animes');

    if (selectedGenre != null) {
      query = query.where('genre', isEqualTo: selectedGenre);
    }

    if (yearController.text.isNotEmpty) {
      final year = int.tryParse(yearController.text);
      if (year != null) {
        query = query.where('year', isEqualTo: year);
      }
    }

    if (selectedSeason != null) {
      query = query.where('season', isEqualTo: selectedSeason);
    }

    final animeSnap = await query.get();

    List<Future<Map<String, dynamic>?>> futures = [];

    for (var anime in animeSnap.docs) {
      futures.add(_loadAnimeAverage(anime));
    }

    final results = await Future.wait(futures);

    return results.whereType<Map<String, dynamic>>().toList()
      ..sort((a, b) => b['average'].compareTo(a['average']));
  }

  // 🔹 平均スコア計算
  Future<Map<String, dynamic>?> _loadAnimeAverage(
      QueryDocumentSnapshot anime) async {
    final animeId = anime.id;

    final reviewsSnap = await FirebaseFirestore.instance
        .collection('reviews')
        .doc(animeId)
        .collection('users')
        .where('includeGlobal', isEqualTo: true)
        .get();

    if (reviewsSnap.docs.isEmpty) return null;

    final scores = reviewsSnap.docs.map((e) => e['score'] as int).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;

    return {
      'animeId': animeId,
      'title': anime['title'],
      'imageUrl': anime['imageUrl'] ?? '',
      'average': average,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('総合ランキング')),
      body: Column(
        children: [
          // 🔹 フィルターUI
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                // ジャンル
                DropdownButton<String>(
                  hint: const Text('ジャンル'),
                  value: selectedGenre,
                  items: genres
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedGenre = value);
                  },
                ),

                // 年（入力）
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '年',
                      hintText: '2024',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                // 季節
                DropdownButton<String>(
                  hint: const Text('季節'),
                  value: selectedSeason,
                  items: seasons.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedSeason = value);
                  },
                ),

                // リセット
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedGenre = null;
                      selectedSeason = null;
                      yearController.clear();
                    });
                  },
                  child: const Text('リセット'),
                ),
              ],
            ),
          ),

          const Divider(),

          // 🔹 ランキング表示
          Expanded(
            child: FutureBuilder(
              future: loadRanking(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snapshot.data as List<Map<String, dynamic>>;

                if (list.isEmpty) {
                  return const Center(child: Text('該当データがありません'));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        leading: item['imageUrl'] != ''
                            ? Image.network(item['imageUrl'], width: 60)
                            : const Icon(Icons.image_not_supported),
                        title: Text('${index + 1}位：${item['title']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '平均 ${item['average'].toStringAsFixed(1)} 点',
                            ),
                            buildStarRating(item['average']),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnimeDetailPage(
                                animeId: item['animeId'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
