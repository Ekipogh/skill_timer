import 'package:flutter/material.dart';

class AppConstants {
  // App info
  static const String appName = 'Skill Timer';
  static const String appVersion = '0.1.0-dev'; // Mark as development version

  // Development mode flag
  static const bool isDevelopmentMode = true; // Set to false for production

  // Database version - increment this when you add new migrations
  static const int databaseVersion = 1;

  // Database migration history (for documentation)
  static const Map<int, String> migrationHistory = {
    1: 'Initial schema with skill_categories and skills tables',
    // 2: 'Add timer_sessions table for detailed session tracking',
    // 3: 'Add user_preferences table and skill colors',
  };
}

class AppColors {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFFFAFAFA);
}
