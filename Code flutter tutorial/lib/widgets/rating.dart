import 'package:flutter/material.dart';

class Rating extends StatelessWidget {
  final int maxStars;
  final double count;
  final Color? color;
  final double? size;
  const Rating(
    this.count, {
    super.key,
    this.color,
    this.size,
    this.maxStars = 5,
  });
  const Rating.percent(double percent, {Key? key})
    : this(percent / 20.0, key: key);

  @override
  Widget build(BuildContext context) {
    final clamped = count.clamp(0, maxStars);
    final fullStars = clamped.floor();
    final halfStar = (clamped - fullStars) >= 0.5 ? 1 : 0;
    final emptyStars = maxStars - fullStars - halfStar;

    final iconDefaults = Theme.of(context).iconTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 1; i <= fullStars; i++)
          Icon(
            Icons.star,
            color: color ?? iconDefaults.color,
            size: size ?? iconDefaults.size,
          ),

        if (halfStar > 0)
          Icon(
            Icons.star_half,
            color: color ?? iconDefaults.color,
            size: size ?? iconDefaults.size,
          ),

        for (int i = 1; i <= emptyStars; i++)
          Icon(
            Icons.star_border,
            color: color ?? iconDefaults.color,
            size: size ?? iconDefaults.size,
          ),
      ],
    );
  }
}
