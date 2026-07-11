import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/providers/current_route_observer.dart';
import 'package:skill_timer/providers/time_session_provider.dart';
import 'package:skill_timer/widgets/common_ui_elements.dart';

class FloatingTimer extends StatefulWidget {
  const FloatingTimer({super.key});

  @override
  State<FloatingTimer> createState() => _FloatingTimerState();
}

class _FloatingTimerState extends State<FloatingTimer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimerSessionProvider>(
      builder: (context, timer, child) {
        final route = context.read<CurrentRouteObserver>().currentRoute;
        final isOnTimerScreen = route.startsWith('/timer/');
        if (!timer.isRunning || isOnTimerScreen) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 20,
          left: 20,
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timer.currentSkill?.name ?? "No Skill",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    TimeFormatter.formatWithMilliseconds(timer.elapsedTime),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
