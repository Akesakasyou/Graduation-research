import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class MyRankingPage extends StatefulWidget {
  const MyRankingPage({super.key});

  @override
  State<MyRankingPage> createState() => _MyRankingPageState();
}

class _MyRankingPageState extends State<MyRankingPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String? selectedGenre;
  String? selectedSeason;
  final TextEditingController yearController = TextEditingController();

  final genres = ['バトル', '恋愛', '日常', 'ファンタジー', 'SF', 'ホラー'];

  final seasons = {
    'spring': '春',
    'summer': '夏',
    'autumn': '秋',
    'winter': '冬',
  };

  // =============================
  // マイランキング取得（フィルター対応）
  // =============================
  Future<List<Map<String, dynamic>>> loadMyRanking() async {
    final myVotesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('myVotes')
        .get();

    List<Map<String, dynamic>> result = [];

    for (var vote in myVotesSnap.docs) {
      final animeId = vote.id;
      final score = vote['score'];

      final animeDoc = await FirebaseFirestore.instance
          .collection('animes')
          .doc(animeId)
          .get();

      if (!animeDoc.exists) continue;

      final anime = animeDoc.data()!;

      // 🔹 フィルター判定
      if (selectedGenre != null && anime['genre'] != selectedGenre) continue;

      if (yearController.text.isNotEmpty) {
        final year = int.tryParse(yearController.text);
        if (year != null && anime['year'] != year) continue;
      }

      if (selectedSeason != null && anime['season'] != selectedSeason) continue;

      result.add({
        'animeId': animeId,
        'title': anime['title'],
        'imageUrl': anime['imageUrl'] ?? '',
        'score': score,
      });
    }

    // 🔹 点数順（高い順）
    result.sort((a, b) => b['score'].compareTo(a['score']));
    return result;
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('マイランキング')),
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
                  onChanged: (v) => setState(() => selectedGenre = v),
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
                  onChanged: (v) => setState(() => selectedSeason = v),
                ),

                // 今期ボタン（UX向上）
                TextButton(
                  onPressed: () {
                    setState(() {
                      final now = DateTime.now();
                      yearController.text = now.year.toString();

                      final m = now.month;
                      if (m <= 3)
                        selectedSeason = 'winter';
                      else if (m <= 6)
                        selectedSeason = 'spring';
                      else if (m <= 9)
                        selectedSeason = 'summer';
                      else
                        selectedSeason = 'autumn';
                    });
                  },
                  child: const Text('今期'),
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

          // 🔹 フィルター状態表示（総合ランキングと同UX）
          if (selectedGenre != null ||
              selectedSeason != null ||
              yearController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '絞り込み：'
                '${selectedGenre ?? ''} '
                '${yearController.text.isNotEmpty ? "${yearController.text}年" : ''} '
                '${selectedSeason != null ? seasons[selectedSeason] : ''}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

          const Divider(),

          // =============================
          // ランキング表示
          // =============================
          Expanded(
            child: FutureBuilder(
              future: loadMyRanking(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snapshot.data as List<Map<String, dynamic>>;

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'この条件で評価した作品はありません',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
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
                            Text('あなたの評価：${item['score']} 点'),
                            buildStarRating(item['score'].toDouble()),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AnimeDetailPage(animeId: item['animeId']),
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
