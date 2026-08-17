# Readiness Checklist: Config & Environment Bootstrap

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-15
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Author (proceeding straight to tasks/implement)
**Focus**: completeness/clarity of the detection & failure-handling rules
(highest-change-risk area — FR-013 and its write-outcome contract are new this
session), and consistency across spec/data-model/contract.

## Requirement Completeness

- [x] CHK001 Are requirements defined for what happens when start/stop detection finds evidence for more than the two illustrated mechanisms at once (beyond `run.sh`+compose vs. `package.json`)? [Completeness, Spec Edge Cases]
- [ ] CHK002 Are requirements defined for what "the skill's own installed location" resolves to when installed via a plugin/marketplace mechanism rather than a manual file copy? [Gap]
- [x] CHK003 Is the exact set of accepted `Procfile`/`Makefile` "dev/up/down-shaped" target names enumerated, or left to interpretation? [Completeness, Spec §FR-002] — **Resolved by removal, not enumeration**: found during `/speckit-implement` that `Procfile` never actually matched this criterion (see `docs/design-history.md` D5); `Procfile` was dropped from FR-002 entirely rather than having its target names enumerated. `Makefile`'s exact accepted target names remain informally described ("dev/up/down-shaped") rather than a fixed enumerated list — acceptable, since `Makefile` targets are genuinely free-form by convention and an exhaustive list would be false precision.

## Requirement Clarity

- [ ] CHK004 Is "genuinely ambiguous" (the condition that gates the needs-your-input label) defined by more than the single monorepo example given? [Clarity, Spec §US3]
- [ ] CHK005 Is "equivalent convention" (for spec-dir detection beyond a literal `specs/` directory) given concrete criteria, or left undefined? [Ambiguity, Spec §FR-006]
- [ ] CHK006 Is the exact form of a "specific evidence" citation for a detected value specified (file path, matched line, or just a file name)? [Clarity, Spec §FR-007]

## Requirement Consistency

- [x] CHK007 Do the write-outcome-report contract (`contracts/setup-interaction-contract.md` §3) and FR-013 agree on whether a partial failure is reported before or after every item has been attempted? [Consistency, Spec §FR-013]
- [x] CHK008 Are the confidence-label definitions in `data-model.md`'s Configuration Draft table consistent, field-by-field, with FR-007's three-way definition? [Consistency, Spec §FR-007]

## Acceptance Criteria Quality

- [ ] CHK009 Is SC-001's "single guided interaction" objectively measurable (e.g., a bounded number of round-trips), or open to interpretation? [Measurability, Spec §SC-001]
- [ ] CHK010 Can SC-004's "genuinely ambiguous situation" be verified independently of the illustrative examples used to define it elsewhere in the spec? [Measurability, Spec §SC-004]

## Scenario Coverage

- [ ] CHK011 Are requirements defined for a user choosing "edit values first" more than once in a row? [Gap, Coverage]
- [ ] CHK012 Are recovery requirements defined for `specify extension list` itself failing or returning no entries, distinct from the happy path FR-005 assumes? [Gap, Exception Flow]

## Edge Case Coverage

- [ ] CHK013 Is behavior specified for a `.specify/` directory that exists but is empty or malformed, versus one genuinely containing Spec Kit configuration? [Edge Case, Gap]
- [ ] CHK014 Is behavior specified for a retry where a *previously succeeded* item (e.g., `config.md`) was manually altered between the failed run and the retry? [Edge Case, Gap]

## Non-Functional Requirements

- [x] CHK015 Is there any requirement governing how long detection may take before the draft must be presented, or is this intentionally unconstrained? [Gap, Non-Functional]

## Dependencies & Assumptions

- [ ] CHK016 Is the assumption that repo-root resolution is available and reliable in every target environment validated anywhere, or only assumed? [Assumption, Spec Assumptions]
- [ ] CHK017 Is the dependency on the spec-workflow tool's command-listing output being stable and parseable documented as a risk? [Dependency, Gap]

## Ambiguities & Conflicts

- [x] CHK018 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability]

## Notes

Defaults applied without an interactive clarification round, per this session's
standing instruction to proceed through the full Spec Kit sequence: Depth =
Standard, Audience = Author, Focus = the two highest-change-risk clusters
(detection-rule completeness/clarity, and consistency of the newly-added
failure-handling behavior across spec/data-model/contract). No user-specified
must-have items were given for this checklist.

### Pre-implementation disposition (2026-08-15)

Reviewed at the `/speckit-implement` checklist gate. 5/18 resolved in substance by
this session's `/speckit-clarify` + `/speckit-analyze` remediation work and checked
off above (CHK001, CHK007, CHK008, CHK015, CHK018). The remaining 13 are real gaps,
but every one is either scoped to a not-yet-built dependency (CHK002 → `UAT-11`) or a
low-impact edge case that doesn't block or contradict this feature's three user
stories:

- **Still open, deferred by explicit decision, not oversight**: CHK002, CHK004,
  CHK005, CHK006, CHK009, CHK010, CHK011, CHK012, CHK013, CHK014, CHK016, CHK017.

### During-implementation update (2026-08-15, T003)

CHK003 resolved during Phase 3 (US1 test execution) — see its checkbox above and
`docs/design-history.md` D5. Not resolved by writing the requirement more precisely
as the checklist item anticipated; resolved by discovering the requirement was
wrong (`Procfile` was never actually reachable by the stated criterion) and removing
that part of the claim entirely. `spec.md` FR-002, `data-model.md`, `plan.md`,
`quickstart.md` (Scenario 11), `SKILL.md`, and `README.md` were all updated to match.
- **Decision**: proceed to implementation despite the FAIL status. If implementation
  work actually runs into one of these 13 (not just brushes past it), stop and raise
  it for discussion rather than silently resolving or silently ignoring it.
