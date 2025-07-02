import 'package:flutter/material.dart';

class DragableIcon extends StatelessWidget {
  const DragableIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Icon(
        Icons.drag_handle,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }
}