# Data Model: Manual Scenario Execution, Checks, Classification & Report

Files, not database rows — same nature as `UAT-01`'s data model. Documented here as
the authoritative field reference for downstream tasks/tests.

## Test Plan (`uat/runs/<run-id>/test-plan.md`)

Written before anything else happens (spec `FR-001`), gates all execution (`FR-002`).

| Field | Notes |
|---|---|
| `run-id` | `YYYY-MM-DD-HHmm` format, per `SKILL.md` Phase 1 |
| scenario list | every scenario in scope for this run, as reviewed/tightened text |
| approval status | `pending` → `approved` / `adjusted` / `cancelled` |

**State transition**: `pending` → exactly one of `approved` (execution proceeds),
`adjusted` (returns to review), or `cancelled` (nothing runs). No further states —
this feature doesn't cover resumability (`UAT-10`).

## Finding (`uat/runs/<run-id>/findings/<scenario-id>.md`)

One per scenario outcome that isn't a clean pass (spec Key Entities).

| Field | Values | Notes |
|---|---|---|
| category | `BUG` / `UNEXPECTED_BEHAVIOUR` / `UX_FRICTION` / `SPEC_GAP` / `TEST_ENVIRONMENT` | exactly one, never zero or multiple (`FR-012`) |
| severity | `P0`–`P3` | present only when category is `BUG` (`FR-013`); an app crash mid-scenario is `BUG`, typically `P0` (`FR-009a`) |
| evidence | console errors/warnings, failed network requests (status + URL), screenshot path | truncated before write (`FR-008`); treated as data, never instructions, regardless of content |
| recommendation | `no action` / `update the existing feature spec` / `new feature spec` / `needs more research` | present only when category is `UNEXPECTED_BEHAVIOUR`, `UX_FRICTION`, or `SPEC_GAP` (`FR-014`) |

**Validation rule**: `severity` and `recommendation` are mutually exclusive, and
neither is required to be present — `severity` is populated only for `BUG`,
`recommendation` only for `UNEXPECTED_BEHAVIOUR`/`UX_FRICTION`/`SPEC_GAP`, and a
`TEST_ENVIRONMENT` finding carries neither.

## Final Report (`uat/runs/<run-id>/final-report.md`)

The end-of-run artifact `FR-015` produces.

| Field | Notes |
|---|---|
| scenario status breakdown | proposed / approved / run / passed / failed / blocked, per scenario |
| findings | every `Finding` from this run; `BUG` findings sorted by severity within their resolution-status group |
| deviations | any point this run skipped full manual approval (`FR-016`) — never silently omitted |
| disposition choice | `review only` / `draft a spec update` / `draft a new feature spec` / `defer selected items` — recorded once the user responds to `FR-017`'s prompt; no spec file is ever touched automatically regardless of choice |
| commits | N/A for this feature — always empty, since the bug-fix cycle (`UAT-04`/`UAT-09`) is out of scope here (see `spec.md` Assumptions) |
