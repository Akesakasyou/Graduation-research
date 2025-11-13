import 'package:flutter/material.dart';
import 'Share/header.dart'; // 共通ヘッダー
import 'Share/footer.dart'; // 共通フッターを追加

class MainPageWidget extends StatelessWidget {
  const MainPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // トップスライダー
            Container(
              height: 180,
              color: Colors.grey[300],
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: const Text('スライダー', style: TextStyle(fontSize: 20)),
            ),

            // 今期アニメ
            const SectionTitle(title: '～ 今期アニメ ～'),
            const AnimeRow(),
            const SeeMoreButton(),

            // 掘りかえそう
            const SectionTitle(title: '～ 掘りかえそう ～'),
            const AnimeRow(),
            const SeeMoreButton(),

            // ジャンル
            const SectionTitle(title: '～ ジャンル ～'),
            const AnimeGrid(),
            const SeeMoreButton(),

            // フッターを追加（共通利用）
            const SizedBox(height: 20),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

/// セクションタイトル
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 横スクロール画像エリア
class AnimeRow extends StatelessWidget {
  const AnimeRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: 100,
          margin: const EdgeInsets.all(8),
          color: Colors.grey[400],
          alignment: Alignment.center,
          child: Text('画像${index + 1}'),
        ),
      ),
    );
  }
}

/// グリッド形式の画像エリア
class AnimeGrid extends StatelessWidget {
  const AnimeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) => Container(
          color: Colors.grey[400],
          alignment: Alignment.center,
          child: Text('画像${index + 1}'),
        ),
      ),
    );
  }
}

/// 「もっと見る」ボタン
class SeeMoreButton extends StatelessWidget {
  const SeeMoreButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 200,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Text('もっと見る'),
    );
  }
}
