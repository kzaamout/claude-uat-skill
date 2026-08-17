# Quickstart: Validating Resumability & In-Run Gap Promotion

Manual validation runbook. `demo-app` supports both scenarios directly — it has
enough scenarios to interrupt mid-run, and its document-creation flow (real zod
validation) is a good candidate for review to notice a genuine boundary-case gap.

Each scenario maps to acceptance scenarios in [spec.md](./spec.md).

## Prerequisites

- `demo-app` running, `webapp-uat` configured against it.
- At least 3 scenarios under `uat/scenarios/` so a mid-run interruption has both
  completed and not-yet-reached scenarios to distinguish.

## Scenario 1 — An interrupted run is detected, offered three ways forward

→ validates User Story 1, all 3 acceptance scenarios

Start a `webapp-uat` run; once `test-plan.md` is written and at least one
scenario has completed, kill the session before `final-report.md` is written.
Invoke `webapp-uat` again. Expect: the interruption is detected in Phase 0,
before the app starts or the browser is touched; the prompt offers exactly
resume / abandon / start fresh. Re-run once a prior run completed cleanly
(`final-report.md` exists) — confirm no resume prompt appears.

## Scenario 2 — Resuming continues the run, doesn't restart it

→ validates User Story 2, all 4 acceptance scenarios

From Scenario 1's interrupted state, choose **resume**. Expect: `test-plan.md` is
reused as-is, no regeneration/re-review; the already-completed scenario(s) are
not re-executed, their prior recorded result carries into the final output
unchanged; remaining scenarios execute normally in original order; the final
report covers the full original set as one document, not two partial ones.

## Scenario 3 — `--silent` defaults safely to abandon, and says so

→ validates User Story 3, all 3 acceptance scenarios

From an interrupted state, invoke `webapp-uat --silent uat/scenarios/`. Expect:
no prompt — it auto-abandons and starts fresh; the final report explicitly states
an interrupted prior run was found and abandoned automatically. Re-run
`--silent` with no interrupted run present — confirm the final report says
nothing about resumability.

## Scenario 4 — A review-noticed gap becomes a real, approvable scenario

→ validates User Story 4, all 4 acceptance scenarios

Run Phase 1 review against a batch including `demo-app`'s document-creation
scenario, deliberately without a boundary-case scenario for the title/body
length limits present. Expect: review notices the gap and drafts an actual
scenario file immediately (not just a note), tagged `Source: review-derived`;
it's included in the same approve/adjust/cancel decision as the rest of the
batch. Re-run review against a batch with no evident gap — confirm no
review-derived scenario is drafted (not a mandatory quota).

## Done when

All 4 scenarios (14 acceptance criteria total) produce the expected outcome
above. All four are fully live-verifiable against `demo-app` — Scenario 1/2/3
need a deliberately interrupted session (killing the CLI mid-run), which is
straightforward to construct; Scenario 4 needs a review pass against a
deliberately gap-containing scenario batch, also straightforward to construct
using `demo-app`'s real validation rules.
