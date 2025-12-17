import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 0〜100点の score を ★0〜5 に変換して表示
Widget buildstar_rating(double score) {
  // 100点 → 5.0, 80点 → 4.0, 50点 → 2.5
  double starValue = (score / 20).clamp(0, 5);

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (index) {
      double diff = starValue - index;

      IconData icon;
      if (diff >= 1) {
        icon = Icons.star;
      } else if (diff >= 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }

      return Icon(icon, color: Colors.amber, size: 22);
    }),
  );
}

class AnimeDetailPage extends StatelessWidget {
  final String animeId;

  const AnimeDetailPage({
    super.key,
    required this.animeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アニメ詳細')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animes')
            .doc(animeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Image.network(data['imageUrl']),
              Text(data['title']),
            ],
          );
        },
      ),
    );
  }
}
