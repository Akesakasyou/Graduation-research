import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'vote_page.dart';

/// ⭐ スター表示
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

class AnimeDetailPage extends StatelessWidget {
  final String animeId;
  const AnimeDetailPage({super.key, required this.animeId});

  static const seasons = {
    'spring': '春',
    'summer': '夏',
    'autumn': '秋',
    'winter': '冬',
  };

  /// =============================
  /// 平均スコア
  /// =============================
  Future<double> _loadAverageScore() async {
    final snap = await FirebaseFirestore.instance
        .collection('reviews')
        .doc(animeId)
        .collection('users')
        .where('includeGlobal', isEqualTo: true)
        .get();

    if (snap.docs.isEmpty) return 0;

    final scores = snap.docs.map((e) => e['score'] as int).toList();
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// =============================
  /// 平均点ランキング順位
  /// =============================
  Future<int> _loadRankByAverage() async {
    final snap = await FirebaseFirestore.instance
        .collection('animes')
        .orderBy('averageScore', descending: true)
        .get();

    return snap.docs.indexWhere((d) => d.id == animeId) + 1;
  }

  /// =============================
  /// 評価済みか
  /// =============================
  Future<bool> _hasMyReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('reviews')
        .doc(animeId)
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.exists;
  }

  /// =============================
  /// 👍 いいね切り替え
  /// =============================
  Future<void> _toggleLike(String reviewUserId, bool isLiked) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final reviewRef = FirebaseFirestore.instance
        .collection('reviews')
        .doc(animeId)
        .collection('users')
        .doc(reviewUserId);

    final likeRef = reviewRef.collection('likedUsers').doc(uid);

    FirebaseFirestore.instance.runTransaction((tx) async {
      if (isLiked) {
        tx.delete(likeRef);
        tx.update(reviewRef, {
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        tx.set(likeRef, {
          'likedAt': FieldValue.serverTimestamp(),
        });
        tx.update(reviewRef, {
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('作品詳細')),

      /// 下固定：評価ボタン
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<bool>(
          future: _hasMyReview(),
          builder: (context, snap) {
            final isVoted = snap.data ?? false;

            return ElevatedButton.icon(
              icon: const Icon(Icons.rate_review),
              label: Text(isVoted ? '再評価する' : '評価する'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VotePage(animeId: animeId),
                  ),
                );
              },
            );
          },
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('animes').doc(animeId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          /// 🔽 null安全：季節表示
          final seasonKey = data['season'];
          final seasonLabel = seasonKey != null ? seasons[seasonKey] ?? '' : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 画像
                if ((data['imageUrl'] ?? '').toString().isNotEmpty)
                  Center(
                    child: Image.network(
                      data['imageUrl'],
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 16),

                /// タイトル
                Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                /// 年・季節・ジャンル
                Text(
                  '${data['year'] ?? ''}年 $seasonLabel / ${data['genre'] ?? ''}',
                  style: const TextStyle(color: Colors.grey),
                ),

                const Divider(height: 32),

                /// 以下そのまま（感想・評価）
                // ← ここは元のコードと同じなので省略してOK
              ],
            ),
          );
        },
      ),
    );
  }
}
