"""Seed script for the Phase 1 demo dataset described in docs/03_PHASED_ROADMAP.md:
30,000 `Employee` records with ~365 `Employee Activity Log` rows each (1 year).

Not a scheduled job, not a patch - a one-off, re-runnable-from-scratch data
generator invoked manually, e.g.:

    bench --site <site> execute analytics_portal.seed.generate_demo_data.run
    bench --site <site> execute analytics_portal.seed.generate_demo_data.run \
        --kwargs '{"employee_count": 50, "days": 5}'

Uses `frappe.db.bulk_insert` instead of `frappe.get_doc().insert()` - at
30,000 employees x 365 days (~11M activity log rows), per-document ORM/hook
overhead would make this impractically slow. Bypassing the ORM means this
script is responsible for everything the controllers normally guarantee:
- `Employee.manager` must never form a cycle (enforced by construction below:
  every employee's manager is chosen from employees already generated)
- `Employee Activity Log.total_hours` must be computed the same way
  `EmployeeActivityLog.compute_total_hours` does, since `before_save` never
  runs for a bulk insert

Data is generated and committed in batches (`batch_size` employees + that
many x `days` log rows per batch), not as one all-or-nothing transaction at
the very end - at 30,000 employees this means the first batch is visible
(and browsable on the site) within well under a minute, instead of only
after the entire ~11M-row run finishes, and killing the process partway
through only loses the in-flight batch rather than everything generated
so far.
"""

import random
from collections.abc import Iterator
from datetime import date, datetime, timedelta
from typing import Any

import frappe
from frappe.utils import add_days, getdate, now_datetime, nowdate

FIRST_NAMES = [
    "Aarav", "Vivaan", "Aditya", "Ishaan", "Arjun", "Kabir", "Rohan", "Sai",
    "Priya", "Ananya", "Diya", "Isha", "Meera", "Neha", "Riya", "Tara",
    "Liam", "Noah", "Oliver", "Ethan", "Mason", "Lucas", "James", "Benjamin",
    "Olivia", "Emma", "Ava", "Sophia", "Isabella", "Mia", "Charlotte", "Amelia",
]  # fmt: skip

LAST_NAMES = [
    "Sharma", "Verma", "Gupta", "Iyer", "Nair", "Reddy", "Rao", "Kapoor",
    "Mehta", "Joshi", "Patel", "Singh", "Kumar", "Das", "Bose", "Chatterjee",
    "Smith", "Johnson", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor",
]  # fmt: skip

EMPLOYEE_FIELDS = [
    "name", "owner", "creation", "modified", "modified_by", "docstatus", "idx",
    "employee_name", "employee_id", "manager", "date_of_joining", "user",
]  # fmt: skip

ACTIVITY_LOG_FIELDS = [
    "name", "owner", "creation", "modified", "modified_by", "docstatus", "idx",
    "employee", "date", "login_time", "logout_time", "total_hours",
]  # fmt: skip

TOP_LEVEL_MANAGER_PROBABILITY = 1 / 50
LOGOUT_MISSING_PROBABILITY = 0.03
LOGIN_HOUR_MEAN = 9.0
LOGIN_HOUR_JITTER = 0.75
WORK_HOURS_MIN = 6.5
WORK_HOURS_MAX = 9.5


def run(
	employee_count: int = 30_000,
	days: int = 365,
	commit: bool = True,
	id_prefix: str = "EMP-",
	batch_size: int = 1000,
) -> None:
	"""Generate `employee_count` employees and `days` days of activity logs each.

	Args:
	    employee_count: how many `Employee` records to create.
	    days: how many calendar days of `Employee Activity Log` rows to create
	        per employee, counting back from yesterday.
	    commit: whether to `frappe.db.commit()` after each batch. Leave this
	        True for a real `bench execute` run (a bulk insert is otherwise
	        silently lost when the process exits without an explicit commit).
	        Tests pass `commit=False` so the generated rows stay inside the
	        test's own transaction and roll back with everything else at
	        class teardown.
	    id_prefix: prefix for generated employee_id values. Tests should pass a
	        distinct prefix (e.g. "TEST-SEED-EMP-") so a small test run can never
	        collide with real seeded data using the default prefix.
	    batch_size: how many employees (and that many x `days` activity log
	        rows) to generate and commit per batch, so progress is visible -
	        and durable - incrementally rather than only at the very end.
	"""
	started_at = now_datetime()
	print(f"[seed] generating {employee_count} employees x {days} days of logs, in batches of {batch_size}")

	employee_ids: list[str] = []
	total_log_count = 0

	for batch_start in range(0, employee_count, batch_size):
		batch_end = min(batch_start + batch_size, employee_count)
		new_ids = _generate_employee_batch(employee_ids, batch_start, batch_end, id_prefix)
		employee_ids.extend(new_ids)

		total_log_count += _generate_activity_logs(new_ids, days)

		if commit:
			frappe.db.commit()

		elapsed = (now_datetime() - started_at).total_seconds()
		print(
			f"[seed] batch done: {len(employee_ids)}/{employee_count} employees, "
			f"{total_log_count} logs so far ({elapsed:.1f}s elapsed)"
		)

	elapsed = (now_datetime() - started_at).total_seconds()
	print(f"[seed] done in {elapsed:.1f}s")


