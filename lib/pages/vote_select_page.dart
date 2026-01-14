import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vote_page.dart';

class VoteSelectPage extends StatelessWidget {
  const VoteSelectPage({super.key});

  /// season 表示用マップ
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
        title: const Text('投票する作品を選択'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animes')
            .orderBy('title')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                '作品が登録されていません',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final anime = docs[index].data() as Map<String, dynamic>;

              final title = anime['title'] ?? '';
              final year = anime['year'];
              final seasonKey = anime['season'];
              final seasonLabel =
                  seasonKey != null ? seasons[seasonKey] ?? '' : '';

              return ListTile(
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${year ?? ''}年 ${seasonLabel}',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VotePage(animeId: docs[index].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
