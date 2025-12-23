import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("管理者画面"),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddAnimeDialog(context);
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("作品がまだありません"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final anime = docs[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: anime['imageUrl'] != ""
                      ? Image.network(
                          anime['imageUrl'],
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                  title: Text(anime['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (anime['season'] != "") Text("放送期：${anime['season']}"),
                      if (anime['genre'] != "") Text("ジャンル：${anime['genre']}"),
                      if (anime['opTitle'] != "")
                        Text("OP：${anime['opTitle']}"),
                      if (anime['edTitle'] != "")
                        Text("ED：${anime['edTitle']}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditAnimeDialog(context, anime);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('animes')
                              .doc(anime.id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("作品を削除しました")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =============================
  // 作品追加
  // =============================
  void _showAddAnimeDialog(BuildContext context) {
    final title = TextEditingController();
    final genre = TextEditingController();
    final season = TextEditingController();
    final imageUrl = TextEditingController();
    final synopsis = TextEditingController();
    final opTitle = TextEditingController();
    final opArtist = TextEditingController();
    final edTitle = TextEditingController();
    final edArtist = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("作品追加"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _field(title, "タイトル"),
                _field(season, "放送期（例：2024春）"),
                _field(genre, "ジャンル"),
                _field(imageUrl, "画像URL"),
                _field(synopsis, "あらすじ", lines: 4),
                const Divider(),
                _field(opTitle, "OP曲名"),
                _field(opArtist, "OPアーティスト"),
                _field(edTitle, "ED曲名"),
                _field(edArtist, "EDアーティスト"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("追加"),
              onPressed: () async {
                if (title.text.trim().isEmpty) return;

                await FirebaseFirestore.instance.collection('animes').add({
                  'title': title.text.trim(),
                  'season': season.text.trim(),
                  'genre': genre.text.trim(),
                  'imageUrl': imageUrl.text.trim(),
                  'synopsis': synopsis.text.trim(),
                  'opTitle': opTitle.text.trim(),
                  'opArtist': opArtist.text.trim(),
                  'edTitle': edTitle.text.trim(),
                  'edArtist': edArtist.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // =============================
  // 編集
  // =============================
  void _showEditAnimeDialog(BuildContext context, QueryDocumentSnapshot anime) {
    final title = TextEditingController(text: anime['title']);
    final season = TextEditingController(text: anime['season']);
    final genre = TextEditingController(text: anime['genre']);
    final imageUrl = TextEditingController(text: anime['imageUrl']);
    final synopsis = TextEditingController(text: anime['synopsis']);
    final opTitle = TextEditingController(text: anime['opTitle']);
    final opArtist = TextEditingController(text: anime['opArtist']);
    final edTitle = TextEditingController(text: anime['edTitle']);
    final edArtist = TextEditingController(text: anime['edArtist']);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("作品編集"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _field(title, "タイトル"),
                _field(season, "放送期"),
                _field(genre, "ジャンル"),
                _field(imageUrl, "画像URL"),
                _field(synopsis, "あらすじ", lines: 4),
                const Divider(),
                _field(opTitle, "OP曲名"),
                _field(opArtist, "OPアーティスト"),
                _field(edTitle, "ED曲名"),
                _field(edArtist, "EDアーティスト"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("保存"),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('animes')
                    .doc(anime.id)
                    .update({
                  'title': title.text.trim(),
                  'season': season.text.trim(),
                  'genre': genre.text.trim(),
                  'imageUrl': imageUrl.text.trim(),
                  'synopsis': synopsis.text.trim(),
                  'opTitle': opTitle.text.trim(),
                  'opArtist': opArtist.text.trim(),
                  'edTitle': edTitle.text.trim(),
                  'edArtist': edArtist.text.trim(),
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _field(TextEditingController c, String label, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