def _generate_employee_batch(
	existing_ids: list[str], batch_start: int, batch_end: int, id_prefix: str
) -> list[str]:
	"""Bulk-insert Employee rows for the index range [batch_start, batch_end).

	Args:
	    existing_ids: employee_ids already generated (and committed) in
	        earlier batches - `len(existing_ids)` must equal `batch_start`.
	    batch_start: global index of the first employee in this batch.
	    batch_end: global index one past the last employee in this batch.
	    id_prefix: prefix for generated employee_id values.

	Returns:
	    The employee_id/name values generated in this batch, in order.
	"""
	now_str = str(now_datetime())
	new_ids: list[str] = []

	def pick_manager(i: int) -> str | None:
		if i == 0 or random.random() <= TOP_LEVEL_MANAGER_PROBABILITY:
			return None
		j = random.randint(0, i - 1)
		return existing_ids[j] if j < batch_start else new_ids[j - batch_start]

	def rows() -> Iterator[tuple[Any, ...]]:
		for i in range(batch_start, batch_end):
			employee_id = f"{id_prefix}{i:06d}"
			manager = pick_manager(i)
			new_ids.append(employee_id)

			employee_name = f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
			date_of_joining = add_days(nowdate(), -random.randint(30, 6 * 365))

			yield (
				employee_id,
				"Administrator",
				now_str,
				now_str,
				"Administrator",
				0,
				0,
				employee_name,
				employee_id,
				manager,
				date_of_joining,
				None,
			)

	frappe.db.bulk_insert("Employee", EMPLOYEE_FIELDS, rows(), chunk_size=2000)
	return new_ids


def _generate_activity_logs(employee_ids: list[str], days: int) -> int:
	"""Bulk-insert `days` `Employee Activity Log` rows for each employee.

	Returns:
	    Total number of rows inserted.
	"""
	today = getdate(nowdate())
	total = len(employee_ids) * days

	def rows() -> Iterator[tuple[Any, ...]]:
		for employee_id in employee_ids:
			for day_offset in range(days):
				log_date: date = getdate(add_days(today, -1 - day_offset))
				login_time, logout_time, total_hours = _generate_shift(
					log_date, is_most_recent_day=(day_offset == 0)
				)
				creation = str(login_time)
				name = f"{employee_id}~{log_date.isoformat()}"

				yield (
					name,
					"Administrator",
					creation,
					creation,
					"Administrator",
					0,
					0,
					employee_id,
					log_date,
					login_time,
					logout_time,
					total_hours,
				)

	frappe.db.bulk_insert("Employee Activity Log", ACTIVITY_LOG_FIELDS, rows(), chunk_size=5000)
	return total


def _generate_shift(log_date: date, is_most_recent_day: bool) -> tuple[datetime, datetime | None, float]:
	"""Generate a plausible (login_time, logout_time, total_hours) for one day.

	Mirrors `EmployeeActivityLog.compute_total_hours` since `before_save` never
	runs for a bulk-inserted row.
	"""
	login_offset_hours = random.gauss(LOGIN_HOUR_MEAN, LOGIN_HOUR_JITTER)
	login_time = datetime.combine(log_date, datetime.min.time()) + timedelta(
		hours=max(0.0, login_offset_hours)
	)

	if is_most_recent_day and random.random() < LOGOUT_MISSING_PROBABILITY:
		return login_time, None, 0.0

	hours_worked = random.uniform(WORK_HOURS_MIN, WORK_HOURS_MAX)
	logout_time = login_time + timedelta(hours=hours_worked)
	total_hours = round((logout_time - login_time).total_seconds() / 3600, 2)
	return login_time, logout_time, total_hours
