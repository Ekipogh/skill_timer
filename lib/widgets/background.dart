  import 'package:flutter/material.dart';
  class SwipeBackground extends StatelessWidget {
    final bool isLeft;

    const SwipeBackground({super.key, required this.isLeft});

    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isLeft ? Colors.blue : Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLeft ? Icons.edit : Icons.delete,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              isLeft ? 'Edit' : 'Delete',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }