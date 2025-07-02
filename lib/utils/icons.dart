import 'package:flutter/material.dart';

const Map<String, IconData> iconMap = {
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
  'draw': Icons.draw,
  'school': Icons.school,
  'sports': Icons.sports,
  'science': Icons.science,
  'business': Icons.business,
  'psychology': Icons.psychology,
  'garage': Icons.garage,
  'home': Icons.home,
  'gamepad': Icons.gamepad,
  'yard': Icons.yard,
  'hiking': Icons.hiking,
  'directions_run': Icons.directions_run,
  'sports_baseball': Icons.sports_baseball,
  'directions_bike': Icons.directions_bike,
  'directions_boat': Icons.directions_boat,
};

IconData getIcon({required String iconName}) {
  return iconMap[iconName] ?? Icons.help_outline; // Default icon if not found
}
