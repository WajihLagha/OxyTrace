class DateFormatter {
  static String toDisplay(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String toDisplayWithTime(DateTime date) =>
      '${toDisplay(date)} à ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
}
