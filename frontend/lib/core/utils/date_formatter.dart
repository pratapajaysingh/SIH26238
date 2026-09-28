/// DateFormatter provides centralized, timezone-safe date and time formatting
/// conforming to the project date presentation standards.
class DateFormatter {
  DateFormatter._();

  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Formats a DateTime as "12 Dec 2025".
  /// Returns '-' if [dateTime] is null.
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = _monthsShort[local.month - 1];
    final year = local.year.toString();
    return '$day $month $year';
  }

  /// Formats a DateTime as "12 Dec 2025, 10:15 AM".
  /// Returns '-' if [dateTime] is null.
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final local = dateTime.toLocal();
    final datePart = formatDate(local);
    final timePart = formatTime(local);
    return '$datePart, $timePart';
  }

  /// Formats a DateTime time as "10:15 AM" or "04:30 PM".
  /// Returns '-' if [dateTime] is null.
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final local = dateTime.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final hourString = displayHour.toString().padLeft(2, '0');
    return '$hourString:$minute $period';
  }

  /// Safely parses an ISO-8601 string or returns null.
  static DateTime? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
