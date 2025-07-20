/// Utility class containing common formatting functions used throughout the app.
/// These functions provide consistent formatting for dates, durations, and other data.
abstract class Formatters {

  /// Formats a DateTime to a readable date string in DD/MM/YYYY format.
  ///
  /// Example: DateTime(2023, 12, 25) → "25/12/2023"
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formats a DateTime to a readable date string in DD/MM/YYYY format (US style).
  ///
  /// Example: DateTime(2023, 12, 25) → "12/25/2023"
  static String formatDateUS(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formats a DateTime to a more readable format.
  ///
  /// Example: DateTime(2023, 12, 25) → "December 25, 2023"
  static String formatDateLong(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a DateTime to show only month and year.
  ///
  /// Example: DateTime(2023, 12, 25) → "December 2023"
  static String formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Formats a duration in seconds to a human-readable string.
  ///
  /// Examples:
  /// - 45 seconds → "45s"
  /// - 90 seconds → "1m 30s"
  /// - 3665 seconds → "1h 1m"
  /// - 7200 seconds → "2h"
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0
          ? '${minutes}m ${remainingSeconds}s'
          : '${minutes}m';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  /// Formats a duration in seconds to a longer, more descriptive format.
  ///
  /// Examples:
  /// - 45 seconds → "45 seconds"
  /// - 90 seconds → "1 minute 30 seconds"
  /// - 3665 seconds → "1 hour 1 minute"
  /// - 7200 seconds → "2 hours"
  static String formatDurationLong(int seconds) {
    if (seconds < 60) {
      return seconds == 1 ? '1 second' : '$seconds seconds';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      final minuteText = minutes == 1 ? '1 minute' : '$minutes minutes';
      if (remainingSeconds > 0) {
        final secondText = remainingSeconds == 1 ? '1 second' : '$remainingSeconds seconds';
        return '$minuteText $secondText';
      }
      return minuteText;
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final hourText = hours == 1 ? '1 hour' : '$hours hours';
      if (minutes > 0) {
        final minuteText = minutes == 1 ? '1 minute' : '$minutes minutes';
        return '$hourText $minuteText';
      }
      return hourText;
    }
  }

  /// Formats a duration in milliseconds to a human-readable string.
  ///
  /// Example: 90000 milliseconds → "1m 30s"
  static String formatDurationFromMilliseconds(int milliseconds) {
    return formatDuration(milliseconds ~/ 1000);
  }

  /// Formats a DateTime to show time in HH:MM format.
  ///
  /// Example: DateTime(2023, 12, 25, 14, 30) → "14:30"
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formats a DateTime to show time in 12-hour format with AM/PM.
  ///
  /// Example: DateTime(2023, 12, 25, 14, 30) → "2:30 PM"
  static String formatTime12Hour(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    if (hour == 0) {
      return '12:$minute AM';
    } else if (hour < 12) {
      return '$hour:$minute AM';
    } else if (hour == 12) {
      return '12:$minute PM';
    } else {
      return '${hour - 12}:$minute PM';
    }
  }

  /// Formats a DateTime to show both date and time.
  ///
  /// Example: DateTime(2023, 12, 25, 14, 30) → "25/12/2023 14:30"
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Formats a percentage as a string with specified decimal places.
  ///
  /// Example: formatPercentage(0.1234, 1) → "12.3%"
  static String formatPercentage(double value, [int decimalPlaces = 1]) {
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }

  /// Formats a number to include thousand separators.
  ///
  /// Example: formatNumber(1234567) → "1,234,567"
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  /// Formats bytes to human-readable format.
  ///
  /// Example: formatBytes(1536) → "1.5 KB"
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Returns a relative time string (e.g., "2 hours ago", "yesterday").
  ///
  /// Example: formatRelativeTime(DateTime.now().subtract(Duration(hours: 2))) → "2 hours ago"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'Yesterday' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Capitalizes the first letter of a string.
  ///
  /// Example: capitalize("hello world") → "Hello world"
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Formats a string to title case.
  ///
  /// Example: toTitleCase("hello world") → "Hello World"
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isEmpty ? word : capitalize(word))
        .join(' ');
  }
}
