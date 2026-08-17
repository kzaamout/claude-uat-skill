# Contract: Bug-fix cycle sequencing & reporting

The process contract for how a bug moves from finding to committed fix — not a
network API.

## 1. Pre-fix gate

**Trigger**: one or more BUG findings from a single scenario.

**MUST**: stop the app before any fix is attempted (`FR-001`). **MUST**: assess
in-session under `bug-fix-mechanism: direct`, producing root cause, proposed fix, and
affected files (`FR-002`).

## 2. Pause gate

**Trigger**: assessment complete for one bug.

**MUST**: if the assessed scope touches security/auth/data-deletion/architecture,
pause unconditionally — no flag skips this (`FR-003`, `FR-005`). **MUST**: otherwise,
if `REVIEW_BEFORE_FIX` is on, pause and offer proceed/adjust/skip — this pause MAY be
skipped under `--silent` (`FR-004`, `FR-005`).

## 3. Fix & test

**Trigger**: pause gate cleared (or not applicable).

**MUST**: fix directly in the codebase. **MUST**: run the project's existing test
suite scoped to the affected area, if one exists (`FR-006`). **MUST**: if none
exists, note that the browser retest is this fix's only verification (`FR-007`).

## 4. Shared restart & retest

**Trigger**: every bug from the scenario's batch has been fixed.

**MUST**: restart exactly once per batch, not once per bug (`FR-008`). **MUST**:
perform exactly one browser retest, re-driving the exact original scenario steps —
an automated test result alone MUST NOT be treated as sufficient (`FR-009`).

## 5. Commit

**Trigger**: browser retest passes for a given bug.

**MUST**: commit that bug separately — its fix, any regression test, its finding
file — even though the restart/retest was shared with other bugs (`FR-010`).

## 6. Retry & abort thresholds

**Trigger**: a bug's browser retest fails, or a restart itself fails.

**MUST**: for a failed retest, attempt up to 2 further diagnose/fix cycles for that
specific bug, then mark it unresolved and continue with independent scenarios
(`FR-011`). **MUST**: each retry cycle re-applies §2's pause gates in full — no
carryover approval from a prior attempt (`FR-011a`). **MUST**: for 2 consecutive
restart failures, stop the entire run and flag the app unstable — this threshold is
independent of and tighter than any single bug's retry budget (`FR-012`).

## 7. Report distinction

**Trigger**: the final report is written.

**MUST**: report a restart-failure-threshold stop (§6) distinctly from a
retry-budget-exhausted unresolved bug (§6) — these are two different failure modes
and MUST NOT be conflated under one undivided "unresolved" label (`FR-013`).
