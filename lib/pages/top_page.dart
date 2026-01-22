import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'firebase_options.dart';
import 'dart:async';
import '../Share/header.dart'; // 共通ヘッダー
import '../Share/footer.dart'; // 共通フッター
import '../User/User.dart'; // AnimeListPage など

class MainPageWidget extends StatefulWidget {
  const MainPageWidget({super.key});

  @override
  State<MainPageWidget> createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget> {
  final List<Map<String, String>> _sliderItems = const [
    {
      "image": "Image/GNOCIA.png",
      "title": "合わなかった…のかなぁ、なんだろうなぁ。",
      "nickname": "take_0(ゼロ)"
    },
    {
      "image": "Image/GNOCIA.png",
      "title": "合わなかった…のかなぁ、なんだろうなぁ。",
      "nickname": "take_0(ゼロ)"
    },
    {
      "image": "Image/GNOCIA.png",
      "title": "合わなかった…のかなぁ、なんだろうなぁ。",
      "nickname": "take_0(ゼロ)"
    },
    {
      "image": "Image/GNOCIA.png",
      "title": "合わなかった…のかなぁ、なんだろうなぁ。",
      "nickname": "take_0(ゼロ)"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHtmlSlider(),
            const SizedBox(height: 20),
            const MyListSlider(),
            const MyListSlider2(),
            const SizedBox(height: 30),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHtmlSlider() {
    return SizedBox(
      height: 260,
      child: AutoScrollSlider(items: _sliderItems),
    );
  }
}

// =====================================================
// 無限横スクロール Slider
// =====================================================
class AutoScrollSlider extends StatefulWidget {
  final List<Map<String, String>> items;

  const AutoScrollSlider({super.key, required this.items});

  @override
  State<AutoScrollSlider> createState() => _AutoScrollSliderState();
}

class _AutoScrollSliderState extends State<AutoScrollSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRow() {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: widget.items.map((item) {
        return Container(
          width: 260,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  item["image"]!,
                  height: 160,
                  width: 260,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: 260,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"]!,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item["nickname"]!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fullWidth = MediaQuery.of(context).size.width;

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double offset = -fullWidth * _controller.value;

          return Transform.translate(
            offset: Offset(offset, 0),
            child: Row(
              children: [
                _buildRow(),
                _buildRow(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// ユーザー今期アニメスライダー（thisterm / thisterm1）
// =====================================================
class MyListSlider extends StatelessWidget {
  const MyListSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "～ ユーザー今期アニメ ～",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("thisterm")
                .doc("thisterm1")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              final List items = data["items"] ?? [];

              if (items.isEmpty) {
                return const Center(child: Text("データがありません"));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildCard(context, item);
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
          MaterialPageRoute(builder: (context) => const AnimeListPage()),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- 画像 ----------
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item["images"] != null && item["images"] != ""
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
            ),

            const SizedBox(height: 8),

            // ---------- タイトル ----------
            Text(
              item["title"] ?? "",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            // ---------- 作品数 ----------
            Text("作品数：${item["count"] ?? ""}"),

            // ---------- 作成者 ----------
            Text("作成者：${item["user"] ?? ""}"),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// ユーザーアニメスライダー
// =====================================================
class MyListSlider2 extends StatelessWidget {
  const MyListSlider2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "～ ユーザーアニメ ～",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("Useranime").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _buildCard(data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------- 画像 -------
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                item["images"] != null && item["images"].toString().isNotEmpty
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
          ),

          const SizedBox(height: 8),

          // ------- タイトル -------
          Text(
            item["title"] ?? "",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          // ------- 作品数（sakuhin） -------
          Text("作品数：${item["sakuhin"] ?? ""}"),

          // ------- 作成者 -------
          Text("作成者：${item["user"] ?? ""}"),
        ],
      ),
    );
  }
}
