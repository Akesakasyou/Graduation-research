import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotePage extends StatelessWidget {
  const VotePage({super.key});

  // ✅ ダイアログを表示
  void showReviewDialog(BuildContext context, String animeId, String title) {
    double score = 50;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("「$title」の評価"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("スコア（0〜100点）"),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Slider(
                        value: score,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: score.toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            score = value;
                          });
                        },
                      ),
                      Text(
                        "${score.toInt()} 点",
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  );
                },
              ),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "感想を書いてください",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser!.uid;

                await FirebaseFirestore.instance
                    .collection('reviews')
                    .doc(animeId)
                    .collection('users')
                    .doc(uid)
                    .set({
                  'score': score.toInt(),
                  'comment': commentController.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("評価を保存しました！")),
                );
              },
              child: const Text("送信"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("アニメ評価ページ")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final anime = docs[index];
              final animeId = anime.id;
              final title = anime['title'];

              return Card(
                child: ListTile(
                  title: Text(title),
                  trailing: ElevatedButton(
                    child: const Text("評価する"),
                    onPressed: () {
                      showReviewDialog(context, animeId, title);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
