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

  // Firebase configuration - these are safe to expose in client code
  // as Firebase security is enforced through server-side Security Rules
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
  );
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'ru.ekipogh.skill_timer'
  );
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'skilltimer-782c0'
  );
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:492145826496:android:c2898cd581e721529f2b25'
  );
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'skilltimer-782c0.firebasestorage.app'
  );
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '492145826496'
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    authDomain: authDomain,
    projectId: projectId,
    appId: appId,
    messagingSenderId: messagingSenderId,
    storageBucket: storageBucket,
  );
}
