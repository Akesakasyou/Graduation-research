import 'package:flutter/material.dart';
import 'yearera_detail.dart';

class Ranking2020sPage extends StatelessWidget {
  const Ranking2020sPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseRankingPage(
      title: '２０２０年代',
      startYear: 2020,
    );
  }
}

class BaseRankingPage extends StatelessWidget {
  final String title;
  final int startYear;

  const BaseRankingPage({
    super.key,
    required this.title,
    required this.startYear,
  });

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
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, letterSpacing: 3),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        itemCount: 10,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2.5,
                        ),
                        itemBuilder: (context, index) {
                          final year = startYear + index;

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      YearDetailPage(year: year),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.grey.shade300,
                              child: Text(
                                '$year年',
                                style:
                                    const TextStyle(letterSpacing: 2),
                              ),
                            ),
                          );
                        },
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
      child: const Row(
        children: [
          _TabItem(text: '振り返り', active: false),
          _TabItem(text: 'マイランキング', active: true),
        ],
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
