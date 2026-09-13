"""Date-range resolution helpers.

See docs/04_BACKEND_RULES.md §9.
"""

from datetime import date, timedelta

from frappe.utils import getdate, nowdate

_DEFAULT_RANGE_DAYS = 30


def resolve_date_range(from_date: str | None, to_date: str | None) -> tuple[date, date]:
	"""Resolve optional request-supplied date strings into a concrete range.

	Missing bounds default to a trailing `_DEFAULT_RANGE_DAYS`-day window ending
	today (or ending `to_date`, if only `from_date` is missing).

	Args:
	    from_date: ISO date string from the request, or None to default.
	    to_date: ISO date string from the request, or None to default.

	Returns:
	    A (from_date, to_date) tuple of concrete `date` objects.
	"""
	resolved_to = getdate(to_date) if to_date else getdate(nowdate())
	resolved_from = getdate(from_date) if from_date else resolved_to - timedelta(days=_DEFAULT_RANGE_DAYS - 1)
	return resolved_from, resolved_to
