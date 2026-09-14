/// Pure formatting helpers shared across features - mirrors
/// web/src/utils/formatDate.ts + formatDuration.ts exactly, so the mobile and
/// web clients render the same values the same way.
library;

const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

DateTime? _parseIsoDate(String isoDate) => DateTime.tryParse(isoDate);

/// "2026-09-12" -> "Sat, 12 Sep 2026". Falls back to the raw string if unparseable.
String formatDateLabel(String isoDate) {
  final parsed = _parseIsoDate(isoDate);
  if (parsed == null) return isoDate;
  final day = parsed.day.toString().padLeft(2, '0');
  return '${_weekdays[parsed.weekday % 7]}, $day ${_months[parsed.month - 1]} ${parsed.year}';
}

/// "2026-09-12" -> "12 Sep", for compact chart axis labels.
String formatShortDate(String isoDate) {
  final parsed = _parseIsoDate(isoDate);
  if (parsed == null) return isoDate;
  final day = parsed.day.toString().padLeft(2, '0');
  return '$day ${_months[parsed.month - 1]}';
}

/// "2026-03" -> "Mar 2026", for the lifetime trend chart's monthly axis labels.
String formatMonthLabel(String yearMonth) {
  final parts = yearMonth.split('-');
  if (parts.length != 2) return yearMonth;
  final monthIndex = int.tryParse(parts[1]);
  if (monthIndex == null || monthIndex < 1 || monthIndex > 12) return yearMonth;
  return '${_months[monthIndex - 1]} ${parts[0]}';
}

/// `avg_hours_overall`/`total_hours` (double) -> "7.4 hrs".
String formatHours(double? hours) {
  if (hours == null) return '—';
  return '${hours.toStringAsFixed(1)} hrs';
}

/// A Frappe Time value ("HH:MM:SS" string) -> "9:02 AM".
String formatTimeOfDay(String? time) {
  if (time == null || time.isEmpty) return '—';
  final parts = time.split(':');
  final hourRaw = int.tryParse(parts.isNotEmpty ? parts[0] : '');
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  if (hourRaw == null) return '—';

  final period = hourRaw >= 12 ? 'PM' : 'AM';
  var hour = hourRaw % 12;
  if (hour == 0) hour = 12;
  return '$hour:${minute.toString().padLeft(2, '0')} $period';
}

/// A Frappe Datetime value ("YYYY-MM-DD HH:MM:SS") -> "9:02 AM".
String formatClockTime(String? datetimeValue) {
  if (datetimeValue == null || datetimeValue.isEmpty) return '—';
  final parsed = DateTime.tryParse(datetimeValue.replaceFirst(' ', 'T'));
  if (parsed == null) return '—';
  final period = parsed.hour >= 12 ? 'PM' : 'AM';
  var hour = parsed.hour % 12;
  if (hour == 0) hour = 12;
  return '$hour:${parsed.minute.toString().padLeft(2, '0')} $period';
}
