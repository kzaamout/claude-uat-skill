# Readiness Checklist: Bug-Fix Cycle (Direct Mechanism)

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-16
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Reviewer
**Focus**: completeness/clarity of the retry-cycle mechanics and the one genuinely
new behavior (FR-013's distinct-failure-mode reporting).

## Requirement Completeness

- [ ] CHK001 Is there a requirement for how "the project's existing test suite" (FR-006) is discovered, given Phase 0.5's documented discovery categories (routing, locale, test-data, backend verification) don't currently include a test-suite category? [Completeness, Gap]
- [ ] CHK002 Are requirements defined for a bug that reappears in a later run after being marked resolved in a prior one (a regression)? [Completeness, Gap]
- [x] CHK003 Is it specified whether the pause gates (FR-003/FR-004) re-trigger on each of FR-011's retry cycles, or only on the first attempt? [Completeness, Gap] — fixed: added FR-011a, and US4 AC1 now states this explicitly (safety-relevant gap, resolved rather than deferred to `/speckit-analyze`).

## Requirement Clarity

- [ ] CHK004 Is "scoped to the affected area" (FR-006) given a concrete definition (a test file/directory mapping), or left to interpretation per bug? [Clarity, Spec §FR-006]
- [ ] CHK005 Is "broad architectural impact" (FR-003) given any further definition beyond the Assumptions section's acknowledgment that it stays a judgment call? [Clarity, Spec Assumptions]

## Requirement Consistency

- [x] CHK006 Does `data-model.md`'s "Restart-Failure Threshold" and "Per-Bug Retry Budget" reporting language match `contracts/fix-cycle-contract.md` §7 exactly? [Consistency, Spec §FR-013] — verified during `/speckit-analyze`: both consistently express the same MUST-distinguish/MUST-NOT-conflate requirement.
- [x] CHK007 Does the spec's Edge Cases section's "assessed scope, not surface classification" rule for the high-risk trigger match FR-003's wording? [Consistency, Spec §FR-003] — verified: both state the trigger is the assessment's determination, not the finding's original category.

## Acceptance Criteria Quality

- [ ] CHK008 Is SC-003's "100% of runs" falsifiable by a small number of live runs, or does validating it require exhausting every flag combination? [Measurability, Spec §SC-003]
- [x] CHK009 Is SC-002's "exactly one restart and one browser retest covering all N" testable with a concrete N=2 case, not just described abstractly? [Measurability, Spec §SC-002] — yes, `quickstart.md` Scenario 2 exercises N=2 concretely.

## Scenario Coverage

- [ ] CHK010 Are requirements defined for a fix to one bug in a shared batch (Story 2) that breaks a *different*, already-passing bug's retest within the same shared retest pass? [Coverage, Gap]
- [x] CHK011 Are requirements defined for a scenario with exactly one bug (the degenerate case of Story 2's batching)? [Coverage, Spec §US1] — Story 1 covers this directly; Story 2 only adds behavior for N>1.

## Edge Case Coverage

- [x] CHK012 Is behavior specified for a high-risk bug discovered only during in-session assessment, not obvious from the original finding? [Edge Case, Spec Edge Cases] — explicit, first edge case bullet.
- [x] CHK013 Is behavior specified for a batch mixing one high-risk and one routine bug? [Edge Case, Spec Edge Cases] — explicit, second edge case bullet.
- [ ] CHK014 Is behavior specified for the app failing to *stop* cleanly (as opposed to failing to *restart*, which FR-012 covers)? [Edge Case, Gap]

## Non-Functional Requirements

- [ ] CHK015 Is there any bound on how long an in-session assessment or fix attempt may take before it's considered stuck? [Gap, Non-Functional]

## Dependencies & Assumptions

- [x] CHK016 Is the dependency on `UAT-02`'s classification (BUG findings as the trigger) and `UAT-03`'s flag semantics (`--silent`, `REVIEW_BEFORE_FIX`) documented? [Dependency, Spec Assumptions] — both named as dependencies; `UAT-03`'s flags are threaded through FR-003–FR-005 explicitly.
- [ ] CHK017 Is the boundary between this feature's scope and `UAT-09`'s Spec-Kit delegation validated anywhere beyond the spec's own Assumptions (e.g. does `SKILL.md`'s actual structure make that boundary as clean as assumed)? [Dependency, Gap]

## Ambiguities & Conflicts

- [x] CHK018 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability] — same `FR-###`/`US#`/`AC#` scheme as prior features, applied consistently.

## Notes

Defaults applied without an interactive clarification round: Depth = Standard,
Audience = Reviewer, per explicit user input. Focus narrowed to the retry-cycle
mechanics (genuinely intricate — batching, two independent thresholds, pause-gate
re-triggering) and FR-013 (the one confirmed new behavior). No user-specified
must-have items beyond depth/audience.
