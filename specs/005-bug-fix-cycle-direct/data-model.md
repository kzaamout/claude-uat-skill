# Data Model: Bug-Fix Cycle (Direct Mechanism)

Process/state conventions, not a schema this feature owns.

## Bug-Fix Cycle

One pass through stop → assess → (optional pause) → fix → test → restart →
browser-retest → per-bug-commit, scoped to a single scenario's batch of BUG findings.

| Field | Notes |
|---|---|
| trigger | one or more BUG findings from a single scenario (`FR-001`) |
| mechanism | `direct` — in-session assessment, no external bug-workflow tool (`FR-002`) |
| batching | every bug from the scenario is assessed+fixed before one shared restart/retest (`FR-008`) |
| verification | browser retest of the exact original scenario steps — required; automated test alone is insufficient (`FR-009`) |
| commit granularity | one commit per bug, even when restart/retest was shared (`FR-010`) |

## High-Risk Bug

A BUG finding whose *assessed* scope (not its surface category) touches security,
authentication, data deletion/migration, or broad architectural impact.

| Field | Notes |
|---|---|
| trigger | determined during in-session assessment, not from the finding's original classification alone (`FR-003`, Edge Case 1) |
| pause behavior | unconditional — no flag skips it (`FR-003`, `FR-005`) |
| distinct from | the routine review pause, which follows `REVIEW_BEFORE_FIX`/`--silent` (`FR-004`) |

## Restart-Failure Threshold

A counter, independent of any individual bug's retry budget, tracking consecutive
failed app restarts.

| Field | Notes |
|---|---|
| trigger | 2 consecutive `wait-ready` timeouts, each following a stop + fresh start (`FR-012`) |
| consequence | stops the entire run, flags the app unstable (`FR-012`) |
| reporting | MUST be distinguished in the final report from a per-bug unresolved marking (`FR-013`) — the one genuinely new piece this feature adds |

## Per-Bug Retry Budget

| Field | Notes |
|---|---|
| trigger | a bug's browser retest fails after a fix attempt (`FR-011`) |
| budget | up to 2 further diagnose/fix cycles for that specific bug (3 total attempts) |
| exhausted | bug marked unresolved; run continues with independent scenarios (`FR-011`) |
| reporting | MUST be distinguished in the final report from a restart-failure-threshold stop (`FR-013`) |
