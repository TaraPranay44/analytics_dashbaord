/** `avg_hours_overall`/`total_hours` (float) -> "7.4 hrs". */
export function formatHours(hours: number | null | undefined): string {
  if (hours === null || hours === undefined) return "—";
  return `${hours.toFixed(1)} hrs`;
}

/** A Frappe Time value ("HH:MM:SS" string) -> "9:02 AM". */
export function formatTimeOfDay(time: string | null | undefined): string {
  if (!time) return "—";
  const [hoursPart, minutesPart] = time.split(":");
  let hour = Number(hoursPart);
  const minute = Number(minutesPart ?? 0);
  if (Number.isNaN(hour) || Number.isNaN(minute)) return "—";

  const period = hour >= 12 ? "PM" : "AM";
  hour = hour % 12;
  if (hour === 0) hour = 12;
  return `${hour}:${String(minute).padStart(2, "0")} ${period}`;
}

/** A Frappe Datetime value ("YYYY-MM-DD HH:MM:SS") -> "9:02 AM". */
export function formatClockTime(datetimeValue: string | null | undefined): string {
  if (!datetimeValue) return "—";
  const parsed = new Date(datetimeValue.replace(" ", "T"));
  if (Number.isNaN(parsed.getTime())) return "—";
  return parsed.toLocaleTimeString(undefined, { hour: "numeric", minute: "2-digit" });
}
