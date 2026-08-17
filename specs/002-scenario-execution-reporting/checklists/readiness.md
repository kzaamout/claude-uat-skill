# Readiness Checklist: Manual Scenario Execution, Checks, Classification & Report

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-16
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Author (proceeding straight to tasks/implement)
**Focus**: completeness/clarity of the five-category classification boundaries
(highest-change-risk area — FR-009a is new this session), and whether the
live-target-app dependency `quickstart.md` surfaced is adequately reflected upstream
in `spec.md` itself.

## Requirement Completeness

- [ ] CHK001 Is there a rule for when an app crash is a severity other than P0 ("typically P0" in FR-009a implies exceptions exist)? [Completeness, Spec §FR-009a]
- [ ] CHK002 Is the live-target-app dependency this feature's own verification needs (surfaced in `quickstart.md`) reflected as a Dependency or Assumption in `spec.md` itself, or only noted downstream? [Gap]
- [ ] CHK003 Are requirements defined for what happens when a fixture is missing not due to an environment problem but because a scenario's own Preconditions are wrong (author error, not `TEST_ENVIRONMENT`)? [Completeness, Gap]

## Requirement Clarity

- [ ] CHK004 Is "instruction-like string" (User Story 3) defined by more than the one illustrative example given? [Clarity, Spec §US3]
- [ ] CHK005 Is the login-failure edge case's category left as a genuine judgment call by design, or does it need a firmer rule? [Ambiguity, Spec Edge Cases]
- [ ] CHK006 Is "becomes unresponsive" (FR-009a) given a concrete detection criterion (a timeout value, a specific signal), or left to interpretation? [Clarity, Spec §FR-009a]

## Requirement Consistency

- [x] CHK007 Does `data-model.md`'s Finding table's severity/recommendation mutual-exclusivity rule match FR-013/FR-014 exactly? [Consistency, Spec §FR-013, §FR-014]
- [x] CHK008 Does `contracts/execution-report-contract.md` §3's category boundary wording match FR-009a and Phase 3's planned edit exactly, not just in spirit? [Consistency, Spec §FR-009a]

## Acceptance Criteria Quality

- [ ] CHK009 Is SC-001's "without any manual test-writing or code inspection" objectively verifiable, or open to interpretation of what counts as "inspection"? [Measurability, Spec §SC-001]
- [x] CHK010 Is SC-005's "never loses that scenario's recorded result" testable without an actual interrupted-run scenario, given this feature doesn't cover resumability itself? [Measurability, Spec §SC-005] — **Improved by `/speckit-analyze` finding E3**: US1 AC8 now ties directly to SC-005 ("written immediately... so interruption afterward does not lose it"), making it text-traceable via T003 rather than requiring a real interrupted-run scenario.

## Scenario Coverage

- [ ] CHK011 Are requirements defined for a scenario producing more than one finding in a single run (e.g. both a `BUG` and separate `UX_FRICTION`)? [Gap, Coverage]
- [ ] CHK012 Are requirements defined for the axe-core CDN failing to load (already flagged as a known, un-fixed gap in Edge Cases) beyond just naming it as out of scope? [Gap, Exception Flow]

## Edge Case Coverage

- [ ] CHK013 Is behavior specified for a scenario with a malformed or incomplete file (missing required template sections)? [Edge Case, Gap — flagged during `/speckit-clarify`, deliberately not asked as a formal question, low impact]
- [ ] CHK014 Is behavior specified for two scenarios in the same run targeting the same account/session concurrently affecting each other's state? [Edge Case, Gap]

## Non-Functional Requirements

- [ ] CHK015 Is there any requirement governing how long a scenario may run before being considered stuck (distinct from the app-crash case, FR-009a)? [Gap, Non-Functional]

## Dependencies & Assumptions

- [x] CHK016 Is the assumption that axe-core's CDN is reachable from every target environment documented as a risk, given the known unresolved gap? [Assumption, Spec Assumptions] — already explicit in Edge Cases: "a known, pre-existing gap... carried forward rather than silently fixed."
- [ ] CHK017 Is the dependency on `UAT-01`'s output (`config.md`, working `scripts/dev.sh`) actually verified at the start of this feature's own flow, or only assumed present? [Dependency, Spec Assumptions]

## Ambiguities & Conflicts

- [x] CHK018 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability]

## Pre-implementation disposition (2026-08-16)

Reviewed at the `/speckit-implement` checklist gate, same process as `UAT-01`. 5/18
resolved in substance (CHK007, CHK008, CHK010, CHK016, CHK018) and checked off
above. The remaining 13 are real gaps, but every one is a low-impact edge case or
scoped to a not-yet-built dependency (`UAT-11`-adjacent, or `demo-app/`) — none
contradict or block this feature's three user stories. **Decision**: proceed to
implementation despite the FAIL status; if implementation work actually runs into
one of the 13, stop and raise it for discussion rather than resolving or ignoring it
silently — same standing instruction as `UAT-01`.

## Notes

Defaults applied without an interactive clarification round, per this session's
standing instruction to proceed through the full Spec Kit sequence: Depth =
Standard, Audience = Author, Focus = the two highest-change-risk clusters
(classification-boundary completeness/clarity, and whether the live-app dependency
surfaced during planning is properly reflected upstream). No user-specified
must-have items were given for this checklist.
