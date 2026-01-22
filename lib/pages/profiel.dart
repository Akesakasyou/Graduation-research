import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // ▼ 入力値管理
  final nicknameController = TextEditingController(text: "福沢 楸86");
  final soulCommentController = TextEditingController();
  final memberController = TextEditingController();
  final noteController = TextEditingController();

  String? selectedPrefecture;
  String? selectedGender = "男性";
  String? selectedYear = "2003";
  String? selectedMonth = "11";
  String? selectedDay = "11";

  // ▼ 都道府県リスト
  final prefectures = [
    "",
    "北海道",
    "青森県",
    "岩手県",
    "宮城県",
    "秋田県",
    "山形県",
    "福島県",
    "茨城県",
    "栃木県",
    "群馬県",
    "埼玉県",
    "千葉県",
    "東京都",
    "神奈川県",
    "新潟県",
    "富山県",
    "石川県",
    "福井県",
    "山梨県",
    "長野県",
    "岐阜県",
    "静岡県",
    "愛知県",
    "三重県",
    "滋賀県",
    "京都府",
    "大阪府",
    "兵庫県",
    "奈良県",
    "和歌山県",
    "鳥取県",
    "島根県",
    "岡山県",
    "広島県",
    "山口県",
    "徳島県",
    "香川県",
    "愛媛県",
    "高知県",
    "福岡県",
    "佐賀県",
    "長崎県",
    "熊本県",
    "大分県",
    "宮崎県",
    "鹿児島県",
    "沖縄県"
  ];

  // ▼ 1900〜2025 年
  List<String> get yearList =>
      List.generate(2025 - 1900 + 1, (i) => (1900 + i).toString())
          .reversed
          .toList();

  // ▼ 1〜12 月
  List<String> get monthList =>
      List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));

  // ▼ 1〜31 日
  List<String> get dayList =>
      List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("プロフィールの設定"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _rowColumn(
              "ニックネーム",
              TextField(
                controller: nicknameController,
                maxLength: 10,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),

            _rowColumn(
              "ヒトコト",
              TextField(
                controller: soulCommentController,
                maxLength: 100,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),

            _rowColumn(
              "都道府県",
              _dropdown(prefectures, selectedPrefecture, (val) {
                setState(() => selectedPrefecture = val);
              }),
            ),

            _rowColumn(
              "性別",
              _dropdown(["", "男性", "女性", "その他"], selectedGender, (val) {
                setState(() => selectedGender = val);
              }),
            ),

            // ▼誕生日
            _rowColumn(
              "誕生日",
              Row(
                children: [
                  Expanded(
                    child: _dropdown(yearList, selectedYear, (v) {
                      setState(() => selectedYear = v);
                    }),
                  ),
                  const Text(" 年 "),
                  Expanded(
                    child: _dropdown(monthList, selectedMonth, (v) {
                      setState(() => selectedMonth = v);
                    }),
                  ),
                  const Text(" 月 "),
                  Expanded(
                    child: _dropdown(dayList, selectedDay, (v) {
                      setState(() => selectedDay = v);
                    }),
                  ),
                  const Text(" 日"),
                ],
              ),
            ),

            _rowColumn(
              "所属",
              TextField(
                controller: memberController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),

            _rowColumn(
              "自由帳",
              TextField(
                controller: noteController,
                maxLines: 10,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),

            const SizedBox(height: 20),
            ImageButton(
              imagePath: "assets/update_btn.png", // ← 用意して使う画像
              onPressed: () {
                // ここでサーバーへ送信などが可能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("更新しました")),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 共通レイアウト
  Widget _rowColumn(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          child
        ],
      ),
    );
  }

  /// ドロップダウン共通化
  Widget _dropdown(
      List<String> list, String? value, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        underline: Container(),
        items: list
            .map((e) =>
                DropdownMenuItem(value: e, child: Text(e.isEmpty ? " " : e)))
            .toList(),
        onChanged: onChange,
      ),
    );
  }
}

/// 更新画像ボタン
class ImageButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const ImageButton(
      {super.key, required this.imagePath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(imagePath, height: 50),
    );
  }
}
