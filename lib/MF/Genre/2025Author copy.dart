import 'package:flutter/material.dart';

class AnimeDetailPage extends StatefulWidget {
  const AnimeDetailPage({super.key});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アニメ詳細'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ランキング・タイトル
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text('1', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'アニメタイトル',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 画像とあらすじ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 画像
                  Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[400],
                    alignment: Alignment.center,
                    child: const Text('画像'),
                  ),
                  const SizedBox(width: 16),
                  // あらすじ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'あらすじ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ここにアニメのあらすじが入ります。長い文章も対応しています。'
                          '～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～ ～',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 星評価 ＋ お気に入り
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(Icons.star, color: Colors.amber),
                    )..add(
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text('(4.5)', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'お気に入り',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1),

            // タブ
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'レビュー・感想'),
                Tab(text: 'カテゴリ'),
                Tab(text: 'スレッド'),
              ],
            ),

            // タブの中身
            SizedBox(
              height: 250,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // レビュー・感想
                  _buildTabContent(
                      'ユーザーのレビューや感想がここに表示されます。'),

                  // カテゴリ
                  _buildTabContent('ジャンルや制作会社などのカテゴリ情報。'),

                  // スレッド
                  _buildTabContent('コメントやスレッドが表示されます。'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }
}
