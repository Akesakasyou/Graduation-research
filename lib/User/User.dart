import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'URanking.dart'; // AnimeDetailPage

class AnimeListPage extends StatelessWidget {
  const AnimeListPage({super.key});

  static const seasons = {
    'spring': '春',
    'summer': '夏',
    'autumn': '秋',
    'winter': '冬',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "アニメ一覧",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      // 🔽 Firestoreから作品一覧取得
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animes')
            // ⚠️ orderByしない（ぐるぐる防止）
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("作品がありません"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final seasonKey = data['season'];
              final seasonLabel =
                  seasonKey != null ? seasons[seasonKey] ?? '' : '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: (data['imageUrl'] ?? '').toString().isNotEmpty
                      ? Image.network(
                          data['imageUrl'],
                          width: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),

                  title: Text(data['title'] ?? ''),
                  subtitle: Text(
                    '${data['year'] ?? ''}年 $seasonLabel',
                  ),

                  // ✅ ここが重要：animeId を渡す
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => URankingPage(animeId: doc.id),
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
