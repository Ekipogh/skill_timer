import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';

class StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const StatBadge({
    required this.icon,
    required this.value,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class TimeBadge extends StatBadge {
  const TimeBadge({required String time, super.key})
    : super(icon: Icons.timer, value: time, color: Colors.green);
}

class SessionsBadge extends StatBadge {
  const SessionsBadge({required int sessions, super.key})
    : super(
        icon: Icons.analytics,
        value: '$sessions sessions',
        color: Colors.blue,
      );
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isCircular;
  final double? size;

  const ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isCircular = false,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isCircular) {
      return SizedBox(
        width: size ?? 160,
        height: size ?? 160,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor ?? Colors.white,
            shape: const CircleBorder(),
            elevation: 8,
            shadowColor: backgroundColor?.withValues(alpha: 0.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class StartButton extends ActionButton {
  const StartButton({required VoidCallback onPressed, super.key})
    : super(
        icon: Icons.play_arrow,
        label: 'Start',
        onPressed: onPressed,
        backgroundColor: Colors.green,
        isCircular: true,
      );
}

class PauseButton extends ActionButton {
  const PauseButton({required VoidCallback onPressed, super.key})
    : super(
        icon: Icons.pause,
        label: 'Pause',
        onPressed: onPressed,
        backgroundColor: Colors.red,
        isCircular: true,
      );
}

class SaveButton extends ActionButton {
  const SaveButton({required VoidCallback onPressed, super.key})
    : super(
        icon: Icons.save,
        label: 'Save Session',
        onPressed: onPressed,
        backgroundColor: Colors.blue,
      );
}

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: action,
        duration: duration,
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      backgroundColor: Colors.green,
      action: action,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      backgroundColor: Colors.red,
      action: action,
    );
  }

  static void showUndo(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
  }) {
    show(
      context,
      message: message,
      action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
    );
  }
}

class TimerDisplay extends StatelessWidget {
  final Duration elapsedTime;
  final bool isRunning;
  final Duration? targetTime;

  const TimerDisplay({
    required this.elapsedTime,
    required this.isRunning,
    this.targetTime,
    super.key,
  });

  bool get _targetMet {
    if (targetTime == null) return false;
    return elapsedTime >= targetTime!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Session Time',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isRunning ? 56 : 48,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
            child: Text(TimeFormatter.formatWithMilliseconds(elapsedTime)),
          ),
          if (targetTime != null) ...[
            const SizedBox(height: 8),
            Text(
              TimeString.format(targetTime!.inSeconds),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _targetMet
                    ? Colors.green
                    : colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _targetMet
                      ? Colors.green
                      : (isRunning ? Colors.green : Colors.grey),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isRunning ? 'Running' : 'Stopped',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final List<StatItem> stats;

  const StatsCard({required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              Expanded(child: stats[i]),
              if (i < stats.length - 1)
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, color: iconColor ?? colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class TimeFormatter {
  static String format(int seconds) {
    return Formatters.formatDuration(seconds);
  }

  static String formatWithMilliseconds(Duration duration) {
    final elapsed = duration;
    return '${elapsed.inHours.toString().padLeft(2, '0')}:'
        '${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}'
        '.${(elapsed.inMilliseconds % 1000).toString().padLeft(3, '0')}';
  }
}

class TimeString {
  static String format(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }
}

class TargetTimeCard extends StatelessWidget {
  final ValueChanged<int> onTargetTimeSelected;
  final int? selectedTargetTime;
  static const List<int> _targetTimeOptions = [
    15,
    30,
    60,
    120,
    300,
  ]; // in minutes

  const TargetTimeCard({
    required this.onTargetTimeSelected,
    this.selectedTargetTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _targetTimeOptions.map((option) {
            final isSelected = selectedTargetTime == option;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTargetTimeSelected(option),
                borderRadius: BorderRadius.circular(8),
                splashColor: colorScheme.primary.withValues(alpha: 0.16),
                highlightColor: colorScheme.primary.withValues(alpha: 0.08),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                        ) ??
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                    child: Text('${option}m'),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class PeriodMetric extends StatelessWidget {
  const PeriodMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const _analyticsChartColors = <Color>[
  Color(0xFFF9413A),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFF5E35B1),
  Color(0xFF2D9CDB),
];

class PieChartCard extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  const PieChartCard({required this.title, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : 320.0;
            final isCompact = maxWidth < 320;
            final chart = SizedBox(
              height: isCompact ? 180 : 240,
              width: maxWidth,
              child: PieChart(_buildChartData(maxWidth)),
            );
            final legend = _PieChartLegend(data: data);
            final useSideBySideLayout = maxWidth >= 480;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                if (useSideBySideLayout)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: chart),
                      const SizedBox(width: 16),
                      Flexible(child: legend),
                    ],
                  )
                else ...[
                  chart,
                  const SizedBox(height: 16),
                  legend,
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  PieChartData _buildChartData(double width) {
    final centerSpaceRadius = width < 320 ? 46.0 : 64.0;
    final sectionRadius = width < 320 ? 34.0 : 48.0;

    return PieChartData(
      centerSpaceRadius: centerSpaceRadius,
      sectionsSpace: 3,
      sections: data.entries.map((entry) {
        final index = data.keys.toList().indexOf(entry.key);
        final color =
            _analyticsChartColors[index % _analyticsChartColors.length];
        return PieChartSectionData(
          value: entry.value.toDouble(),
          title: '',
          color: color,
          radius: sectionRadius,
        );
      }).toList(),
    );
  }
}

class _PieChartLegend extends StatelessWidget {
  final Map<String, int> data;

  const _PieChartLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 320.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            final color =
                _analyticsChartColors[index % _analyticsChartColors.length];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                width: maxWidth,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.key}: ${Formatters.formatDurationFromSeconds(entry.value)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: maxWidth < 320 ? 12 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class BarChartCard extends StatelessWidget {
  final String title;
  final Map<String, int> data;

  const BarChartCard({required this.title, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxSeconds = data.values.fold<int>(
      0,
      (currentMax, value) => value > currentMax ? value : currentMax,
    );
    final maxHours = maxSeconds / 3600;
    final maxY = maxHours <= 1 ? 1.0 : maxHours * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: entries.isEmpty
                  ? const Center(child: Text('No category data'))
                  : BarChart(
                      BarChartData(
                        maxY: maxY,
                        minY: 0,
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxY / 4,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withValues(alpha: 0.24),
                            strokeWidth: 1,
                          ),
                        ),
                        barGroups: entries.map((entry) {
                          final index = entries.indexOf(entry);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value / 3600,
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                                color: _analyticsChartColors[
                                    index % _analyticsChartColors.length],
                              ),
                            ],
                          );
                        }).toList(),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.32),
                            ),
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.32),
                            ),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 34,
                              interval: maxY / 4,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) {
                                  return const Text(
                                    '0h',
                                    style: TextStyle(fontSize: 10),
                                  );
                                }
                                return Text(
                                  '${value.toStringAsFixed(value < 10 ? 1 : 0)}h',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= entries.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SizedBox(
                                    width: 52,
                                    child: Text(
                                      _shortLabel(entries[index].key),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortLabel(String label) {
    if (label.length <= 9) return label;
    return '${label.substring(0, 8)}...';
  }
}
