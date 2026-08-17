# Readiness Checklist: Run Isolation & Data Hygiene

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-16
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Author (proceeding straight to tasks/implement)
**Focus**: completeness/clarity of the two purge mechanisms and the newly-clarified
differentiated decline behavior (highest-change-risk area this session), and
consistency across spec/data-model/contract.

## Requirement Completeness

- [ ] CHK001 Are requirements defined for what happens if the purge itself fails partway (already flagged as unresolved in Assumptions) beyond just naming it unresolved? [Completeness, Gap]
- [ ] CHK002 Is the exact detection mechanism for "leftover UAT-marked data" specified (a query pattern, a marker field), or left to interpretation? [Completeness, Gap]
- [ ] CHK003 Is what "blocks the run" (FR-011) concretely means — a retry option, or full termination — defined? [Completeness, Spec §FR-011]

## Requirement Clarity

- [ ] CHK004 Is "structurally near-impossible" (naming collision resistance) quantified, or left a qualitative claim? [Clarity, Spec Edge Cases]
- [ ] CHK005 Is "runtime setting, flag, or mode" (FR-010) defined broadly enough to explicitly cover a future `config.md` key, not just CLI flags? [Clarity, Spec §FR-010]
- [ ] CHK006 Is "database-tracked synthesized fixture" (vs. a bare file) given a concrete distinguishing test? [Clarity, Spec Assumptions]

## Requirement Consistency

- [x] CHK007 Does `data-model.md`'s decline-consequence description for both purges match FR-011 exactly? [Consistency, Spec §FR-011] — verified word-for-word during `/speckit-analyze`.
- [x] CHK008 Does `contracts/cleanup-confirmation-contract.md` §1/§2's decline behavior match US2/AC3 and US3/AC3 exactly? [Consistency, Spec §US2, §US3] — verified word-for-word during `/speckit-analyze`.

## Acceptance Criteria Quality

- [ ] CHK009 Is SC-004 ("never assigned the same identifier") falsifiable in principle, or an absolute claim resting entirely on run-id granularity never repeating? [Measurability, Spec §SC-004]
- [x] CHK010 Is SC-001's "100% of cases" scoped to exclude the already-flagged partial-purge-failure gap, or does it implicitly overclaim against that gap? [Consistency, Spec §SC-001 vs. Assumptions] — re-read: SC-001 says data is never left behind *permanently*, which a temporarily-failed purge doesn't violate as long as future runs keep self-healing. Not a contradiction.

## Scenario Coverage

- [ ] CHK011 Are requirements defined for a purge triggered while a second confirmation (e.g. seed-data creation) is also pending in the same run? [Gap, Coverage]
- [x] CHK012 Are requirements defined for what happens to in-progress scenario execution if start-of-run cleanup is declined and blocks the run (before vs. after scenarios have started)? [Gap, Edge Case] — moot on reflection: start-of-run cleanup is part of Phase 0, strictly before Phase 2 scenario execution begins, so "in-progress scenario execution" can't exist yet when this block would occur.

## Edge Case Coverage

- [x] CHK013 Is behavior specified for a run-id collision across two runs started in the same clock-minute (the naming format's actual granularity)? [Edge Case, Gap] — already explicit in spec.md's own Edge Cases as an acknowledged, deliberately-unguarded near-impossibility, same treatment as `UAT-02`'s axe-core CDN gap.
- [ ] CHK014 Is behavior specified for a UAT-marked record manually renamed or altered outside the skill, breaking the naming pattern? [Edge Case, Gap]

## Non-Functional Requirements

- [ ] CHK015 Is there any requirement bounding how long a purge may take before it's considered stuck, distinct from failing outright? [Gap, Non-Functional]

## Dependencies & Assumptions

- [ ] CHK016 Is the dependency on the target project's data store supporting a query/delete-by-prefix operation validated anywhere, or only assumed universally possible? [Assumption, Gap]
- [ ] CHK017 Is the boundary between this feature's DB-tracked scope and `UAT-04`/`UAT-09`'s code-artifact scope documented anywhere besides this spec's own Assumptions? [Dependency, Spec Assumptions]

## Ambiguities & Conflicts

- [x] CHK018 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability] — verified consistent during `/speckit-analyze` (100% requirement-to-task coverage confirmed the ID scheme holds throughout).

## Pre-implementation disposition (2026-08-16)

Reviewed at the `/speckit-implement` checklist gate. 6/18 resolved in substance
(CHK007, CHK008, CHK010, CHK012, CHK013, CHK018) and checked off above — notably
more than the prior two features' ~5/18, since `/speckit-analyze` this time came
back with zero findings, directly resolving the consistency items. The remaining
12 are real gaps, all low-impact edge cases or documentation-completeness items
that don't block or contradict this feature's four user stories. **Decision**:
proceed to implementation; if implementation work actually runs into one of the
12, stop and raise it for discussion — same standing instruction as before.

## Notes

Defaults applied without an interactive clarification round, per this session's
standing instruction to proceed through the full Spec Kit sequence: Depth =
Standard, Audience = Author, Focus = the two highest-change-risk clusters (purge
mechanism completeness/clarity, and the newly-clarified decline-consequence
consistency across artifacts). No user-specified must-have items were given for
this checklist.
