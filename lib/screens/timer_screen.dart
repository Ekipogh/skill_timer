import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/models/skill.dart';
import 'package:skill_timer/providers/time_session_provider.dart';
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
  Future<void> _setWakelockEnabled(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } catch (e) {
      debugPrint('Failed to ${enabled ? 'enable' : 'disable'} wakelock: $e');
    }
  }

  Future<void> _startTimer() async {
    final timerProvider = context.read<TimerSessionProvider>();
    if (timerProvider.isRunning) {
      return;
    }

    unawaited(timerProvider.start(widget.skill));
    unawaited(_setWakelockEnabled(true));
  }

  void _stopTimer() {
    final timerProvider = context.read<TimerSessionProvider>();
    if (!timerProvider.isRunning) {
      return;
    }

    unawaited(timerProvider.pause());
    unawaited(_setWakelockEnabled(false));
  }

  Future<bool> _saveSession(TimerSessionProvider timerProvider) async {
    if (!timerProvider.canSave) {
      return false;
    }

    if (timerProvider.isRunning) {
      _stopTimer();
    }

    final skillProvider = context.read<SkillProvider>();

    try {
      await timerProvider.save(skillProvider);

      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Session saved successfully!',
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: 'Failed to save session: $e',
        );
      }
      return false;
    }
  }

  Future<void> _handleExit(TimerSessionProvider timerProvider) async {
    if (timerProvider.isRunning || !timerProvider.hasUnsavedSession) {
      unawaited(_setWakelockEnabled(false));
      if (context.mounted) {
        Navigator.pop(context);
      }
      return;
    }

    final result = await SaveDiscardCancelDialog.show(
      context,
      skillName: widget.skill.name,
      elapsedTime: TimeFormatter.formatWithMilliseconds(
        timerProvider.elapsedTime,
      ),
    );
    if (!context.mounted) {
      return;
    }

    switch (result) {
      case SaveDiscardCancelResult.save:
        final saved = await _saveSession(timerProvider);
        if (context.mounted && saved) {
          Navigator.pop(context, true);
        }
        return;
      case SaveDiscardCancelResult.discard:
        await timerProvider.discard();
        unawaited(_setWakelockEnabled(false));
        if (context.mounted) {
          Navigator.pop(context);
        }
        return;
      case SaveDiscardCancelResult.cancel:
      case null:
        return;
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
                  settings: const RouteSettings(name: '/manual_data_entry'),
                  builder: (context) =>
                      ManualDataEntryScreen(skill: widget.skill),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimerSessionProvider>(
        builder: (context, timerProvider, child) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) {
                return;
              }
              await _handleExit(timerProvider);
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
                        elapsedTime: timerProvider.elapsedTime,
                        isRunning: timerProvider.isRunning,
                        targetTime: timerProvider.targetTime.inSeconds > 0
                            ? timerProvider.targetTime
                            : null,
                      ),

                      const SizedBox(height: 10),

                      // Target time card
                      TargetTimeCard(
                        selectedTargetTime: timerProvider.targetTime.inMinutes,
                        onTargetTimeSelected: (selectedTime) {
                          timerProvider.setTargetTime(
                            Duration(minutes: selectedTime),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Control button
                      timerProvider.isRunning
                          ? PauseButton(
                              onPressed: () {
                                _stopTimer();
                              },
                            )
                          : StartButton(
                              onPressed: () async {
                                await _startTimer();
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
          );
        },
      ),
      floatingActionButton: !context.watch<TimerSessionProvider>().canSave
          ? null
          : SaveButton(
              onPressed: () async {
                final timerProvider = context.read<TimerSessionProvider>();
                final bool shouldSave = await SaveSessionDialog.show(
                  context,
                  skillName: widget.skill.name,
                  elapsedTime: TimeFormatter.formatWithMilliseconds(
                    timerProvider.elapsedTime,
                  ),
                );
                if (!shouldSave) {
                  return;
                }

                if (!context.mounted) {
                  return;
                }

                final saved = await _saveSession(timerProvider);
                if (context.mounted && saved) {
                  Navigator.pop(context, true);
                }
              },
            ),
    );
  }

  @override
  void dispose() {
    unawaited(_setWakelockEnabled(false));
    super.dispose();
  }
}
