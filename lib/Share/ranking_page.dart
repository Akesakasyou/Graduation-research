import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'animedetailpage.dart'; // AnimeDetailPage.dart を import

// スター評価を 0〜5 に変換して表示
Widget buildstar_rating(double score) {
  double star = (score / 100) * 5;

  return Row(
    children: List.generate(5, (index) {
      if (star >= index + 1) {
        return const Icon(Icons.star, color: Colors.amber);
      } else if (star > index) {
        return const Icon(Icons.star_half, color: Colors.amber);
      } else {
        return const Icon(Icons.star_border, color: Colors.amber);
      }
    }),
  );
}

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  // Firestore からランキングをロード
  Future<List<Map<String, dynamic>>> _loadRanking() async {
    final animeSnap =
        await FirebaseFirestore.instance.collection('animes').get();

    List<Future<Map<String, dynamic>?>> futures = [];

    for (var anime in animeSnap.docs) {
      futures.add(_loadAnimeRanking(anime));
    }

    final results = await Future.wait(futures);

    // null を除外して平均スコア順にソート
    return results.whereType<Map<String, dynamic>>().toList()
      ..sort((a, b) => b["average"].compareTo(a["average"]));
  }

  // 個別アニメの平均スコアを計算
  Future<Map<String, dynamic>?> _loadAnimeRanking(
      QueryDocumentSnapshot anime) async {
    final animeId = anime.id;
    final title = anime['title'];
    final imageUrl = anime['imageUrl'] ?? "";

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
      "animeId": animeId,
      "title": title,
      "imageUrl": imageUrl,
      "average": average,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("総合ランキング")),
      body: FutureBuilder(
        future: _loadRanking(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data as List<Map<String, dynamic>>;
          if (list.isEmpty) {
            return const Center(child: Text("まだ投票がありません"));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: item["imageUrl"] != ""
                      ? Image.network(item["imageUrl"], width: 60)
                      : const Icon(Icons.image_not_supported, size: 40),
                  title: Text("${index + 1}位：${item["title"]}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "平均スコア：${item["average"].toStringAsFixed(1)} 点",
                      ),
                      buildstar_rating(item["average"]),
                    ],
                  ),
                  onTap: () {
                    // 修正: AnimeDetailPage に渡すのは animeId のみ
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimeDetailPage(
                          animeId: item["animeId"],
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
    );
  }
}
