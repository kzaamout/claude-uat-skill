# Quickstart: Validating the Bug-Fix Cycle (Direct Mechanism)

Manual validation runbook. `demo-app`'s three `DEMO_BUG_*` flags give this feature
real completion evidence — each toggles a genuine, fixable bug.

Each scenario maps to acceptance scenarios in [spec.md](./spec.md).

## Prerequisites

- `demo-app` running, `webapp-uat` configured against it, `bug-fix-mechanism: direct`
  (already the case per `config.md`).

## Scenario 1 — Single bug: stop, assess, fix, browser-retest, commit

→ validates User Story 1, all 6 acceptance scenarios

Enable `DEMO_BUG_SILENT_COMMENT_FAILURE`, run the comment-length scenario. Expect:
app stopped before any fix; in-session assessment produced (no external tool
invoked); fix made; existing test suite run if it covers the area, noted as
sole verification if not; app restarted; the exact scenario re-driven in Chrome;
one commit containing the fix + finding file.

## Scenario 2 — Multiple bugs from one scenario, one shared restart/retest

→ validates User Story 2, all 3 acceptance scenarios

Construct or simulate a scenario surfacing two BUG findings at once. Expect: both
assessed and fixed before any restart; exactly one restart and one browser retest
covering both; two separate commits.

## Scenario 3 — High-risk bug pauses regardless of flags

→ validates User Story 3, all 4 acceptance scenarios

Enable `DEMO_BUG_PERMISSION_BYPASS` (security/auth-adjacent), run with
`--silent --no-review-before-fix` together. Expect: the pause still happens before
any fix is attempted, despite both flags being set to skip routine review.

## Scenario 4 — Retry budget and restart-failure threshold

→ validates User Story 4, all 4 acceptance scenarios

Part A (retry budget): seed a bug whose first "fix" attempt deliberately doesn't
resolve it. Expect: 2 further diagnose/fix cycles attempted, then marked unresolved,
run continues with other scenarios.

Part B (restart-failure threshold): force two consecutive `wait-ready` timeouts
(e.g. temporarily break `scripts/dev.sh start`). Expect: the entire run stops,
distinctly reported from Part A's per-bug unresolved marking — not conflated under
one undivided "unresolved" bucket in the report.

## Done when

All 4 scenarios (13 acceptance criteria total) produce the expected outcome above.
Scenario 1 runs cleanly against `demo-app` as-is. Scenario 2 needs a constructed
multi-bug case (`demo-app`'s three bugs don't naturally co-occur in one scenario by
default). Scenario 3 uses `demo-app`'s permission-bypass bug directly. Scenario 4
needs deliberate interference (a non-fixing "fix," a broken start command) to force
both failure paths.
