# Quickstart: Validating Backend Verification

Manual validation runbook, same rationale as the prior features' `quickstart.md`.
`demo-app` is genuinely well-suited to this feature specifically — it has both an
API-covered path (documents) and a direct-DB-only path (comments, deliberately
POST-only), plus a seeded bug (`DEMO_BUG_SILENT_COMMENT_FAILURE`) built exactly to
exercise Story 1.

Each scenario maps to acceptance scenarios in [spec.md](./spec.md).

## Prerequisites

- `demo-app` running (`UAT-12`), `webapp-uat` configured against it (`UAT-01`), Phase
  0.5 discovery already run so its backend-verification path is recorded.

## Scenario 1 — A false UI success is caught (the core case)

→ validates User Story 1, Acceptance Scenarios 1, 4

Enable `DEMO_BUG_SILENT_COMMENT_FAILURE`, then write a scenario (or copy `UAT-002`)
that posts a 1001–2000-character comment — none of the six bundled `demo-app`
scenarios (`UAT-001`..`UAT-006`) does; see `demo-app/README.md` §7 — and run it. The
UI shows a success toast; the DB column limit
silently rejects the insert. Expect: the finding surfaces this as a discrepancy —
UI claimed success, backend shows no change — not silently trusted from the UI alone.

## Scenario 2 — API path preferred when available

→ validates User Story 1, Acceptance Scenario 2

Run a scenario whose outcome is a new/changed document (API-covered per discovery).
Expect: verification goes through the app's own API, not a direct DB query, for this
outcome.

## Scenario 3 — Direct-store fallback when the API doesn't cover it

→ validates User Story 1, Acceptance Scenario 3

Run a scenario whose outcome is a new comment (deliberately POST-only, no GET
endpoint). Expect: verification falls back to a direct DB read since discovery found
no API coverage for reading comments.

## Scenario 4 — Backend verification is a read, no DB-write confirmation shown

→ validates User Story 1, Acceptance Scenario 5

Observe either of Scenarios 2-3. Expect: no DB-write confirmation prompt appears for
the verification step itself — that gate is for writes this skill performs (seeding,
cleanup), not for reading the app's own already-written data.

## Scenario 5 — Multi-store outcome discloses single-store scope

→ validates User Story 1, Acceptance Scenario 6

Point discovery at a (real or simulated) project where a scenario's outcome
plausibly spans two stores. Expect: verification checks the single primary store
recorded by discovery, and the finding does not claim full coverage across both —
the single-store scope is stated explicitly, not silently implied as complete.

## Scenario 6 — Graceful UI-only degradation

→ validates User Story 2, Acceptance Scenario 1

Temporarily point `config.md`/discovery at a state where neither API coverage nor a
data store is recorded (or test against a project genuinely lacking both). Run a
scenario whose outcome names backend data. Expect: the finding notes "verified via UI
only" — no error, no blocked run.

## Scenario 7 — No verification attempted when nothing is claimed

→ validates User Story 2, Acceptance Scenario 2

Run a scenario whose Expected Outcome names no backend data change at all (e.g. a
pure navigation/display scenario). Expect: no backend verification step is attempted
or reported for it.

## Scenario 8 — Verification failure classified as test-environment, not app defect

→ validates User Story 3, both acceptance scenarios

Simulate a verification-connection failure (e.g. temporarily block the DB port
webapp-uat's verification step uses, while leaving the app itself and its own DB
connection untouched). Expect: the finding is classified as a test-environment
problem, explicitly distinguished from a data-persistence bug in the app itself, with
a note explaining the verification attempt failed and why.

## Done when

All 8 scenarios produce the expected outcome above. Scenarios 1-4 and 7 run cleanly
against `demo-app` as-is. Scenarios 5 and 6 need a temporary discovery-state
override or a second test project (multi-store and backend-opaque, respectively —
`demo-app` itself has neither by default). Scenario 8 needs a deliberately broken
verification connection, distinct from breaking the app itself.

**Live-verification record (2026-08-16, commit 50cbe5c)**: commit 50cbe5c ("Findings
from live-verifying UAT-02/05/06 against demo-app") names `UAT-05` among the slices
exercised in a live run against `demo-app` (built the same day, D6). Its body
records two gaps — `SKILL.md` Phase 2 step 3's guidance for a server-side boundary
check blocked by client-side validation (added), and the `Skill` tool loading the
outer repo's copy when invoked above a nested project (D8) — neither in this
slice's scope, plus the statement that the run "confirmed the rest of
UAT-02/UAT-06's behavior holds." It records no UAT-05-specific or
scenario-by-scenario result, so no scenario above is marked live-verified on its
strength.
