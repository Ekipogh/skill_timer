import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skill_timer/models/learning_session.dart';
import 'package:skill_timer/models/skill.dart';
import 'package:skill_timer/providers/skill_category_provider.dart';
import 'package:skill_timer/services/foreground_timer_service.dart';
import 'package:skill_timer/services/local_notification_service.dart';

class TimerSessionProvider extends ChangeNotifier {
  static const Duration _refreshRate = Duration(milliseconds: 100);

  Skill? _currentSkill;
  Timer? _currentTimer;
  final Stopwatch _stopwatch = Stopwatch();
  Duration _elapsedTime = Duration.zero;
  Duration _targetTime = Duration.zero;
  bool _hasUnsavedSession = false;

  Skill? get currentSkill => _currentSkill;
  Duration get elapsedTime => _elapsedTime;
  bool get isRunning => _stopwatch.isRunning;
  Duration get targetTime => _targetTime;
  bool get hasUnsavedSession => _hasUnsavedSession;
  bool get canSave => _hasUnsavedSession && elapsedTime.inSeconds > 0;

  bool _isTargetNotificationSent = false;

  int _lastNotificationSecond = -1;

  Future<void> start(Skill skill) async {
    if (_hasUnsavedSession && _currentSkill?.id == skill.id) {
      await resume();
      return;
    }

    _currentSkill = skill;
    _currentTimer?.cancel();
    _stopwatch.reset();
    _elapsedTime = Duration.zero;
    _hasUnsavedSession = true;
    _isTargetNotificationSent = false;
    _stopwatch.start();
    _startTicker();

    await ForegroundTimerService.start(
      skillName: skill.name,
      elapsed: _elapsedTime,
    );

    notifyListeners();
  }

  void _timerCallback() {
    if (!_stopwatch.isRunning) return;

    _elapsedTime = _stopwatch.elapsed;

    final currentSecond = _elapsedTime.inSeconds;
    if (currentSecond != _lastNotificationSecond && _currentSkill != null) {
      _lastNotificationSecond = currentSecond;
      unawaited(
        ForegroundTimerService.update(
          skillName: _currentSkill!.name,
          elapsed: _elapsedTime,
        ),
      );
    }

    if (_targetTime != Duration.zero &&
        _elapsedTime >= _targetTime &&
        !_isTargetNotificationSent) {
      final reachedTarget = _targetTime;
      _isTargetNotificationSent = true;
      unawaited(LocalNotificationService.showNotification(
        'Target Time Reached',
        'You have reached your target time of ${reachedTarget.inMinutes} minutes for ${_currentSkill!.name}.',
      ));
      _isTargetNotificationSent = true;
    }

    notifyListeners();
  }

  Future<void> pause() async {
    _elapsedTime = _stopwatch.elapsed;
    _stopwatch.stop();
    _currentTimer?.cancel();

    await ForegroundTimerService.stop();

    notifyListeners();
  }

  Future<void> resume() async {
    if (_currentSkill == null || _stopwatch.isRunning) {
      return;
    }

    _stopwatch.start();
    _startTicker();

    await ForegroundTimerService.start(
      skillName: _currentSkill!.name,
      elapsed: _elapsedTime,
    );

    notifyListeners();
  }

  Future<void> discard() async {
    _stopwatch.stop();
    _stopwatch.reset();
    _elapsedTime = Duration.zero;
    _currentTimer?.cancel();
    _currentSkill = null;
    _hasUnsavedSession = false;
    _lastNotificationSecond = -1;
    _resetTargetTime();

    await ForegroundTimerService.stop();

    notifyListeners();
  }

  Future<LearningSession?> save(SkillProvider skillProvider) async {
    final skill = _currentSkill;
    final duration = _elapsedTime.inSeconds;
    if (skill == null || duration == 0) {
      return null;
    }

    _stopwatch.stop();
    _currentTimer?.cancel();
    _elapsedTime = _stopwatch.elapsed;

    final session = LearningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      skillId: skill.id,
      duration: duration,
      datePerformed: DateTime.now(),
    );

    await skillProvider.addSession(session.toMap().cast<String, Object>());
    if (skillProvider.hasError) {
      throw StateError(skillProvider.error ?? 'Failed to save session');
    }

    await discard();
    return session;
  }

  Future<void> setTargetTime(Duration targetTime) async {
    _targetTime = targetTime;
    _isTargetNotificationSent = false;
    notifyListeners();
  }

  void _resetTargetTime() {
    _targetTime = Duration.zero;
    _isTargetNotificationSent = false;
  }

  void _startTicker() {
    _currentTimer?.cancel();
    _currentTimer = Timer.periodic(_refreshRate, (_) => _timerCallback());
  }

  @override
  void dispose() {
    _currentTimer?.cancel();
    super.dispose();
  }
}
