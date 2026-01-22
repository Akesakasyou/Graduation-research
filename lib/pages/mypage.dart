import 'package:flutter/material.dart';
import '../Lookingback/2000yearera.dart';
import '../Lookingback/2010yearera.dart';
import '../Lookingback/2020yearera.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool isMyRanking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profile(),
              const SizedBox(height: 16),
              _tab(),
              const SizedBox(height: 32),

              /// タブ切り替え表示
              isMyRanking ? const MyRanking() : _reviewBody(context),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== 振り返りタブの中身（指定コード）=====
  Widget _reviewBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rankingButton(context, '２０００年代', const Ranking2000sPage()),
        const SizedBox(height: 24),
        _rankingButton(context, '２０１０年代', const Ranking2010sPage()),
        const SizedBox(height: 24),
        _rankingButton(context, '２０２０年代', const Ranking2020sPage()),
      ],
    );
  }

  Widget _profile() {
    return Row(
      children: const [
        CircleAvatar(radius: 26, backgroundColor: Colors.grey),
        SizedBox(width: 16),
        Text(
          '橋本太郎',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _tab() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Row(
        children: [
          _TabItem(
            text: '振り返り',
            active: !isMyRanking,
            onTap: () {
              setState(() => isMyRanking = false);
            },
          ),
          _TabItem(
            text: 'マイランキング',
            active: isMyRanking,
            onTap: () {
              setState(() => isMyRanking = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _rankingButton(
    BuildContext context,
    String text,
    Widget page,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        color: Colors.grey.shade300,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, letterSpacing: 2),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          color: active ? Colors.grey.shade300 : Colors.white,
          child: Text(text),
        ),
      ),
    );
  }
}

/// =============================
/// マイランキング
/// =============================
class MyRanking extends StatelessWidget {
  const MyRanking({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('編集'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Spacer(),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _RankingCard(title: '歴代ラブコメランキング'),
            _RankingCard(title: '個人的好きなアニメランキング'),
            _RankingCard(title: 'ギャグ系おもしろランキング'),
            _RankingCard(title: '好きなバトルアニメ'),
          ],
        ),
      ],
    );
  }
}

class _RankingCard extends StatelessWidget {
  final String title;

  const _RankingCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
