import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Top/other_user_ranking_detail.dart';

class OtherUsersMyRanking extends StatelessWidget {
  const OtherUsersMyRanking({super.key});

  Future<List<Map<String, dynamic>>> _getOtherUsersRanking() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> results = [];

    for (final userDoc in usersSnapshot.docs) {
      if (userDoc.id == currentUser?.uid) continue;

      final userName = userDoc.data()['name'] ?? '名無し';

      final rankingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDoc.id)
          .collection('Creatmypage')
          .get();

      for (final doc in rankingSnapshot.docs) {
        final data = doc.data();
        data['userId'] = userDoc.id;
        data['userName'] = userName; // ★追加
        results.add(data);
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "～ 他ユーザーのマイランキング ～",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _getOtherUsersRanking(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'エラー: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("表示するランキングがありません"));
              }

              final items = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildCard(context, items[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtherUserRankingDetailPage(
              userId: item['userId'],
            ),
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            item["images"] != null
                ? Image.network(
                    item["images"],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(child: Text("No Image")),
                  ),
            const SizedBox(height: 8),
            Text(
              item["title"] ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("作品数：${item["sakuhin"] ?? ""}"),
          ],
        ),
      ),
    );
  }
}
