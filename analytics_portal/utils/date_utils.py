"""Date-range resolution helpers.

See docs/04_BACKEND_RULES.md §9.
"""

from datetime import date


def resolve_date_range(from_date: str | None, to_date: str | None) -> tuple[date, date]:
	"""Resolve optional request-supplied date strings into a concrete range.

	Args:
	    from_date: ISO date string from the request, or None to default.
	    to_date: ISO date string from the request, or None to default.

	Returns:
	    A (from_date, to_date) tuple of concrete `date` objects.
	"""
	raise NotImplementedError
