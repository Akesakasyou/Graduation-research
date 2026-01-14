import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotePage extends StatefulWidget {
  final String animeId;

  const VotePage({
    super.key,
    required this.animeId,
  });

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final _commentController = TextEditingController();

  int _score = 80;
  bool _includeGlobal = true;
  bool _loading = true;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // =============================
  // 既存レビュー読み込み（再評価対応）
  // =============================
  Future<void> _loadMyReview() async {
    final doc = await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.animeId)
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _score = data['score'] ?? 80;
      _commentController.text = data['comment'] ?? '';
      _includeGlobal = data['includeGlobal'] ?? true;
    }

    setState(() => _loading = false);
  }

  // =============================
  // 平均点再計算
  // =============================
  Future<void> _updateAverageScore() async {
    final snap = await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.animeId)
        .collection('users')
        .where('includeGlobal', isEqualTo: true)
        .get();

    double avg = 0;

    if (snap.docs.isNotEmpty) {
      final scores = snap.docs.map((d) => d['score'] as int).toList();
      avg = scores.reduce((a, b) => a + b) / scores.length;
    }

    await FirebaseFirestore.instance
        .collection('animes')
        .doc(widget.animeId)
        .update({
      'averageScore': avg,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =============================
  // 保存
  // =============================
  Future<void> _saveReview() async {
    final reviewRef = FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.animeId)
        .collection('users')
        .doc(uid);

    await reviewRef.set({
      'score': _score,
      'comment': _commentController.text,
      'includeGlobal': _includeGlobal,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _updateAverageScore();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _loadMyReview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('評価する')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // スコア
                  Text(
                    'スコア：$_score 点',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _score.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: _score.toString(),
                    onChanged: (v) => setState(() => _score = v.round()),
                  ),

                  const SizedBox(height: 16),

                  // 感想
                  const Text(
                    '感想',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '感想を書いてください',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 全体ランキングに含める
                  SwitchListTile(
                    title: const Text('全体ランキングに含める'),
                    value: _includeGlobal,
                    onChanged: (v) => setState(() => _includeGlobal = v),
                  ),

                  const Spacer(),

                  // 保存
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('保存する'),
                      onPressed: _saveReview,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
