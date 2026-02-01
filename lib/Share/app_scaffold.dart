import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== 遷移先 =====
import '../pages/mypage.dart';
import '../pages/profiel.dart';
import '../pages/vote_select_page.dart';
import '../pages/my_ranking_page.dart';
import '../pages/ranking_page.dart';
import '../pages/AdminPage.dart';
import '../LN/Nrlogin.dart';
import '../pages/search_result_page.dart';

/// ===================================================
/// 共通 Scaffold（AppBar + Drawer）
/// ===================================================
class AppScaffold extends StatefulWidget {
  final Widget body;

  const AppScaffold({super.key, required this.body});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool isDark = true;
  final TextEditingController _searchController = TextEditingController();

  // =========================
  // 検索
  // =========================
  void _onSearch(String keyword) {
    if (keyword.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(keyword: keyword),
      ),
    );
  }

  // =========================
  // プロフィールメニュー
  // =========================
  Future<void> _showProfileMenu(BuildContext context, Offset offset) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<int>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(offset, offset.translate(0, 40)),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(value: 0, child: Text('マイページ')),
        PopupMenuItem(value: 1, child: Text('プロフィール')),
        PopupMenuItem(value: 2, child: Text('ログアウト')),
      ],
    );

    if (!mounted || result == null) return;

    switch (result) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileEditPage()),
        );
        break;
      case 2:
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
        break;
    }
  }

  // =========================
  // 管理者判定
  // =========================
  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['isAdmin'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            onSubmitted: _onSearch,
            decoration: InputDecoration(
              hintText: '作品名で検索',
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.person,
                  color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                final box = context.findRenderObject() as RenderBox;
                _showProfileMenu(
                  context,
                  box.localToGlobal(Offset.zero),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => setState(() => isDark = !isDark),
          ),
        ],
      ),

      // =========================
      // Drawer
      // =========================
      drawer: Drawer(
        child: FutureBuilder<bool>(
          future: _isAdmin(),
          builder: (context, snapshot) {
            final isAdmin = snapshot.data == true;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Text(
                    'メニュー',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.how_to_vote),
                  title: const Text('投票する'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VoteSelectPage()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('マイランキング'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyRankingPage()),
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
                if (isAdmin) ...[
                  const Divider(),
                  const ListTile(
                    title: Text('管理者',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),

      body: widget.body,
    );
  }
}
