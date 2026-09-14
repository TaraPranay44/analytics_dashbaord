"""Business logic for the org-wide dashboard and org hierarchy views.

Plain Python, no `frappe.whitelist()` here. See docs/04_BACKEND_RULES.md §1.
"""

from datetime import date
from typing import Any

from frappe.utils import add_days, getdate, nowdate

from analytics_portal.constants.api_constants import (
	HEADCOUNT_GROWTH_WINDOW_DAYS,
	HEADCOUNT_TREND_MONTHS,
	LOW_HOURS_MARGIN_HOURS,
	ORG_DASHBOARD_HISTORY_DAYS,
	RECENT_HIRES_WINDOW_DAYS,
)
from analytics_portal.constants.cache_keys import org_dashboard_key
from analytics_portal.repositories import employee_repo, stats_repo
from analytics_portal.utils.cache_utils import get_or_set
from analytics_portal.utils.validators import assert_employee_exists


def get_org_dashboard() -> dict[str, Any]:
	"""Org-wide tiles for the landing dashboard, cached per `cache_keys.org_dashboard_key`.

	Sourced from the most recent `Org Daily Stats` row plus a trailing
	`ORG_DASHBOARD_HISTORY_DAYS`-day history of the same table (for
	sparklines/trend badges) - never computed by scanning raw activity logs.
	`history` is bounded/embedded, not a primary list result - see
	docs/04_BACKEND_RULES.md §5's pagination exception note.

	Returns:
	    Dashboard tile fields: `date`, `total_employees`, `avg_hours_org`,
	    `avg_login_time_org`, `history` (daily, `ORG_DASHBOARD_HISTORY_DAYS`
	    days - for the hours/login-time sparklines), `headcount_trend`
	    (monthly, `HEADCOUNT_TREND_MONTHS` months - real registered headcount
	    growth, for the "employees tracked" sparkline; daily granularity
	    isn't useful there since headcount barely moves day to day at this
	    org's size) - all empty/0/None if no stats have been computed yet.
	"""

	def _compute() -> dict[str, Any]:
		latest = stats_repo.get_latest_org_daily_stats()
		history = stats_repo.get_recent_org_daily_stats(ORG_DASHBOARD_HISTORY_DAYS)
		headcount_trend = _compute_headcount_trend()
		if not latest:
			return {
				"date": None,
				"total_employees": 0,
				"avg_hours_org": 0.0,
				"avg_login_time_org": None,
				"history": history,
				"headcount_trend": headcount_trend,
			}
		return {
			"date": latest.date,
			"total_employees": latest.total_employees,
			"avg_hours_org": latest.avg_hours_org,
			"avg_login_time_org": latest.avg_login_time_org,
			"history": history,
			"headcount_trend": headcount_trend,
		}

	return get_or_set(org_dashboard_key(), None, _compute)


def _compute_headcount_trend() -> list[dict[str, Any]]:
	"""Registered headcount as of the 1st of each of the last `HEADCOUNT_TREND_MONTHS` months.

	Monthly, not daily, because at 30k+ employees the headcount barely moves
	day to day - a real trend only shows up at month granularity.
	"""
	today = getdate(nowdate())
	trend = []
	for offset in range(HEADCOUNT_TREND_MONTHS - 1, -1, -1):
		month_index = today.month - 1 - offset
		year = today.year + month_index // 12
		month = month_index % 12 + 1
		cutoff = date(year, month, 1)
		trend.append(
			{
				"year_month": cutoff.strftime("%Y-%m"),
				"cumulative_headcount": employee_repo.count_employees_registered_by(cutoff),
			}
		)
	return trend


def get_org_insights() -> dict[str, Any]:
	"""Supplementary real-data callouts for the dashboard's insight chips.

	Not cached (a handful of cheap, already-indexed count queries - nowhere
	near `employee_list`/`org_dashboard`'s read volume, so the caching
	contract in docs/04_BACKEND_RULES.md §6 doesn't apply here).

	Returns:
	    `manager_count`, `total_registered_employees`,
	    `total_registered_employees_growth_window_start` (headcount as of
	    `HEADCOUNT_GROWTH_WINDOW_DAYS` ago, for a real growth %),
	    `headcount_growth_window_days`, `low_hours_threshold`,
	    `low_hours_employee_count`, `recent_hires_count`, `recent_hires_window_days`.
	"""
	latest = stats_repo.get_latest_org_daily_stats()
	avg_hours_org = latest.avg_hours_org if latest else 0.0
	low_hours_threshold = round(avg_hours_org - LOW_HOURS_MARGIN_HOURS, 2) if avg_hours_org else 0.0
	growth_window_start = add_days(nowdate(), -HEADCOUNT_GROWTH_WINDOW_DAYS)

	return {
		"manager_count": employee_repo.count_distinct_managers(),
		"total_registered_employees": employee_repo.count_all_employees(),
		"total_registered_employees_growth_window_start": employee_repo.count_employees_registered_by(
			growth_window_start
		),
		"headcount_growth_window_days": HEADCOUNT_GROWTH_WINDOW_DAYS,
		"low_hours_threshold": low_hours_threshold,
		"low_hours_employee_count": (
			stats_repo.count_employees_below_hours(low_hours_threshold) if avg_hours_org else 0
		),
		"recent_hires_count": employee_repo.count_employees_joined_within_days(RECENT_HIRES_WINDOW_DAYS),
		"recent_hires_window_days": RECENT_HIRES_WINDOW_DAYS,
	}


def get_org_hierarchy(employee_id: str) -> dict[str, Any]:
	"""Manager chain and direct reports for one employee.

	Validates the employee exists first (raises `frappe.DoesNotExistError` if not).

	Args:
	    employee_id: the `Employee.employee_id` value.

	Returns:
	    `{"manager_chain": [...], "direct_reports": [...]}`.
	"""
	assert_employee_exists(employee_id)
	return {
		"manager_chain": employee_repo.get_manager_chain(employee_id),
		"direct_reports": employee_repo.get_direct_reports(employee_id),
	}
