import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class URankingPage extends StatelessWidget {
  final String animeId;

  const URankingPage({super.key, required this.animeId});

  static const seasons = {
    'spring': '春',
    'summer': '夏',
    'autumn': '秋',
    'winter': '冬',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("作品詳細"),
      ),

      // データ取得（FutureBuilder）で作品情報を取得
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            FirebaseFirestore.instance.collection('animes').doc(animeId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("作品データが見つかりません"));
          }

          final data = snapshot.data!.data()!;
          final seasonKey = data['season'];
          final seasonLabel = seasonKey != null ? seasons[seasonKey] ?? '' : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル
                Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '${data['year'] ?? ''}年 $seasonLabel / ${data['genre'] ?? ''}',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // 画像
                if ((data['imageUrl'] ?? '').toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      data['imageUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 25),

                // あらすじ
                const Text(
                  "あらすじ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  data['synopsis'] ?? 'あらすじがありません',
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 30),

                // 感想（レビュー）
                const Text(
                  "みんなの感想",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                _buildReviews(),
              ],
            ),
          );
        },
      ),
    );
  }

  // 感想一覧（StreamBuilder）
  Widget _buildReviews() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .doc(animeId)
          .collection('users')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(10),
            child: Text("まだ感想がありません"),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nickname'] ?? '匿名',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(data['comment'] ?? ''),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
