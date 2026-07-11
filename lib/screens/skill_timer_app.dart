import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/providers/current_route_observer.dart';
import 'package:skill_timer/screens/homescreen.dart';
import 'package:skill_timer/widgets/floating_timer.dart';
import 'package:skill_timer/providers/skill_category_provider.dart';
import 'package:skill_timer/providers/time_session_provider.dart';
import 'package:skill_timer/utils/constants.dart';
import 'package:skill_timer/providers/foreground_timer_service.dart';
import 'package:skill_timer/theme/app_theme.dart';

class SkillTimerApp extends StatefulWidget {
  const SkillTimerApp({super.key});
  @override
  State<SkillTimerApp> createState() => _SkillTimerAppState();
}

class _SkillTimerAppState extends State<SkillTimerApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForegroundTimerService.init();
      ForegroundTimerService.requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeObserver = CurrentRouteObserver();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SkillProvider()),
        ChangeNotifierProvider(create: (context) => TimerSessionProvider()),
        ChangeNotifierProvider(create: (context) => routeObserver),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        title: AppConstants.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        builder: (context, child) {
          return Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const FloatingTimer(key: Key('floating_timer')),
            ],
          );
        },
        home: HomeScreen(key: const Key('home_screen')),
      ),
    );
  }
}
