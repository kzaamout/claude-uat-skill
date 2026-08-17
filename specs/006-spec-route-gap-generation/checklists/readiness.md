# Readiness Checklist: Scenario Generation — Spec-Derived + Route-Gap-Derived

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-17
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Reviewer
**Focus**: completeness/clarity of the two genuinely new pieces (FR-008/FR-009's
symmetric degradation, FR-010/FR-012's broader `--priority` scoping) and the
cross-source tagging/dedup rules that make the two draft types safely coexist.

## Requirement Completeness

- [ ] CHK001 Is there a requirement for what happens when `generate` is invoked a second time and a prior draft (not yet reviewed/promoted) already exists for the same acceptance criterion or route gap? [Completeness, Gap]
- [ ] CHK002 Is there a requirement for how a single acceptance criterion that itself contains multiple distinct Given/When/Then clauses is decomposed — one draft per criterion, or one per clause? [Completeness, Gap]

## Requirement Clarity

- [ ] CHK003 Is "plausibly different behavior" (FR-003) given any further definition beyond the Assumptions section's acknowledgment that persona derivation stays qualitative? [Clarity, Spec Assumptions]
- [x] CHK004 Is "zero existing scenario coverage" (FR-004/FR-006) defined precisely enough to distinguish it from "incomplete coverage"? [Clarity, Spec §FR-006] — US2 AC3 states this explicitly: route-gap-derived targets screens with zero coverage, not screens with incomplete coverage, which is called out as a distinct, non-route-gap concern.

## Requirement Consistency

- [x] CHK005 Does `data-model.md`'s Generation Prerequisite State table match `contracts/generation-source-contract.md` §2-§4 exactly, for all four prerequisite-state combinations? [Consistency, Spec §FR-007/FR-008/FR-009] — verified: both enumerate the same four states (both met / spec-dir only / routing only / neither) with matching outcomes.
- [x] CHK006 Does the spec's Edge Cases section's "not merged or deduplicated" rule match `contracts/generation-source-contract.md` §7 wording? [Consistency, Spec Edge Cases] — verified: both state both drafts are produced independently, each with its own true source tag, even for overlapping UI.

## Acceptance Criteria Quality

- [ ] CHK007 Is SC-001's "100% of generation runs" falsifiable by a small number of live runs, or does validating it require exhausting every acceptance-criteria shape a spec could contain? [Measurability, Spec §SC-001]
- [x] CHK008 Is SC-004's "100% of drafts... carry a Source: tag" testable with a concrete mixed-source batch, not just described abstractly? [Measurability, Spec §SC-004] — yes, `quickstart.md` Scenario 4 exercises a mixed-source batch inspection concretely.

## Scenario Coverage

- [x] CHK009 Are requirements defined for a project with `spec-dir` configured but zero acceptance criteria found under it (an empty-but-valid case, distinct from unconfigured)? [Coverage, Gap] — not explicitly distinguished from FR-007's "unconfigured" case; folds into it since a `spec-dir` producing zero criteria still lets spec-derived generation "run" and simply complete with no drafts, which SC-001's "every acceptance criterion" framing already covers vacuously — not a genuine gap.
- [ ] CHK010 Are requirements defined for a `scope` path that matches neither anything under `spec-dir` nor any discovered screen (a scope that excludes everything)? [Coverage, Gap]

## Edge Case Coverage

- [x] CHK011 Is behavior specified for a discovered route that's a redirect or non-content technical route rather than a user-facing screen? [Edge Case, Spec Edge Cases] — explicit, first edge case bullet; deferred to Phase 0.5's own recording, not re-filtered here.
- [x] CHK012 Is behavior specified for an acceptance criterion too vague to turn into a concrete Given/When/Then scenario? [Edge Case, Spec Edge Cases] — explicit, second edge case bullet.
- [x] CHK013 Is behavior specified for the same screen being both a route-gap and the subject of a spec-derived draft in one run? [Edge Case, Spec Edge Cases] — explicit, third edge case bullet.
- [x] CHK014 Is behavior specified for `--priority` excluding every flow a project has? [Edge Case, Spec Edge Cases] — explicit, fourth edge case bullet.

## Non-Functional Requirements

- [ ] CHK015 Is there any bound on the number of drafts a single `generate` run may produce before Phase 1's review flow becomes impractical to work through in one pass? [Gap, Non-Functional]

## Dependencies & Assumptions

- [x] CHK016 Is the dependency on `UAT-01`'s Phase 0.5 routing discovery documented? [Dependency, Spec Input] — named directly in the feature description and reflected in FR-004/FR-008's routing-source language.
- [x] CHK017 Is the boundary between this feature's scope and `UAT-08`'s boundary-derived/fixture-synthesis scope stated explicitly? [Dependency, Spec Assumptions] — first Assumptions bullet states this directly.

## Ambiguities & Conflicts

- [x] CHK018 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability] — same `FR-###`/`US#`/`AC#` scheme as prior features, applied consistently.

## Notes

Defaults applied without an interactive clarification round: Depth = Standard,
Audience = Reviewer, per explicit user input. Focus narrowed to the two genuinely
new degradation/scoping rules and the cross-source tagging/dedup rules, since most
other requirements already existed in `SKILL.md` before this feature formalized
them. No user-specified must-have items beyond depth/audience.
