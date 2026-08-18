class CustomDateFormatter {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Formats a [DateTime] into a string like "MMM dd, yyyy"
  static String formatDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }
}
