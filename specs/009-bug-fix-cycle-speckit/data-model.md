# Data Model: Bug-Fix Cycle (Spec-Kit Mechanism)

Process/state conventions, not a schema this feature owns. Reuses `UAT-04`'s
Bug-Fix Cycle / High-Risk Bug / Restart-Failure Threshold / Per-Bug Retry Budget
entities (`specs/005-bug-fix-cycle-direct/data-model.md`) unmodified — this
feature adds two entities specific to the spec-kit mechanism.

## Spec-Kit Assessment

The output of `<bug-assess-command>` run against a finding.

| Field | Notes |
|---|---|
| trigger | `bug-fix-mechanism: spec-kit`, a BUG finding needs fixing (`FR-001`) |
| identifier | a slug, referenced by the subsequent `<bug-fix-command>`/`<bug-test-command>` calls (`FR-001`, `FR-002`) |
| artifact shape | whatever the configured tool actually produces — not required to match the direct mechanism's summary/proposed-fix/affected-files shape (`FR-004`) |
| review-pause presentation | presented as-is at the routine `REVIEW_BEFORE_FIX` pause, not reshaped (`FR-004`) |
| retry reuse | a retry reuses the existing slug rather than re-running `<bug-assess-command>` (`FR-008`) |

## Tool-Invocation Failure

A distinct failure mode where one of the three configured commands fails to
execute.

| Field | Notes |
|---|---|
| trigger | `<bug-assess-command>`, `<bug-fix-command>`, or `<bug-test-command>` fails to run (not found, non-zero exit, unparseable output) (`FR-011`) |
| consequence | run pauses to flag it explicitly — MUST NOT silently treat the bug as resolved or continue unattended (`FR-011`) |
| reporting | MUST be distinguished in the final report from a retry-budget-exhausted unresolved bug and from a restart-failure-threshold stop — three separate failure modes (`FR-012`) |

## Test/Retest Discrepancy

Not a standalone entity — a noted condition on the existing Bug-Fix Cycle.

| Field | Notes |
|---|---|
| trigger | `<bug-test-command>`'s result disagrees with the subsequent browser retest's result, in either direction (`FR-013`) |
| resolution | the browser retest is what closes the bug out, per the cycle's existing shared step — the discrepancy is noted as additional context in the commit/report, not treated as a blocking contradiction (`FR-013`) |
