import 'dart:math';

import 'package:flutter/material.dart';

@immutable
class CategoryView extends StatelessWidget {
  final String? title;
  final VoidCallback? onPressed;
  final String image;

  const CategoryView({super.key, required this.title, required this.onPressed, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        height: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onBackground.withAlpha(75), // 0.2 * 255 ≈ 51
                  ),
                  child: Center(
                    child: Text(
                      title ?? '',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Theme.of(context).colorScheme.background,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
