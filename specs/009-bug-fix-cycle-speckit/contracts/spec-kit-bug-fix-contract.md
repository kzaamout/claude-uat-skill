# Contract: Spec-kit bug-fix mechanism

The process contract for how a BUG finding moves through the configured
assess/fix/test commands — not a network API. Assumes `UAT-04`'s shared cycle
structure (`contracts/fix-cycle-contract.md` §1, §4, §5, §6 batching/restart/
retry/commit rules) already applies identically; this contract covers only what
differs for `bug-fix-mechanism: spec-kit`.

## 1. Assessment

**Trigger**: `bug-fix-mechanism: spec-kit`, one or more BUG findings from a
single scenario, pre-fix gate cleared per the shared cycle's §1.

**MUST**: run `<bug-assess-command>` against the finding file, producing a slug
(`FR-001`).

## 2. Pause gate (spec-kit-specific presentation)

**Trigger**: assessment complete for one bug.

**MUST**: if the assessed scope touches security/auth/data-deletion/
architecture, pause unconditionally — no flag skips this, identical to the
shared cycle's rule (`FR-003`). **MUST**: otherwise, if `REVIEW_BEFORE_FIX` is
on, pause and present `<bug-assess-command>`'s own resulting artifact as-is —
MUST NOT require or assume it matches the direct mechanism's specific
summary/proposed-fix/affected-files shape (`FR-004`). This pause MAY be skipped
under `--silent`; the high-risk pause never is (`FR-005`).

## 3. Fix & test

**Trigger**: pause gate cleared (or not applicable).

**MUST**: run `<bug-fix-command>` with the assessment's slug, then
`<bug-test-command>` with the same slug, in that order (`FR-002`).

**Trigger**: `<bug-test-command>`'s result disagrees with the subsequent browser
retest's result.

**MUST**: note the discrepancy as additional context in the commit/report —
MUST NOT let it override the browser retest as the mechanism that closes the
bug out (`FR-013`).

## 4. Retry (spec-kit-specific: slug reuse)

**Trigger**: a bug's browser retest fails after a spec-kit fix attempt.

**MUST**: reuse the existing assessment slug for the retry — MUST NOT re-run
`<bug-assess-command>` for the same, unchanged finding (`FR-008`). **MUST**:
re-apply §2's pause gates in full on each retry cycle, identical to the shared
cycle's rule — no carried-forward approval (`FR-009`).

## 5. Commit (spec-kit-specific: tool records included)

**Trigger**: browser retest passes for a given bug.

**MUST**: include the bug-workflow tool's own records in that bug's commit,
alongside the fix and finding file (`FR-007`).

## 6. Tool-invocation failure

**Trigger**: `<bug-assess-command>`, `<bug-fix-command>`, or
`<bug-test-command>` fails to execute — not found, non-zero exit, or output
this skill can't parse into what the next step needs.

**MUST**: report this explicitly as a tool-invocation failure, distinct from
the bug being genuinely unfixable (`FR-011`). **MUST**: pause the run to flag
it — MUST NOT silently treat the bug as resolved or continue as if nothing
happened (`FR-011`). **MUST NOT**: skip this pause under `--silent` — identical
in this respect to the restart-failure threshold (`FR-011`). **MUST**: in the
final report, distinguish this from a retry-budget-exhausted unresolved bug and
from a restart-failure-threshold stop — three separate failure modes, never
conflated (`FR-012`).
