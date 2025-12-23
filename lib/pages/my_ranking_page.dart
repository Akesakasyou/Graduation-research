import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/AnimeDetailPage.dart';

// =============================
// 並び替えモード
// =============================
enum SortMode {
  score, // 点数順
  star, // ★順（表示基準）
}

// =============================
// ★表示ウィジェット
// =============================
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

// =============================
// マイランキングページ
// =============================
class MyRankingPage extends StatefulWidget {
  final String userId;
  const MyRankingPage({super.key, required this.userId});

  @override
  State<MyRankingPage> createState() => _MyRankingPageState();
}

class _MyRankingPageState extends State<MyRankingPage> {
  SortMode sortMode = SortMode.score;

  // =============================
  // Firestore からデータ取得
  // =============================
  Future<List<Map<String, dynamic>>> _loadUserRanking() async {
    final votesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('myVotes')
        .get();

    List<Map<String, dynamic>> result = [];

    for (var vote in votesSnap.docs) {
      final animeId = vote.id;
      final score = vote['score'] as int;

      final animeDoc = await FirebaseFirestore.instance
          .collection('animes')
          .doc(animeId)
          .get();

      if (!animeDoc.exists) continue;

      final anime = animeDoc.data()!;
      result.add({
        'animeId': animeId,
        'title': anime['title'] ?? 'タイトル不明',
        'imageUrl': anime['imageUrl'] ?? '',
        'score': score,
      });
    }

    // 🔽 並び替え（今はどちらも score 基準）
    result.sort((a, b) => b['score'].compareTo(a['score']));

    return result;
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("マイランキング"),
        actions: [
          PopupMenuButton<SortMode>(
            onSelected: (mode) {
              setState(() {
                sortMode = mode;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortMode.score,
                child: Text("点数順"),
              ),
              PopupMenuItem(
                value: SortMode.star,
                child: Text("★順"),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadUserRanking(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(child: Text("まだ投票がありません"));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final score = item['score'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: item['imageUrl'] != ""
                      ? Image.network(item['imageUrl'], width: 50)
                      : const Icon(Icons.image_not_supported),
                  title: Text("${index + 1}位：${item['title']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sortMode == SortMode.score) ...[
                        Text("スコア：$score 点"),
                        buildStarRating(score.toDouble()),
                      ] else ...[
                        buildStarRating(score.toDouble()),
                        Text("${(score / 20).toStringAsFixed(1)} ★"),
                      ],
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
    );
  }
}
