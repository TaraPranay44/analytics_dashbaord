"""Time-of-day averaging helpers for the nightly aggregation jobs.

Frappe's `Time` fieldtype round-trips as `datetime.time` on a loaded `Document`
but as `datetime.timedelta` when read via `frappe.get_all`/`frappe.db.sql`
(confirmed empirically against this bench's DB driver - MariaDB returns a
native TIME column as a duration, not a time-of-day). These helpers accept
either so callers don't need to care which one they have.

Averaging is a plain arithmetic mean of seconds-since-midnight; shifts that
wrap past midnight are not handled (not a scenario in this app's data model).
See docs/04_BACKEND_RULES.md §8.
"""

from collections.abc import Iterable
from datetime import time, timedelta

_SECONDS_PER_DAY = 24 * 60 * 60


def _to_seconds(value: time | timedelta) -> float:
	"""Convert a `datetime.time` or `datetime.timedelta` to seconds-since-midnight.

	Args:
	    value: the time-like value to convert.

	Returns:
	    Seconds since midnight as a float.
	"""
	if isinstance(value, timedelta):
		return value.total_seconds()
	return value.hour * 3600 + value.minute * 60 + value.second + value.microsecond / 1_000_000


def _seconds_to_time(seconds: float) -> time:
	"""Convert seconds-since-midnight (wrapped to a 24h day) to a `datetime.time`.

	Args:
	    seconds: seconds since midnight, may exceed 86400 or be negative.

	Returns:
	    The equivalent `datetime.time`, wrapped into a single day.
	"""
	wrapped_seconds = round(seconds) % _SECONDS_PER_DAY
	hour, remainder = divmod(wrapped_seconds, 3600)
	minute, second = divmod(remainder, 60)
	return time(hour=hour, minute=minute, second=second)


def average_time_of_day(values: Iterable[time | timedelta]) -> time | None:
	"""Return the arithmetic mean time-of-day across `values`.

	Args:
	    values: `datetime.time`/`datetime.timedelta` values to average.

	Returns:
	    The mean as a `datetime.time`, or None if `values` is empty.
	"""
	seconds = [_to_seconds(value) for value in values]
	if not seconds:
		return None
	return _seconds_to_time(sum(seconds) / len(seconds))


def weighted_average(pairs: Iterable[tuple[float, int]]) -> float:
	"""Return the weighted mean of (value, weight) pairs.

	Args:
	    pairs: iterable of (value, weight) tuples, e.g. (avg_hours, days_present).

	Returns:
	    The weighted mean, or 0.0 if `pairs` is empty or every weight is 0.
	"""
	total_weight = 0
	weighted_sum = 0.0
	for value, weight in pairs:
		total_weight += weight
		weighted_sum += value * weight
	return weighted_sum / total_weight if total_weight else 0.0


def weighted_average_time_of_day(pairs: Iterable[tuple[time | timedelta, int]]) -> time | None:
	"""Return the weighted mean time-of-day across (value, weight) pairs.

	Args:
	    pairs: iterable of (`time`/`timedelta`, weight) tuples, e.g.
	        (avg_login_time, days_present) per month.

	Returns:
	    The weighted mean as a `datetime.time`, or None if `pairs` is empty or
	    every weight is 0.
	"""
	total_weight = 0
	weighted_seconds = 0.0
	for value, weight in pairs:
		total_weight += weight
		weighted_seconds += _to_seconds(value) * weight
	if not total_weight:
		return None
	return _seconds_to_time(weighted_seconds / total_weight)
