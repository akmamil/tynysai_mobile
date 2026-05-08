class DateFormatter {
  DateFormatter._();

  /// '2024-01-15T10:30:00' → 'Jan 15, 2024'
  static String formatDate(String? isoString) {
    if (isoString == null) return '—';
    try {
      final dt = DateTime.parse(isoString);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return isoString;
    }
  }

  /// '2024-01-15T10:30:00' → 'Jan 15, 2024 10:30'
  static String formatDateTime(String? isoString) {
    if (isoString == null) return '—';
    try {
      final dt = DateTime.parse(isoString);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month]} ${dt.day}, ${dt.year} $h:$m';
    } catch (_) {
      return isoString;
    }
  }
}