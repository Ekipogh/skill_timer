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
      body: Consumer<TimerSessionProvider>(
        builder: (context, timerProvider, child) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) {
                return;
              }
              final bool isRunningOrNotSaved =
                  timerProvider.isRunning || timerProvider.hasUnsavedSession;
              if (isRunningOrNotSaved) {
                final bool shouldPop = await UnsavedChangesDialog.show(
                  context,
                  isTimerRunning: timerProvider.isRunning,
                );
                if (context.mounted && shouldPop) {
                  unawaited(_setWakelockEnabled(false));
                }

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
                if (!timerProvider.canSave) {
                  return; // Do nothing if no time has elapsed
                }

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
