# Data Model: Run Isolation & Data Hygiene

Files/DB-record conventions, not a schema this feature owns — it defines a naming
and lifecycle *contract* over whatever storage the target project actually uses.

## UAT-Marked Record

Any seeded user, seeded row, or DB-tracked synthesized fixture this skill creates.

| Field | Notes |
|---|---|
| identifier | `uat-{run-id}-<descriptor>` (spec `FR-001`) — e.g. `uat-2026-08-13-1430-admin@test.local` |
| run-id | `YYYY-MM-DD-HHmm`, the same format `UAT-02`'s Test Plan entity uses — one run-id ties a record to exactly one run |
| descriptor | free-form, human-readable (e.g. `admin@test.local`) — the part that would collide across runs without the `uat-{run-id}-` prefix |

**Validation rule**: every record this skill creates in a target project's data
store MUST carry this identifier shape — no fixed/reused identifier is valid for
this purpose (`FR-001`).

## Start-of-Run Purge

The confirmed database write that removes UAT-marked records left over from an
interrupted prior run.

| Field | Notes |
|---|---|
| trigger | every run, before Phase 0 completes |
| confirmation | explicit, every time, `--silent` or not (`FR-003`) |
| no-op case | nothing to purge → completes silently, no confirmation prompt shown (`FR-004`) |
| decline consequence | **blocks the run** — stale data during execution is a real risk (`FR-011`) |

## End-of-Run Purge

The confirmed database write that removes the current run's own UAT-marked records.

| Field | Notes |
|---|---|
| trigger | only after the final report is written (`FR-005`) |
| confirmation | explicit, every time, `--silent` or not (`FR-006`) |
| runs regardless of | unresolved bugs (`FR-007`) — finding files are the source of truth, not live data |
| decline consequence | **does not block completion** — self-healing recovers it next run (`FR-011`) |

## Seed-Data Creation (Generation mode)

Not a new entity — the same `UAT-Marked Record` shape, created at generation time
rather than cleaned up. Documented here only for its confirmation contract.

| Field | Notes |
|---|---|
| confirmation | explicit, distinct from the general plan approve/adjust/cancel decision (`FR-008`) |
| skip conditions | none — never skipped by `--silent` or any flag (`FR-009`) |
