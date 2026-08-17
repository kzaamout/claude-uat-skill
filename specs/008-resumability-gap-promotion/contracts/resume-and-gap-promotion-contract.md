# Contract: Resume decision & gap promotion

The process contract for detecting/continuing an interrupted run and for
promoting a review-noticed gap into a real scenario — not a network API.

## 1. Interrupted-run detection

**Trigger**: Phase 0 begins, before the app is started or the browser touched.

**MUST**: scan `uat/runs/` for a directory with `test-plan.md` but no
`final-report.md` (`FR-001`). **MUST**: when found, offer exactly resume /
abandon / start fresh (`FR-002`). **MUST**: when none found, proceed with no
resume-related prompt (`FR-003`). **MUST**: when multiple are found, act only on
the most recent by `run-id`, leaving others untouched — no auto-purge, no
auto-merge (`FR-004`).

## 2. Resume continuation

**Trigger**: "resume" is chosen.

**MUST**: reuse the existing `test-plan.md` as-is — MUST NOT regenerate or
re-review it (`FR-005`). **MUST**: skip re-executing any scenario that already
has a recorded result from before the interruption, carrying that result forward
into the final report unchanged (`FR-006`). **MUST**: execute every scenario with
no recorded result, in the plan's original order (`FR-007`). **MUST**: produce
one final report covering every scenario from the original plan — pre- and
post-interruption — as a single coherent document (`FR-008`).

**Trigger**: a resumed run's `test-plan.md` references a scenario file no longer
present on disk.

**MUST**: report that scenario as unable to resume/execute, explicitly — MUST NOT
silently omit it from the count or abort the entire resume over it (`FR-017`).

## 3. Fresh start

**Trigger**: "start fresh" is chosen.

**MUST**: begin under a new `run-id` and new directory. **MUST NOT**: modify or
delete the interrupted run's directory (`FR-009`).

## 4. `--silent` resume default

**Trigger**: an interrupted run is found and `--silent` is set.

**MUST**: default to abandon-and-start-fresh automatically, with no prompt
(`FR-010`). **MUST**: state this explicitly in the final report every time it
happens (`FR-011`).

**Trigger**: no interrupted run is found and `--silent` is set.

**MUST NOT**: mention resumability in the final report at all (`FR-012`).

## 5. Gap promotion during review

**Trigger**: Phase 1 review, reading through scenarios already under review,
notices a real coverage gap (a missing negative path, boundary condition, or
recovery scenario).

**MUST**: draft an actual scenario file for it immediately, using the standard
template (`FR-013`). **MUST**: tag it `Source: review-derived` (`FR-014`).
**MUST**: include it in the same approve/adjust/cancel decision as the rest of
the batch under review — MUST NOT require a separate approval step (`FR-015`).

**Trigger**: a scenario was just gap-promoted within the current review pass.

**MUST NOT**: re-review that newly-promoted scenario for further gaps within the
same pass — recursion is bounded to one promotion per originally-reviewed
scenario per pass (`FR-016`).
