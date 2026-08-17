# Readiness Checklist: Scenario Generation — Boundary-Derived + Fixture Synthesis

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-17
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Reviewer
**Focus**: completeness/clarity of the four genuinely new pieces (FR-002 drafting
cardinality, FR-006 fixture-list dedup, FR-011 unreadable-validation skip, FR-012
zero-constraints-found) and the corrected FR-010 fixture-persistence rule.

## Requirement Completeness

- [ ] CHK001 Is there a requirement for how "cannot be confidently read or parsed" (FR-011) is determined — a concrete threshold, or left entirely to per-flow judgment? [Completeness, Gap]
- [ ] CHK002 Is there a requirement for what happens when a flow's validation is split across multiple layers (e.g. client-side zod schema AND a separate server-side check) that disagree with each other? [Completeness, Gap]

## Requirement Clarity

- [x] CHK003 Is "genuinely satisfies the constraint" (FR-008) given a concrete definition beyond the Edge Cases' worked example (structurally valid, actually over/under the stated limit)? [Clarity, Spec Edge Cases] — Edge Cases states the smallest-unambiguous-value rule directly; sufficiently concrete for a generation-time judgment call, consistent with how persona derivation (UAT-07) and high-risk scope (UAT-04) are handled.
- [ ] CHK004 Is "distinct constraint category" (FR-002) closed to exactly the four named (max-length, required-field, enum, type-mismatch), or open-ended for a validation framework with other category types (e.g. cross-field validation, regex pattern)? [Clarity, Spec §FR-002]

## Requirement Consistency

- [x] CHK005 Does `data-model.md`'s Synthesized Fixture entity's persistence rule match `contracts/boundary-fixture-contract.md` §6 exactly? [Consistency, Spec §FR-010] — verified: both state the file persists unsuffixed/unpurged, distinct from any referencing DB row which follows `UAT-06`.
- [x] CHK006 Does the corrected FR-010 in `spec.md` actually match the existing `SKILL.md` R7 text it's meant to already satisfy, not just plausibly resemble it? [Consistency, Spec §FR-010] — verified directly against R7's exact wording ("synthesized fixtures tracked in the DB" get suffixed) during `/speckit-plan`'s research phase; the correction is precise, not approximate.

## Acceptance Criteria Quality

- [ ] CHK007 Is SC-002's "100% of generation runs against that flow" falsifiable by a small number of live runs, or does validating it require a flow with all four constraint categories simultaneously present? [Measurability, Spec §SC-002]
- [x] CHK008 Is SC-005's "genuine files... actually satisfy the constraint" testable with a concrete inspection step, not just described abstractly? [Measurability, Spec §SC-005] — yes, `quickstart.md` Scenario 3 specifies confirming the synthesized file is parseable and genuinely over the stated size limit.

## Scenario Coverage

- [x] CHK009 Are requirements defined for a flow that is both Critical/High priority AND has a discovered routing gap (an overlap with `UAT-07`'s route-gap-derived source)? [Coverage, Gap] — not a genuine gap: boundary-derived and route-gap-derived answer different questions (real negative-path coverage for existing validated input vs. any coverage at all for an untested screen) and `UAT-07`'s Edge Cases already establish the general no-dedup-across-sources precedent this would fall under.
- [ ] CHK010 Are requirements defined for a Critical/High-priority flow whose validation constraints change between two separate `generate` runs (e.g. a max-length was widened)? [Coverage, Gap]

## Edge Case Coverage

- [x] CHK011 Is behavior specified for validation code that can't be read or parsed? [Edge Case, Spec Edge Cases] — explicit, first edge case bullet.
- [x] CHK012 Is behavior specified for an ambiguous synthesis target value (e.g. "oversized" with no exact limit stated)? [Edge Case, Spec Edge Cases] — explicit, second edge case bullet.
- [x] CHK013 Is behavior specified for an existing fixture that doesn't actually satisfy a new draft's constraint (a same-name collision)? [Edge Case, Spec Edge Cases] — explicit, third edge case bullet.
- [x] CHK014 Is behavior specified for a Critical/High-priority flow with zero discoverable validation constraints? [Edge Case, Spec Edge Cases] — explicit, fourth edge case bullet.

## Non-Functional Requirements

- [ ] CHK015 Is there any bound on how large a synthesized fixture may legitimately be (e.g. a "10GB oversized" constraint), given synthesis happens inline in an approval flow? [Gap, Non-Functional]

## Dependencies & Assumptions

- [x] CHK016 Is the dependency on `UAT-07`'s already-established generation-source patterns (Source: tagging, explicit graceful degradation) documented? [Dependency, Spec Assumptions] — first Assumptions bullet states `UAT-07` is done and this feature only adds the third source.
- [x] CHK017 Is the dependency on `UAT-06`'s run-isolation discipline, and its actual scope (DB rows, not fixture files), validated against `UAT-06`'s own spec rather than assumed? [Dependency, Spec §FR-010] — validated directly against `SKILL.md` R7's exact text during `/speckit-plan`, not assumed; this is precisely the correction this feature's plan made.

## Ambiguities & Conflicts

- [x] CHK018 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability] — same `FR-###`/`US#`/`AC#` scheme as prior features, applied consistently.

## Notes

Defaults applied without an interactive clarification round: Depth = Standard,
Audience = Reviewer, per explicit user input. Focus narrowed to the four genuinely
new rules and the FR-010 correction, since most other requirements already existed
correctly in `SKILL.md` (Generation mode's boundary-derived bullet, and — notably —
Phase 0's fixture-check step already satisfying the synthesis-offer requirements
before this feature existed). No user-specified must-have items beyond
depth/audience.
