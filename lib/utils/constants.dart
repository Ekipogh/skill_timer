import 'package:flutter/material.dart';

class AppConstants {
  // App info
  static const String appName = 'Skill Timer';
  static const String appVersion = '1.0.0';
  
  // Timer defaults
  static const int defaultSessionDuration = 25 * 60; // 25 minutes in seconds
  static const int shortBreakDuration = 5 * 60; // 5 minutes
  static const int longBreakDuration = 15 * 60; // 15 minutes
  
  // Categories
  static const List<String> defaultCategories = [
    'Programming',
    'Design',
    'Language Learning',
    'Music',
    'Sports',
    'Reading',
    'Writing',
    'Other',
  ];
  
  // Storage keys
  static const String skillsStorageKey = 'skills';
  static const String sessionsStorageKey = 'sessions';
  static const String settingsStorageKey = 'settings';
}

class AppColors {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFFFAFAFA);
}
