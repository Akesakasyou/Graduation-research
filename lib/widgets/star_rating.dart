import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double score; // 0〜100

  const StarRating({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    double starValue = (score / 20).clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        double diff = starValue - index;
        IconData icon;

        if (diff >= 1) {
          icon = Icons.star;
        } else if (diff >= 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return Icon(
          icon,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}
