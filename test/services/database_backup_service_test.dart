import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:skill_timer/services/database_backup_service.dart';

void main() {
  Uint8List backupBytes({Map<String, dynamic>? data, int formatVersion = 1}) {
    return Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'format': 'skill_timer_backup',
          'formatVersion': formatVersion,
          'databaseVersion': 2,
          'exportedAt': '2026-07-20T12:00:00.000Z',
          'data':
              data ??
              {
                'skillCategories': [
                  {
                    'id': 'development',
                    'name': 'Development',
                    'description': 'Build things',
                    'iconPath': 'code',
                  },
                ],
                'skills': [
                  {
                    'id': 'flutter',
                    'name': 'Flutter',
                    'description': 'Apps',
                    'iconPath': 'phone_android',
                    'category': 'development',
                  },
                ],
                'timerSessions': [
                  {
                    'id': 'session-1',
                    'skillId': 'flutter',
                    'duration': 600,
                    'datePerformed': '2026-07-20T12:00:00.000',
                  },
                ],
              },
        }),
      ),
    );
  }

  test('accepts a valid backup with intact relationships', () {
    final backup = DatabaseBackupService.decodeAndValidate(backupBytes());

    expect(backup['format'], 'skill_timer_backup');
  });

  test('rejects an unsupported backup format version', () {
    expect(
      () => DatabaseBackupService.decodeAndValidate(
        backupBytes(formatVersion: 99),
      ),
      throwsA(isA<DatabaseBackupException>()),
    );
  });

  test('accepts historical sessions whose skill has been deleted', () {
    final bytes = backupBytes(
      data: {
        'skillCategories': <Map<String, Object?>>[],
        'skills': <Map<String, Object?>>[],
        'timerSessions': [
          {
            'id': 'session-1',
            'skillId': 'missing',
            'duration': 10,
            'datePerformed': '2026-07-20T12:00:00.000',
          },
        ],
      },
    );

    final backup = DatabaseBackupService.decodeAndValidate(bytes);
    final data = backup['data'] as Map<String, dynamic>;
    final sessions = data['timerSessions'] as List<dynamic>;

    expect(sessions, hasLength(1));
    expect((sessions.single as Map<String, dynamic>)['skillId'], 'missing');
  });

  test('rejects invalid JSON', () {
    expect(
      () => DatabaseBackupService.decodeAndValidate(
        Uint8List.fromList(utf8.encode('not json')),
      ),
      throwsA(isA<DatabaseBackupException>()),
    );
  });
}
