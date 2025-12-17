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

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final anime = docs[index];

              return Card(
                child: ListTile(
                  leading: anime['imageUrl'] != ""
                      ? Image.network(anime['imageUrl'], width: 50)
                      : const Icon(Icons.image),
                  title: Text(anime['title']),
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
  // 作品追加ダイアログ
  // =============================
  void _showAddAnimeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("作品追加"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "アニメタイトル"),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "画像URL（任意）"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("追加"),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                await FirebaseFirestore.instance.collection('animes').add({
                  'title': titleController.text.trim(),
                  'imageUrl': imageController.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("作品を追加しました")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // =============================
  // 作品編集ダイアログ
  // =============================
  void _showEditAnimeDialog(BuildContext context, QueryDocumentSnapshot anime) {
    final titleController = TextEditingController(text: anime['title']);
    final imageController = TextEditingController(text: anime['imageUrl']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("作品編集"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "アニメタイトル"),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "画像URL"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("保存"),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('animes')
                    .doc(anime.id)
                    .update({
                  'title': titleController.text.trim(),
                  'imageUrl': imageController.text.trim(),
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("作品を更新しました")),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
