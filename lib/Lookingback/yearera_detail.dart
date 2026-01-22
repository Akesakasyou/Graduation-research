import 'package:flutter/material.dart';

class YearDetailPage extends StatelessWidget {
  final int year;

  const YearDetailPage({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profile(),
            const SizedBox(height: 16),
            _tab(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 編集ボタン
                    _editButton(),
                    const SizedBox(height: 16),

                    /// 中身表示エリア
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// プロフィール
  Widget _profile() => Row(
        children: const [
          CircleAvatar(radius: 26, backgroundColor: Colors.grey),
          SizedBox(width: 16),
          Text(
            '橋本太郎',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );

  /// タブ
  Widget _tab() => Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: const Row(
          children: [
            _TabItem(text: '振り返り', active: false),
            _TabItem(text: 'マイランキング', active: true),
          ],
        ),
      );

  /// 編集ボタン
  Widget _editButton() {
    return InkWell(
      onTap: () {
        // 今後 編集画面へ遷移などを実装
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 16),
            SizedBox(width: 6),
            Text('編集'),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final bool active;

  const _TabItem({required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        color: active ? Colors.grey.shade300 : Colors.white,
        child: Text(text),
      ),
    );
  }
}
