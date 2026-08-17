# Readiness Checklist: Backend Verification

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-16
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Reviewer
**Focus**: completeness/clarity of the path-selection and degradation rules, and
consistency across spec/data-model/contract for the three genuinely new behaviors
(FR-006, FR-008, FR-009).

## Requirement Completeness

- [ ] CHK001 Are requirements defined for what happens when Phase 0.5 discovery itself couldn't determine a single "primary" store among several candidates (as opposed to finding none at all)? [Completeness, Gap]
- [ ] CHK002 Is there a requirement addressing verification reading data that was actually left over from a prior, uncleaned run (stale data producing a false "confirmed" result)? [Completeness, Gap]
- [ ] CHK003 Are requirements defined for a partial-match case — the claimed data exists in the backend but doesn't fully match the scenario's claimed shape/values? [Completeness, Gap]

## Requirement Clarity

- [ ] CHK004 Is "discrepancy" (FR-006) defined precisely enough to distinguish a genuine contradiction from a benign formatting/representation difference between UI and backend? [Clarity, Spec §FR-006]
- [ ] CHK005 Is how discovery selects a "single primary store" when multiple are plausibly relevant (FR-009) defined, or left to interpretation? [Clarity, Spec §FR-009]
- [ ] CHK006 Is a bound given for how long a verification attempt may run before being treated as failed/timed-out (FR-008), or is this deliberately left unquantified like this product's other retry-based rules? [Clarity, Spec §FR-008]

## Requirement Consistency

- [x] CHK007 Does `data-model.md`'s `Backend Verification Result.status` enumeration match the outcome language used in spec.md's User Story 1 Acceptance Scenario 4 and Story 3 exactly? [Consistency, Spec §US1, §US3] — fixed during `/speckit-analyze`: the contract file previously described these outcomes in different prose per section rather than using the enum's literal values; now references `confirmed`/`discrepancy`/`ui-only`/`verification-failed` verbatim throughout.
- [x] CHK008 Does `contracts/verification-path-contract.md`'s four sections map one-to-one to this spec's three user stories without a gap or an extra, unspecified behavior? [Consistency, Spec §US1-3] — verified: §1/§4 → US1 (path selection, multi-store disclosure), §2 → US2 (no path discoverable), §3 → US1 discrepancy + US3 failure classification (correctly spans both, since FR-006 is US1 and FR-008 is US3).

## Acceptance Criteria Quality

- [ ] CHK009 Is SC-001's "100% of cases" falsifiable by a single live run, or does validating it actually require testing across multiple discoverable-store configurations? [Measurability, Spec §SC-001]
- [ ] CHK010 Is SC-003's "used rather than bypassed" given an observable signal (what would someone actually look at to confirm the API path, not the direct-store path, was used)? [Measurability, Spec §SC-003]

## Scenario Coverage

- [ ] CHK011 Are requirements defined for a scenario whose Expected Outcome names backend data, but where the API technically exists yet returns an error unrelated to the data itself (e.g. auth failure on the verification call)? [Coverage, Gap]
- [ ] CHK012 Are requirements defined for how this feature's read interacts with UAT-06's start-of-run purge timing — could verification run against data that's about to be purged as stale? [Coverage, Gap]

## Edge Case Coverage

- [x] CHK013 Is behavior specified for when the backend-verification connection itself fails while the app under test is functioning normally? [Edge Case, Spec §US3] — explicit in Story 3 and its edge case bullet.
- [x] CHK014 Is behavior specified for a scenario that names no backend data at all? [Edge Case, Spec §US2 AC2] — explicit, backend verification is not attempted.
- [ ] CHK015 Is behavior specified for a scenario whose Expected Outcome names data across a boundary this feature doesn't own (e.g. a third-party/external API webapp-uat doesn't control) versus the app's own backend? [Edge Case, Gap]

## Non-Functional Requirements

- [ ] CHK016 Is there a requirement governing how much of a captured backend response gets written into the finding (truncation for size/sensitive-data reasons), consistent with Phase 2's existing "truncate before writing to disk" rule for console/network capture? [Gap, Non-Functional]

## Dependencies & Assumptions

- [ ] CHK017 Is this feature's dependency on Phase 0.5 discovery's accuracy (a mis-identified store/API silently produces wrong verification results) documented anywhere, or implicitly assumed reliable? [Assumption, Gap]
- [x] CHK018 Is the boundary between this feature's read-only scope and UAT-06's write-confirmation gate documented? [Dependency, Spec §FR-005, Assumptions] — explicit in both FR-005 and the Assumptions section.

## Ambiguities & Conflicts

- [x] CHK019 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability] — same `FR-###`/`US#`/`AC#` scheme as prior features, applied consistently.

## Notes

Defaults applied without an interactive clarification round: Depth = Standard,
Audience = Reviewer, per explicit user input for this checklist invocation. Focus
narrowed to the three genuinely new behaviors this feature adds beyond what
`SKILL.md` already has (FR-006, FR-008, FR-009), since those carry the highest
change/ambiguity risk. No user-specified must-have items beyond depth/audience.
