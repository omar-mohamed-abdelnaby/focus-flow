import 'package:intl/intl.dart';

/// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  /// Format date as "MMM dd, yyyy" (e.g., "Oct 19, 2026")
  String toFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Format time as "hh:mm a" (e.g., "02:30 PM")
  String toFormattedTime() {
    return DateFormat('hh:mm a').format(this);
  }

  /// Format date and time as "MMM dd, yyyy hh:mm a"
  String toFormattedDateTime() {
    return DateFormat('MMM dd, yyyy hh:mm a').format(this);
  }

  /// Format as relative time (e.g., "2 hours ago", "in 3 days")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      // Future date
      final futureDiff = difference.abs();
      if (futureDiff.inDays > 365) {
        final years = (futureDiff.inDays / 365).floor();
        return 'in ${years} ${years == 1 ? 'year' : 'years'}';
      } else if (futureDiff.inDays > 30) {
        final months = (futureDiff.inDays / 30).floor();
        return 'in $months ${months == 1 ? 'month' : 'months'}';
      } else if (futureDiff.inDays > 0) {
        return 'in ${futureDiff.inDays} ${futureDiff.inDays == 1 ? 'day' : 'days'}';
      } else if (futureDiff.inHours > 0) {
        return 'in ${futureDiff.inHours} ${futureDiff.inHours == 1 ? 'hour' : 'hours'}';
      } else if (futureDiff.inMinutes > 0) {
        return 'in ${futureDiff.inMinutes} ${futureDiff.inMinutes == 1 ? 'minute' : 'minutes'}';
      } else {
        return 'in a few seconds';
      }
    }

    // Past date
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years} ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Get day of week name (e.g., "Monday")
  String get dayOfWeekName {
    return DateFormat('EEEE').format(this);
  }

  /// Get short day of week name (e.g., "Mon")
  String get shortDayOfWeekName {
    return DateFormat('EEE').format(this);
  }

  /// Get month name (e.g., "October")
  String get monthName {
    return DateFormat('MMMM').format(this);
  }

  /// Get short month name (e.g., "Oct")
  String get shortMonthName {
    return DateFormat('MMM').format(this);
  }

  /// Check if date is same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Get number of days until this date
  int daysUntil() {
    final now = DateTime.now();
    return startOfDay.difference(now.startOfDay).inDays;
  }

  /// Get number of days since this date
  int daysSince() {
    final now = DateTime.now();
    return now.startOfDay.difference(startOfDay).inDays;
  }

  /// Copy with new values
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
