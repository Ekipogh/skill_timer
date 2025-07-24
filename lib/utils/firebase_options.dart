import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Firebase configuration - these are safe to expose in client code
  // as Firebase security is enforced through server-side Security Rules
  static final String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? "";
  static final String authDomain =
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'ru.ekipogh.skill_timer';
  static final String projectId =
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'skilltimer-782c0';
  static final String appId =
      dotenv.env['FIREBASE_APP_ID'] ??
      '1:492145826496:android:c2898cd581e721529f2b25';
  static final String storageBucket =
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ??
      'skilltimer-782c0.firebasestorage.app';
  static final String messagingSenderId =
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '492145826496';

  static FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    authDomain: authDomain,
    projectId: projectId,
    appId: appId,
    messagingSenderId: messagingSenderId,
    storageBucket: storageBucket,
  );
}
