"""Add the `(employee, year_month)` composite index required on `Employee Monthly Stats`.

See docs/04_BACKEND_RULES.md §4.3.
"""

import frappe


def execute() -> None:
	"""Create the composite index directly via SQL, with every column backtick-quoted.

	`frappe.db.add_index` builds its `ALTER TABLE ... ADD INDEX (...)` column list
	without backticks around each field, which breaks here because `year_month` is
	a reserved MariaDB/MySQL keyword (used in `INTERVAL ... YEAR_MONTH` expressions)
	- passing it unquoted to `add_index` raises a SQL syntax error. Quoting each
	column ourselves avoids the problem without renaming the documented field.
	"""
	frappe.db.sql(
		"""ALTER TABLE `tabEmployee Monthly Stats`
        ADD INDEX IF NOT EXISTS `employee_year_month_index` (`employee`, `year_month`)"""
	)
