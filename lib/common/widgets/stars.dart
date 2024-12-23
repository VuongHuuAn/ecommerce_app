import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Stars extends StatelessWidget {
  final double rating;
  const Stars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      direction: Axis.horizontal,
      rating: rating,
      itemCount: 5,
      itemSize: 14,
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: GlobalVariables.secondaryColor,
      ),
    );
  }
}
