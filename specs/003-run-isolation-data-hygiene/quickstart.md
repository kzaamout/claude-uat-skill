# Quickstart: Validating Run Isolation & Data Hygiene

Manual validation runbook, same rationale as the prior two features'
`quickstart.md`. **Lighter live-execution dependency than `UAT-02`**: these
guarantees are mostly about whether a confirmation prompt appears, what a decline
does, and whether an identifier follows a naming pattern — not about live browser
behavior. A minimal target project with *some* seed-data mechanism (even a trivial
one) is enough; a full `demo-app/`-style app is not required the way `UAT-02`
needed one for accessibility/browser checks.

Each scenario maps to acceptance scenarios in [spec.md](./spec.md).

## Prerequisites

- A target project with `webapp-uat` configured (`UAT-01`'s output) and some seed
  data mechanism discoverable (per Phase 0.5).
- Ability to interrupt a run deliberately (kill it after data creation, before its
  own end-of-run cleanup).

## Scenario 1 — Collision-resistant naming

→ validates User Story 1, all 3 acceptance scenarios

Trigger seed-data creation (via a `generate` run or a scenario needing a seeded
account). Expect: the resulting identifier follows `uat-{run-id}-<descriptor>`.
Run it twice with the same descriptor (e.g. "admin"); expect two distinct
identifiers, differing only by run-id.

## Scenario 2 — Self-healing start-of-run purge, confirmed, no-op when empty

→ validates User Story 2, Acceptance Scenarios 1, 2, 4

Interrupt a run after it creates UAT-marked data but before its own end-of-run
cleanup. Start a fresh run. Expect: the leftover data is found, an explicit
confirmation is shown before it's purged. Then run again with no leftover data:
expect the step to complete silently, no confirmation shown.

## Scenario 3 — Declining start-of-run purge blocks the run

→ validates User Story 2, Acceptance Scenario 3 (the clarified behavior)

Repeat Scenario 2's interrupted-run setup; decline the confirmation when shown.
Expect: the run does not proceed — blocked, not continuing with stale data present.

## Scenario 4 — End-of-run purge gated on report completion

→ validates User Story 3, Acceptance Scenarios 1, 2

Run a scenario to completion. Expect: the final report is written first; only then
is the end-of-run purge proposed, with its own explicit confirmation.

## Scenario 5 — Declining end-of-run purge does not block completion

→ validates User Story 3, Acceptance Scenario 3 (the clarified behavior)

Repeat Scenario 4; decline the end-of-run confirmation. Expect: the run is still
considered complete (report exists); the declined data becomes visible again as
Scenario 2's leftover-data case on the *next* run.

## Scenario 6 — Unresolved bugs don't block end-of-run cleanup

→ validates User Story 3, Acceptance Scenario 4

Run a scenario that produces an unresolved `BUG` finding. Expect: end-of-run cleanup
still runs (and is still confirmed) regardless.

## Scenario 7 — Generation-time seed data gets its own distinct confirmation

→ validates User Story 4, Acceptance Scenario 1

Run `/webapp-uat generate` against a project where the resulting plan needs new
seed data beyond static fixtures. Expect: a confirmation for that data creation
specifically, separate from the general plan approve/adjust/cancel decision.

## Scenario 8 — `--silent` never skips any of the three confirmations

→ validates User Story 4, Acceptance Scenario 2

Repeat Scenarios 2, 4, and 7 under `--silent`. Expect: all three confirmations still
appear and still require an explicit response.

## Scenario 9 — No runtime way to reduce or skip these confirmations

→ validates User Story 4, Acceptance Scenario 3

Text-only check (no live execution needed): confirm neither `SKILL.md` nor
`USAGE.md` nor `config.md.example` exposes any flag or setting that would suppress
any of the three confirmations — the only way to change this is a manual edit to
`SKILL.md` itself.

## Done when

All 9 scenarios produce the expected outcome above. Scenarios 1-8 need a live
target project with a seed-data mechanism; Scenario 9 is text-only and can be
confirmed immediately.
