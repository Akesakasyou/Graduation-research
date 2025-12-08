import 'package:flutter/material.dart';
import '../MF/Cool Ranking/2025Author.dart'; // AnimeDetailPage のファイルパスを調整
import 'vote_page.dart';

// =============================
// 共通ヘッダー
// =============================
class CustomHeader extends StatefulWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  State<CustomHeader> createState() => _CustomHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomHeaderState extends State<CustomHeader> {
  bool isDark = true;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  void _showProfileMenu(BuildContext context, Offset offset) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(offset, offset.translate(0, 40)),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem<int>(
          value: 0,
          child: Text('マイページ'),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Text('プロフィール'),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text('ログイン'),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('マイページを開きます')));
      } else if (value == 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('プロフィールを開きます')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? Colors.black : Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: SizedBox(
        height: 40,
        child: TextField(
          decoration: InputDecoration(
            hintText: '検索バー',
            hintStyle:
                TextStyle(color: isDark ? Colors.black54 : Colors.black45),
            fillColor: isDark ? Colors.white : Colors.grey[200],
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon:
                Icon(Icons.person, color: isDark ? Colors.white : Colors.black),
            onPressed: () async {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final offset = button.localToGlobal(Offset.zero);
              _showProfileMenu(context, offset);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: toggleTheme,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// =============================
// ドロワーメニュー
// =============================
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black87),
            child: Text(
              'メニュー',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.how_to_vote),
            title: Text('投票する'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VotePage(), // ← ここに遷移先を書く
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.history),
            title: Text('投票履歴'),
          ),
          const ListTile(
            leading: Icon(Icons.forum),
            title: Text('スレッド'),
          ),

          // ▼ 歴代アニメランキング
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('歴代アニメランキング'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnimeDetailPage(),
                ),
              );
            },
          ),

          // ▼ 今期アニメランキング
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('今期アニメランキング'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnimeDetailPage(),
                ),
              );
            },
          ),

          // ▼ ジャンルランキング（修正追加）
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('ジャンルランキング'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnimeDetailPage(),
                ),
              );
            },
          ),

          const ListTile(
            leading: Icon(Icons.schedule),
            title: Text('来季アニメ'),
          ),

          // ▼ 振り返りページ（修正追加）
          ListTile(
            leading: const Icon(Icons.replay),
            title: const Text('振り返りページ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnimeDetailPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================
// アニメ詳細ページ
// =============================
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
                  _buildTabContent('ユーザーのレビューや感想がここに表示されます。'),
                  _buildTabContent('ジャンルや制作会社などのカテゴリ情報。'),
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
