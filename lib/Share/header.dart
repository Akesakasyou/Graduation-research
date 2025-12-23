import 'package:flutter/material.dart';
import '../MF/Cool Ranking/2025Author.dart';
import '../pages/vote_page.dart';
import '../pages/ranking_page.dart';
import '../pages/my_ranking_page.dart';
import '../pages/search_result_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/AdminPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final TextEditingController _searchController = TextEditingController();

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
        PopupMenuItem<int>(value: 0, child: Text('マイページ')),
        PopupMenuItem<int>(value: 1, child: Text('プロフィール')),
        PopupMenuItem<int>(value: 2, child: Text('ログイン')),
      ],
    );
  }

  void _onSearch(String keyword) {
    if (keyword.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(keyword: keyword),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? Colors.black : Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearch,
          decoration: InputDecoration(
            hintText: '作品名で検索',
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
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon:
                Icon(Icons.person, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
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

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    print("UID: ${user?.uid}");

    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    print("User doc exists: ${doc.exists}");
    print("User data: ${doc.data()}");

    return doc.data()?['isAdmin'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<bool>(
        future: _isAdmin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final isAdmin = snapshot.data!;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.black87),
                child: Text(
                  'メニュー',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),

              // ===== 共通メニュー =====
              ListTile(
                leading: const Icon(Icons.how_to_vote),
                title: const Text('投票する'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VotePage()),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('マイランキング'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyRankingPage(),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.leaderboard),
                title: const Text('総合ランキング'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RankingPage()),
                ),
              ),

              // ===== 管理者専用 =====
              if (isAdmin) ...[
                const Divider(),
                const ListTile(
                  title: Text(
                    '管理者',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('管理者画面'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPage()),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// =============================
// アニメ詳細ページ（固定表示用）
// =============================
class AnimeDetailPageStatic extends StatefulWidget {
  const AnimeDetailPageStatic({super.key});
  @override
  State<AnimeDetailPageStatic> createState() => _AnimeDetailPageStaticState();
}

class _AnimeDetailPageStaticState extends State<AnimeDetailPageStatic>
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
      appBar: AppBar(title: const Text('アニメ詳細'), backgroundColor: Colors.black),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _header(),
          _imageAndSummary(),
          const SizedBox(height: 16),
          _ratingAndFavorite(),
          const SizedBox(height: 16),
          const Divider(),
          _tabs(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: const Text('1', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          const Text(
            'アニメタイトル',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _imageAndSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 150,
            color: Colors.grey[400],
            alignment: Alignment.center,
            child: const Text('画像'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('あらすじ', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'ここにアニメのあらすじが入ります…',
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingAndFavorite() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            ...List.generate(
                5, (_) => const Icon(Icons.star, color: Colors.amber)),
            const SizedBox(width: 6),
            const Text('(4.5)'),
          ]),
          GestureDetector(
            onTap: () => setState(() => isFavorite = !isFavorite),
            child: Row(
              children: [
                Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black54),
                const SizedBox(width: 4),
                const Text('お気に入り'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'レビュー・感想'),
            Tab(text: 'カテゴリ'),
            Tab(text: 'スレッド'),
          ],
          labelColor: Colors.black,
          indicatorColor: Colors.black,
        ),
        SizedBox(
          height: 250,
          child: TabBarView(
            controller: _tabController,
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('レビューが表示されます'),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('カテゴリ情報'),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('スレッド一覧'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
