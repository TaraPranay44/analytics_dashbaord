"""All DB access for the `Employee Activity Log` DocType.

This is the 11M+ row table — every query here must be paginated and must use
the `(employee, date)` composite index. See docs/04_BACKEND_RULES.md §7.
"""

from datetime import date
from typing import Any


def get_employee_logs_page(
	employee_id: str,
	from_date: date | None,
	to_date: date | None,
	start: int,
	limit: int,
) -> list[dict[str, Any]]:
	"""Fetch one page of `Employee Activity Log` rows for an employee.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    from_date: inclusive lower bound on `date`, or None for no lower bound.
	    to_date: inclusive upper bound on `date`, or None for no upper bound.
	    start: zero-based row offset.
	    limit: max rows to return; caller has already capped this at PAGE_SIZE_MAX.

	Returns:
	    A list of activity log row dicts, ordered by `date` descending.
	"""
	raise NotImplementedError


def count_employee_logs(
	employee_id: str,
	from_date: date | None,
	to_date: date | None,
) -> int:
	"""Count `Employee Activity Log` rows matching the same filter as the page query.

	Used to derive `has_more` for the paginated response envelope.

	Args:
	    employee_id: the `Employee.employee_id` value.
	    from_date: inclusive lower bound on `date`, or None for no lower bound.
	    to_date: inclusive upper bound on `date`, or None for no upper bound.

	Returns:
	    Total matching row count.
	"""
	raise NotImplementedError
