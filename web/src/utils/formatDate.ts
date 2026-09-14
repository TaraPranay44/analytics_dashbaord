const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTHS = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
];

function parseIsoDate(isoDate: string): Date {
  return new Date(`${isoDate}T00:00:00`);
}

/** "2026-09-12" -> "Sat, 12 Sep 2026". Falls back to the raw string if unparseable. */
export function formatDateLabel(isoDate: string): string {
  const parsed = parseIsoDate(isoDate);
  if (Number.isNaN(parsed.getTime())) return isoDate;
  return `${WEEKDAYS[parsed.getDay()]}, ${String(parsed.getDate()).padStart(2, "0")} ${MONTHS[parsed.getMonth()]} ${parsed.getFullYear()}`;
}

/** "2026-09-12" -> "12 Sep", for compact chart axis labels. */
export function formatShortDate(isoDate: string): string {
  const parsed = parseIsoDate(isoDate);
  if (Number.isNaN(parsed.getTime())) return isoDate;
  return `${String(parsed.getDate()).padStart(2, "0")} ${MONTHS[parsed.getMonth()]}`;
}

/** "2026-03" -> "Mar 2026", for the lifetime trend chart's monthly axis labels. */
export function formatMonthLabel(yearMonth: string): string {
  const [yearStr, monthStr] = yearMonth.split("-");
  const monthIndex = Number(monthStr) - 1;
  if (!yearStr || Number.isNaN(monthIndex) || monthIndex < 0 || monthIndex > 11) return yearMonth;
  return `${MONTHS[monthIndex]} ${yearStr}`;
}
