# Readiness Checklist: Resumability & In-Run Gap Promotion

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-17
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Reviewer
**Focus**: completeness/clarity of the resume-mechanics content (the substantive
new addition) and the three-way choice's exact semantics.

## Requirement Completeness

- [x] CHK001 Is "abandon" (distinct from "start fresh") given its own defined effect, or left implicit as a synonym? [Completeness, Spec §FR-002] — fixed: `spec.md`'s three-way choice was ambiguous on this point during drafting; resolved directly (see Notes) — "abandon" stops the invocation entirely with nothing run, "start fresh" begins a new run leaving the old one untouched. Both now stated explicitly in the Key Entities' Resume Decision entry.
- [ ] CHK002 Is there a requirement for what happens if the user is prompted with resume/abandon/start-fresh but declines to answer at all (as opposed to `--silent`'s automatic default)? [Completeness, Gap]

## Requirement Clarity

- [x] CHK003 Is "a real coverage gap" (FR-013) given any further definition beyond the Assumptions section's acknowledgment that it stays a judgment call? [Clarity, Spec Assumptions] — consistent with how `UAT-07`'s persona derivation and `UAT-08`'s constraint-category detection are handled; not further quantified by design.
- [ ] CHK004 Is "picks up... in the same order it would have run in originally" (FR-007) precise about what happens if the scope path or scenario set genuinely changed between the interrupted run and the resume attempt? [Clarity, Gap]

## Requirement Consistency

- [x] CHK005 Does `data-model.md`'s Resume Decision table match `contracts/resume-and-gap-promotion-contract.md` §2-§4 exactly, including the corrected "abandon" vs. "start fresh" distinction? [Consistency, Spec §FR-002/FR-009] — verified: both now state the same two distinct effects.
- [x] CHK006 Does the Edge Cases section's multiple-interrupted-runs tie-break match `data-model.md`'s Interrupted Run entity and FR-004's wording? [Consistency, Spec Edge Cases] — verified: both state most-recent-by-run-id, others left untouched.

## Acceptance Criteria Quality

- [ ] CHK007 Is SC-002's "100% of scenarios with a recorded result... preserved unchanged" falsifiable by a small number of live interrupt-and-resume cycles, or does it require exhausting every possible interruption point? [Measurability, Spec §SC-002]
- [x] CHK008 Is SC-004's "100% of real coverage gaps... produce an actual, approvable scenario file" testable with a concrete review-pass inspection, not just described abstractly? [Measurability, Spec §SC-004] — yes, `quickstart.md` Scenario 4 specifies a concrete deliberately-gapped batch and confirms both the promoted case and the no-gap case.

## Scenario Coverage

- [x] CHK009 Are requirements defined for a run interrupted before `test-plan.md` is even written (i.e. during Phase 0 itself, before any plan exists)? [Coverage, Gap] — not a genuine gap: FR-001's detection condition is specifically "test-plan.md exists, final-report.md doesn't" — an interruption before test-plan.md exists leaves no artifact at all to detect, so Phase 0 correctly proceeds as a normal fresh run; nothing to resume by definition.
- [ ] CHK010 Are requirements defined for a run interrupted *during* the resume attempt itself (a resume that itself gets interrupted)? [Coverage, Gap]

## Edge Case Coverage

- [x] CHK011 Is behavior specified for multiple interrupted runs existing simultaneously? [Edge Case, Spec Edge Cases] — explicit, first edge case bullet.
- [x] CHK012 Is behavior specified for "start fresh" chosen with an interrupted run present (does the old one get cleaned up)? [Edge Case, Spec Edge Cases] — explicit, second edge case bullet.
- [x] CHK013 Is behavior specified for a resumed run's `test-plan.md` referencing a scenario file deleted since the interruption? [Edge Case, Spec Edge Cases] — explicit, third edge case bullet.
- [x] CHK014 Is behavior specified for a gap-promoted scenario itself appearing to have a further gap (recursive promotion)? [Edge Case, Spec Edge Cases] — explicit, fourth edge case bullet.

## Non-Functional Requirements

- [ ] CHK015 Is there any bound on how old an interrupted run may be before it's no longer offered as resumable (e.g. a run from months ago, against a since-changed app)? [Gap, Non-Functional]

## Dependencies & Assumptions

- [x] CHK016 Is the dependency on `UAT-02`'s Phase 1 review (which gap promotion extends) and `UAT-01`'s Phase 0 (which resume detection extends) documented? [Dependency, Spec Input] — named directly in the feature description.
- [x] CHK017 Is the closing of the review/generation-adjacent group (`UAT-07`, `UAT-08`, `UAT-10` — the fourth and final `Source:` tag) stated explicitly? [Dependency, Spec Assumptions] — third Assumptions bullet states this directly.

## Ambiguities & Conflicts

- [x] CHK018 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability] — same `FR-###`/`US#`/`AC#` scheme as prior features, applied consistently.

## Notes

Defaults applied without an interactive clarification round: Depth = Standard,
Audience = Reviewer, per explicit user input. Focus narrowed to the resume
mechanics (the substantive new content this feature adds, per `docs/design-
history.md` R8 never having specified it) and the three-way choice's exact
semantics. **CHK001 surfaced a genuine ambiguity in `spec.md`'s own drafting**
(whether "abandon" is a synonym for "start fresh" or a distinct third action) —
resolved directly by clarifying `spec.md`'s Key Entities Resume Decision entry:
"abandon" stops the invocation with nothing run (the interrupted run stays
exactly as it was, unresolved); "start fresh" begins a new run under a new
`run-id`, also leaving the interrupted run's directory untouched. The two differ
only in whether a new run begins at all. No user-specified must-have items beyond
depth/audience.
