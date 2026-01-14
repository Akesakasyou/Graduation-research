import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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
        title: const Text('管理者画面'),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAnimeDialog(context),
        child: const Icon(Icons.add),
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
            return const Center(child: Text('作品がまだありません'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final anime = docs[index];
              final data = anime.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: (data['imageUrl'] ?? '').toString().isNotEmpty
                      ? Image.network(data['imageUrl'], width: 50)
                      : const Icon(Icons.image),
                  title: Text(data['title'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('年：${data['year'] ?? '-'}'),
                      Text('季節：${seasons[data['season']] ?? '-'}'),
                      if ((data['genre'] ?? '').toString().isNotEmpty)
                        Text('ジャンル：${data['genre']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditAnimeDialog(context, anime),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('animes')
                              .doc(anime.id)
                              .delete();
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
    final yearController = TextEditingController();
    final imageUrl = TextEditingController();
    final synopsis = TextEditingController();
    final opTitle = TextEditingController();
    final opArtist = TextEditingController();
    final edTitle = TextEditingController();
    final edArtist = TextEditingController();

    String? selectedSeason;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('作品追加'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _field(title, 'タイトル'),
                _field(yearController, '年（例：2024）', type: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: selectedSeason,
                  decoration: const InputDecoration(labelText: '季節'),
                  items: seasons.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => selectedSeason = v,
                ),
                _field(genre, 'ジャンル'),
                _field(imageUrl, '画像URL'),
                _field(synopsis, 'あらすじ', lines: 4),
                const Divider(),
                _field(opTitle, 'OP曲名'),
                _field(opArtist, 'OPアーティスト'),
                _field(edTitle, 'ED曲名'),
                _field(edArtist, 'EDアーティスト'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              child: const Text('追加'),
              onPressed: () async {
                final year = int.tryParse(yearController.text);
                if (title.text.trim().isEmpty ||
                    year == null ||
                    selectedSeason == null) return;

                await FirebaseFirestore.instance.collection('animes').add({
                  'title': title.text.trim(),
                  'genre': genre.text.trim(),
                  'year': year,
                  'season': selectedSeason,
                  'imageUrl': imageUrl.text.trim(),
                  'synopsis': synopsis.text.trim(),
                  'opTitle': opTitle.text.trim(),
                  'opArtist': opArtist.text.trim(),
                  'edTitle': edTitle.text.trim(),
                  'edArtist': edArtist.text.trim(),
                  'totalScore': 0,
                  'voteCount': 0,
                  'avgScore': 0.0,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(), // ← 追加
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
  // 作品編集
  // =============================
  void _showEditAnimeDialog(BuildContext context, QueryDocumentSnapshot anime) {
    final data = anime.data() as Map<String, dynamic>;

    final title = TextEditingController(text: data['title'] ?? '');
    final genre = TextEditingController(text: data['genre'] ?? '');
    final yearController =
        TextEditingController(text: (data['year'] ?? '').toString());
    final imageUrl = TextEditingController(text: data['imageUrl'] ?? '');
    final synopsis = TextEditingController(text: data['synopsis'] ?? '');
    final opTitle = TextEditingController(text: data['opTitle'] ?? '');
    final opArtist = TextEditingController(text: data['opArtist'] ?? '');
    final edTitle = TextEditingController(text: data['edTitle'] ?? '');
    final edArtist = TextEditingController(text: data['edArtist'] ?? '');

    String? selectedSeason = data['season'];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('作品編集'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _field(title, 'タイトル'),
                _field(yearController, '年', type: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: selectedSeason,
                  decoration: const InputDecoration(labelText: '季節'),
                  items: seasons.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => selectedSeason = v,
                ),
                _field(genre, 'ジャンル'),
                _field(imageUrl, '画像URL'),
                _field(synopsis, 'あらすじ', lines: 4),
                const Divider(),
                _field(opTitle, 'OP曲名'),
                _field(opArtist, 'OPアーティスト'),
                _field(edTitle, 'ED曲名'),
                _field(edArtist, 'EDアーティスト'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              child: const Text('保存'),
              onPressed: () async {
                final year = int.tryParse(yearController.text);
                if (year == null || selectedSeason == null) return;

                await FirebaseFirestore.instance
                    .collection('animes')
                    .doc(anime.id)
                    .update({
                  'title': title.text.trim(),
                  'genre': genre.text.trim(),
                  'year': year,
                  'season': selectedSeason,
                  'imageUrl': imageUrl.text.trim(),
                  'synopsis': synopsis.text.trim(),
                  'opTitle': opTitle.text.trim(),
                  'opArtist': opArtist.text.trim(),
                  'edTitle': edTitle.text.trim(),
                  'edArtist': edArtist.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _field(TextEditingController c, String label,
      {int lines = 1, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        maxLines: lines,
        keyboardType: type,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
