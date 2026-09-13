"""Shared pagination helper enforcing PAGE_SIZE_MAX across all list endpoints.

See docs/04_BACKEND_RULES.md §9/§7.
"""

from typing import Any

from analytics_portal.constants.api_constants import PAGE_SIZE_MAX


def paginate(query: Any, start: int, limit: int) -> Any:
	"""Apply offset/limit to a query, capping limit at PAGE_SIZE_MAX.

	Args:
	    query: a frappe.qb query builder object to paginate.
	    start: zero-based row offset to start from.
	    limit: requested page size; capped at PAGE_SIZE_MAX.

	Returns:
	    The same query object with limit/offset applied.
	"""
	capped_limit = min(limit, PAGE_SIZE_MAX)
	return query.limit(capped_limit).offset(start)
