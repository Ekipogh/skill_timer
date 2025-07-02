import 'package:flutter/material.dart';

Map<String, IconData> iconMap = {
  'code': Icons.code,
  'brush': Icons.brush,
  'music_note': Icons.music_note,
  'piano': Icons.piano,
  'camera_alt': Icons.camera_alt,
  'language': Icons.language,
  'design_services': Icons.design_services,
  'fitness_center': Icons.fitness_center,
  'kitchen': Icons.kitchen,
  'palette': Icons.palette,
  'book': Icons.book,
};

IconData getIcon({required String iconName}) {
  return iconMap[iconName] ?? Icons.help_outline; // Default icon if not found
}
