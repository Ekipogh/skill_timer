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
          bottom: 16,
          left: 16,
          child: Card(
            color: Colors.blueAccent.withAlpha(200),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timer.currentSkill?.name ?? "No Skill",
                    style: const TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                  Text(
                    TimeFormatter.formatWithMilliseconds(timer.elapsedTime),
                    style: const TextStyle(fontSize: 24.0, color: Colors.white),
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
