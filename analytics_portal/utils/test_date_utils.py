# Copyright (c) 2026, EMPLOYEE ANALYTICS PORTAL and Contributors
# See license.txt

from datetime import date, timedelta

from frappe.tests import IntegrationTestCase
from frappe.utils import getdate, nowdate

from analytics_portal.utils.date_utils import resolve_date_range


class TestDateUtils(IntegrationTestCase):
	"""Tests for docs/04_BACKEND_RULES.md §9 - `utils.date_utils.resolve_date_range`."""

	def test_both_bounds_given_are_used_as_is(self) -> None:
		result = resolve_date_range("2026-01-01", "2026-01-31")
		self.assertEqual(result, (date(2026, 1, 1), date(2026, 1, 31)))

	def test_both_missing_defaults_to_trailing_30_days_ending_today(self) -> None:
		from_date, to_date = resolve_date_range(None, None)
		self.assertEqual(to_date, getdate(nowdate()))
		self.assertEqual((to_date - from_date).days, 29)

	def test_only_to_date_given_defaults_from_date_relative_to_it(self) -> None:
		from_date, to_date = resolve_date_range(None, "2026-06-30")
		self.assertEqual(to_date, date(2026, 6, 30))
		self.assertEqual(from_date, date(2026, 6, 30) - timedelta(days=29))

	def test_only_from_date_given_defaults_to_date_to_today(self) -> None:
		from_date, to_date = resolve_date_range("2026-06-01", None)
		self.assertEqual(from_date, date(2026, 6, 1))
		self.assertEqual(to_date, getdate(nowdate()))
