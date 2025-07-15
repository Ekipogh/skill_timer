import 'package:flutter/material.dart';

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
  const TimeBadge({
    required String time,
    super.key,
  }) : super(
          icon: Icons.timer,
          value: time,
          color: Colors.green,
        );
}

class SessionsBadge extends StatBadge {
  const SessionsBadge({
    required int sessions,
    super.key,
  }) : super(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class StartButton extends ActionButton {
  const StartButton({
    required VoidCallback onPressed,
    super.key,
  }) : super(
          icon: Icons.play_arrow,
          label: 'Start',
          onPressed: onPressed,
          backgroundColor: Colors.green,
          isCircular: true,
        );
}

class PauseButton extends ActionButton {
  const PauseButton({
    required VoidCallback onPressed,
    super.key,
  }) : super(
          icon: Icons.pause,
          label: 'Pause',
          onPressed: onPressed,
          backgroundColor: Colors.red,
          isCircular: true,
        );
}

class SaveButton extends ActionButton {
  const SaveButton({
    required VoidCallback onPressed,
    super.key,
  }) : super(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: onUndo,
      ),
    );
  }
}

class TimerDisplay extends StatelessWidget {
  final String elapsedTime;
  final bool isRunning;

  const TimerDisplay({
    required this.elapsedTime,
    required this.isRunning,
    super.key,
  });

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
            child: Text(elapsedTime),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isRunning ? Colors.green : Colors.grey,
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

  const StatsCard({
    required this.stats,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
        Icon(
          icon,
          color: iconColor ?? colorScheme.primary,
          size: 24,
        ),
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
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  static String formatWithMilliseconds(Duration duration) {
    final elapsed = duration;
    return '${elapsed.inHours.toString().padLeft(2, '0')}:'
        '${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}'
        '.${(elapsed.inMilliseconds % 1000).toString().padLeft(3, '0')}';
  }
}
