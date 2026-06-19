import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/models/skill.dart';
import 'package:skill_timer/screens/manual_data.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/skill_category_provider.dart';
import '../widgets/widgets.dart';

class TimerScreen extends StatefulWidget {
  final Skill skill;

  const TimerScreen({required this.skill, super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final int _refreshRate = 100; // Update every 100 milliseconds
  String _elapsedTime = '00:00:00.000';
  bool _sessionSaved = true;
  int _targetTime = 0; // Initialize target time to 0

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setWakelockEnabled(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } catch (e) {
      debugPrint('Failed to ${enabled ? 'enable' : 'disable'} wakelock: $e');
    }
  }

  void _startTimer() {
    if (_stopwatch.isRunning) {
      return;
    }

    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _refreshRate),
      _timerCallback,
    );
    _stopwatch.start();
    unawaited(_setWakelockEnabled(true));
    _setElapsedTime(sessionSaved: false);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    unawaited(_setWakelockEnabled(false));
    _setElapsedTime();
  }

  void _setElapsedTime({bool? sessionSaved}) {
    if (!mounted) {
      return;
    }

    final elapsed = _stopwatch.elapsed;
    setState(() {
      _elapsedTime = TimeFormatter.formatWithMilliseconds(elapsed);
      if (sessionSaved != null) {
        _sessionSaved = sessionSaved;
      }
    });
  }

  void _timerCallback(Timer timer) {
    if (_stopwatch.isRunning) {
      _setElapsedTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.skill.name,
        centerTitle: true,
        actions: [
          CustomIconButton(
            icon: Icons.border_color,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ManualDataEntryScreen(skill: widget.skill),
                ),
              );
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
          final bool isRunningOrNotSaved =
              _stopwatch.isRunning || !_sessionSaved;
          if (isRunningOrNotSaved) {
            final bool shouldPop = await UnsavedChangesDialog.show(
              context,
              isTimerRunning: _stopwatch.isRunning,
            );
            if (context.mounted && shouldPop) {
              Navigator.pop(context);
            }
          } else {
            Navigator.pop(context);
          }
        },
        child: TimerGradientBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Skill info card
                  IconCard(
                    icon: Icons.psychology,
                    iconColor: colorScheme.primary,
                    iconBackgroundColor: colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    title: widget.skill.name,
                    subtitle: widget.skill.description.isNotEmpty
                        ? widget.skill.description
                        : null,
                    padding: const EdgeInsets.all(20),
                  ),

                  const Spacer(),

                  // Timer display
                  TimerDisplay(
                    elapsedTime: _elapsedTime,
                    isRunning: _stopwatch.isRunning,
                    targetTime: _targetTime > 0 ? _targetTime : null,
                  ),

                  const SizedBox(height: 10),

                  // Target time card
                  TargetTimeCard(
                    selectedTargetTime: _targetTime > 0 ? _targetTime : null,
                    onTargetTimeSelected: (selectedTime) {
                      // Handle target time selection
                      setState(() {
                        _targetTime = selectedTime;
                      });
                    },
                  ),

                  const SizedBox(height: 40),

                  // Control button
                  _stopwatch.isRunning
                      ? PauseButton(
                          onPressed: () {
                            _stopTimer();
                          },
                        )
                      : StartButton(
                          onPressed: () {
                            _startTimer();
                          },
                        ),

                  const Spacer(),

                  // Stats row
                  StatsCard(
                    stats: [
                      StatItem(
                        icon: Icons.timer,
                        label: 'Total Time',
                        value: TimeFormatter.format(
                          widget.skill.totalTimeSpent,
                        ),
                      ),
                      StatItem(
                        icon: Icons.analytics,
                        label: 'Sessions',
                        value: '${widget.skill.sessionsCount}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _sessionSaved
          ? null
          : SaveButton(
              onPressed: () async {
                if (!_stopwatch.isRunning &&
                    _stopwatch.elapsed.inSeconds == 0) {
                  return; // Do nothing if no time has elapsed
                }

                final bool shouldSave = await SaveSessionDialog.show(
                  context,
                  skillName: widget.skill.name,
                  elapsedTime: _elapsedTime,
                );
                if (!shouldSave) {
                  return;
                }

                if (!context.mounted) {
                  return;
                }

                if (_stopwatch.isRunning) {
                  _stopTimer();
                }

                if (!_sessionSaved) {
                  final skillProvider = context.read<SkillProvider>();

                  try {
                    // create a new session record
                    final session = {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'skillId': widget.skill.id,
                      'duration': _stopwatch.elapsed.inSeconds,
                      'datePerformed': DateTime.now().toIso8601String(),
                    };

                    await skillProvider.addSession(session);
                    _sessionSaved = true;

                    if (context.mounted) {
                      CustomSnackBar.showSuccess(
                        context,
                        message: 'Session saved successfully!',
                      );
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      CustomSnackBar.showError(
                        context,
                        message: 'Failed to save session: $e',
                      );
                    }
                  }
                }
              },
            ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    unawaited(_setWakelockEnabled(false));
    super.dispose();
  }
}
