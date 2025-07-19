import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final List<double>? stops;
  final Alignment begin;
  final Alignment end;

  const GradientBackground({
    required this.child,
    this.colors,
    this.stops,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ?? [colorScheme.primary, colorScheme.surface],
          stops: stops ?? const [0.0, 0.3],
        ),
      ),
      child: child,
    );
  }
}

class ScaffoldWithGradient extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final Widget? endDrawer;

  const ScaffoldWithGradient({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.gradientColors,
    this.gradientStops,
    super.key,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: GradientBackground(
        colors: gradientColors,
        stops: gradientStops,
        child: body,
      ),
      endDrawer: endDrawer,
    );
  }
}

class TimerGradientBackground extends GradientBackground {
  const TimerGradientBackground({required super.child, super.key})
    : super(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.3],
      );
}

class SkillsGradientBackground extends GradientBackground {
  const SkillsGradientBackground({required super.child, super.key})
    : super(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.2],
      );
}

class HomeGradientBackground extends GradientBackground {
  const HomeGradientBackground({required super.child, super.key})
    : super(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.2],
      );
}

class SessionReportGradientBackground extends GradientBackground {
  const SessionReportGradientBackground({required super.child, super.key})
    : super(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.2],
      );
}
