import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class SkillTimerFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      // TODO: Handle this case.
      TargetPlatform.fuchsia => throw UnimplementedError(),
      // TODO: Handle this case.
      TargetPlatform.iOS => throw UnimplementedError(),
      // TODO: Handle this case.
      TargetPlatform.linux => throw UnimplementedError(),
      // TODO: Handle this case.
      TargetPlatform.macOS => throw UnimplementedError(),
      // TODO: Handle this case.
      TargetPlatform.windows => throw UnimplementedError(),
    };
  }

  // Common options for all platforms
  static const String apiKey = 'AIzaSyC_uwSDM5Fc3aB_gQCiU5HQ4jWFuGnjG9w';
  static const String authDomain = 'ru.ekipogh.skill_timer';
  static const String projectId = 'skilltimer-782c0';
  static const String appId = '1:492145826496:android:c2898cd581e721529f2b25';
  static const String storageBucket = 'skilltimer-782c0.firebasestorage.app';
  static const String messagingSenderId = '492145826496';

  static FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    authDomain: authDomain,
    projectId: projectId,
    appId: appId,
    messagingSenderId: messagingSenderId,
    storageBucket: storageBucket,
  );
}
