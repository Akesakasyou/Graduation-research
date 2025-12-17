import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AnimeDetailPage.dart'; // 動的詳細ページ

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

class MyRankingPage extends StatelessWidget {
  final String userId;

  const MyRankingPage({super.key, required this.userId});

  // Firestore からユーザー別のランキングをロード
  Future<List<Map<String, dynamic>>> _loadUserRanking() async {
    final reviewsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('myVotes')
        .get();

    List<Map<String, dynamic>> result = [];

    for (var review in reviewsSnap.docs) {
      final animeId = review.id;
      final score = review['score'] as int;

      final animeDoc = await FirebaseFirestore.instance
          .collection('animes')
          .doc(animeId)
          .get();

      if (!animeDoc.exists) continue;

      final animeData = animeDoc.data()!;
      result.add({
        "animeId": animeId,
        "title": animeData['title'] ?? 'タイトル不明',
        "imageUrl": animeData['imageUrl'] ?? "",
        "score": score,
      });
    }

    // スコア順にソート
    result.sort((a, b) => b['score'].compareTo(a['score']));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("マイランキング")),
      body: FutureBuilder(
        future: _loadUserRanking(),
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
                      Text("スコア：${item["score"]}点"),
                      buildstar_rating(item["score"].toDouble()),
                    ],
                  ),
                  onTap: () {
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
