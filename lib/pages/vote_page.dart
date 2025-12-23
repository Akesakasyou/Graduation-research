import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  Set<String> votedAnimeIds = {};
  Map<String, Map<String, dynamic>> myVotes = {};

  @override
  void initState() {
    super.initState();
    _loadMyVotes();
  }

  /// =============================
  /// 自分の投票データを取得
  /// =============================
  Future<void> _loadMyVotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('myVotes')
        .get();

    setState(() {
      votedAnimeIds = snap.docs.map((d) => d.id).toSet();
      myVotes = {
        for (var d in snap.docs) d.id: d.data(),
      };
    });
  }

  /// =============================
  /// 評価 / 再評価ダイアログ
  /// =============================
  void showReviewDialog(
    BuildContext context,
    String animeId,
    String title, {
    Map<String, dynamic>? existingData,
  }) {
    double score = existingData?['score']?.toDouble() ?? 50;
    bool includeGlobal = existingData?['includeGlobal'] ?? true;
    final TextEditingController commentController =
        TextEditingController(text: existingData?['comment'] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("「$title」の評価"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("スコア（0〜100点）"),
                  Slider(
                    value: score,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: score.toInt().toString(),
                    onChanged: (value) {
                      setStateDialog(() {
                        score = value;
                      });
                    },
                  ),
                  Text("${score.toInt()} 点",
                      style: const TextStyle(fontSize: 18)),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: "感想を書いてください"),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text("総合ランキングに反映する"),
                    value: includeGlobal,
                    onChanged: (v) {
                      setStateDialog(() {
                        includeGlobal = v ?? true;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser!.uid;

                /// 総合ランキング用（上書き）
                await FirebaseFirestore.instance
                    .collection('reviews')
                    .doc(animeId)
                    .collection('users')
                    .doc(uid)
                    .set({
                  'score': score.toInt(),
                  'comment': commentController.text,
                  'includeGlobal': includeGlobal,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                /// マイランキング用（上書き）
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('myVotes')
                    .doc(animeId)
                    .set({
                  'animeTitle': title,
                  'score': score.toInt(),
                  'comment': commentController.text,
                  'includeGlobal': includeGlobal,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);

                setState(() {
                  votedAnimeIds.add(animeId);
                  myVotes[animeId] = {
                    'score': score.toInt(),
                    'comment': commentController.text,
                    'includeGlobal': includeGlobal,
                  };
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("評価を更新しました！")),
                );
              },
              child: const Text("保存"),
            ),
          ],
        );
      },
    );
  }

  /// =============================
  /// 画面
  /// =============================
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

              final isVoted = votedAnimeIds.contains(animeId);

              return Card(
                child: ListTile(
                  title: Text(title),
                  trailing: ElevatedButton(
                    onPressed: () {
                      showReviewDialog(
                        context,
                        animeId,
                        title,
                        existingData: myVotes[animeId],
                      );
                    },
                    child: Text(isVoted ? "再評価" : "評価する"),
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
