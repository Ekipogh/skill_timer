import 'dart:convert';
import 'dart:typed_data';

import '../utils/constants.dart';
import 'database.dart';

class DatabaseBackupException implements Exception {
  const DatabaseBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DatabaseBackupService {
  static const int backupFormatVersion = 1;

  Future<Uint8List> exportBackup() async {
    final db = await DBProvider().database;
    final backup = <String, Object>{
      'format': 'skill_timer_backup',
      'formatVersion': backupFormatVersion,
      'databaseVersion': AppConstants.databaseVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': <String, Object>{
        'skillCategories': await db.query('skill_categories'),
        'skills': await db.query('skills'),
        'timerSessions': await db.query('timer_sessions'),
      },
    };

    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(backup)),
    );
  }

  Future<void> importBackup(Uint8List bytes) async {
    final backup = decodeAndValidate(bytes);
    final data = backup['data'] as Map<String, dynamic>;
    final categories = _rows(data, 'skillCategories');
    final skills = _rows(data, 'skills');
    final sessions = _rows(data, 'timerSessions');
    final db = await DBProvider().database;

    await db.transaction((transaction) async {
      await transaction.delete('timer_sessions');
      await transaction.delete('skills');
      await transaction.delete('skill_categories');

      for (final row in categories) {
        await transaction.insert('skill_categories', row);
      }
      for (final row in skills) {
        await transaction.insert('skills', row);
      }
      for (final row in sessions) {
        await transaction.insert('timer_sessions', row);
      }
    });
  }

  static Map<String, dynamic> decodeAndValidate(Uint8List bytes) {
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on Object {
      throw const DatabaseBackupException(
        'The selected file is not valid JSON.',
      );
    }

    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'skill_timer_backup' ||
        decoded['formatVersion'] != backupFormatVersion) {
      throw const DatabaseBackupException(
        'This is not a supported Skill Timer backup.',
      );
    }
    final databaseVersion = decoded['databaseVersion'];
    if (databaseVersion is! int ||
        databaseVersion > AppConstants.databaseVersion) {
      throw const DatabaseBackupException(
        'This backup was created by a newer, incompatible version of Skill Timer.',
      );
    }
    if (decoded['data'] is! Map<String, dynamic>) {
      throw const DatabaseBackupException(
        'The backup does not contain a data section.',
      );
    }

    final data = decoded['data'] as Map<String, dynamic>;
    final categories = _validateRows(
      data,
      'skillCategories',
      requiredFields: const {'id': String, 'name': String},
    );
    final skills = _validateRows(
      data,
      'skills',
      requiredFields: const {'id': String, 'name': String, 'category': String},
    );
    final sessions = _validateRows(
      data,
      'timerSessions',
      requiredFields: const {
        'id': String,
        'skillId': String,
        'duration': int,
        'datePerformed': String,
      },
    );

    final categoryIds = categories.map((row) => row['id']).toSet();
    final skillIds = skills.map((row) => row['id']).toSet();
    if (skills.any((row) => !categoryIds.contains(row['category']))) {
      throw const DatabaseBackupException(
        'The backup contains a skill with a missing category.',
      );
    }
    if (sessions.any((row) => !skillIds.contains(row['skillId']))) {
      throw const DatabaseBackupException(
        'The backup contains a session with a missing skill.',
      );
    }
    for (final session in sessions) {
      if ((session['duration'] as int) < 0 ||
          DateTime.tryParse(session['datePerformed'] as String) == null) {
        throw const DatabaseBackupException(
          'The backup contains an invalid timer session.',
        );
      }
    }

    return decoded;
  }

  static List<Map<String, Object?>> _validateRows(
    Map<String, dynamic> data,
    String key, {
    required Map<String, Type> requiredFields,
  }) {
    final value = data[key];
    if (value is! List) {
      throw DatabaseBackupException('The backup is missing $key.');
    }

    final rows = <Map<String, Object?>>[];
    for (final valueRow in value) {
      if (valueRow is! Map<String, dynamic>) {
        throw DatabaseBackupException(
          'The backup contains an invalid $key entry.',
        );
      }
      for (final field in requiredFields.entries) {
        if (valueRow[field.key].runtimeType != field.value) {
          throw DatabaseBackupException(
            'The backup contains an invalid $key entry.',
          );
        }
      }
      rows.add(Map<String, Object?>.from(valueRow));
    }
    return rows;
  }

  static List<Map<String, Object?>> _rows(Map<String, dynamic> data, String key) {
    return (data[key] as List)
        .cast<Map<String, dynamic>>()
        .map(Map<String, Object?>.from)
        .toList();
  }
}
