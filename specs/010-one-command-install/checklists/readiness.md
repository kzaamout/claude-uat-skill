# Readiness Checklist: One-Command Install

**Purpose**: Unit tests for the requirements themselves — validating that `spec.md`,
`plan.md`, and their supporting artifacts are complete, clear, consistent, and
measurable before `/speckit-tasks` breaks them into implementation work.
**Created**: 2026-08-17
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)
**Depth**: Standard | **Audience**: Reviewer
**Focus**: confirming the retroactive-formalization premise holds (every FR
already matches existing text) and the `/plugin`-verification limitation is
honestly scoped, not overstated.

## Requirement Completeness

- [ ] CHK001 Is there a requirement for what happens if `.claude-plugin/marketplace.json` itself becomes malformed or out of sync with Claude Code's own schema over time? [Completeness, Gap]
- [x] CHK002 Is there a requirement covering the case where a target project already has files from a prior partial/failed install attempt (not the same as Story 3's forced-failure case, but a pre-existing stale state)? [Completeness, Gap] — not a genuine gap: this is exactly Setup mode's own existing re-run behavior (step 7, diff-and-per-field-approval), already reused by this feature rather than reinvented, per Constitution Principle V; no separate requirement needed.

## Requirement Clarity

- [x] CHK003 Is "behave identically" (FR-002) given enough concreteness to be falsifiable, or does it risk being an unfalsifiable claim about two flows that were never actually run side-by-side? [Clarity, Spec §FR-002] — concretized by Assumptions and `quickstart.md`: falsifiable via text-tracing (steps 1-5 don't branch on install method) within the stated `/plugin`-verification limitation; not claimed as live-observed identical behavior.
- [ ] CHK004 Is "specific reason" (Key Entities, Write-Step Outcome) for a FAILED item given any minimum content requirement, or left entirely to whatever the underlying filesystem error message says? [Clarity, Gap]

## Requirement Consistency

- [x] CHK005 Does `data-model.md`'s Bundled Template table match `contracts/setup-template-copy-contract.md` §3 exactly, for both the copy-when-missing and fill-in-place-when-existing cases? [Consistency, Spec §FR-003/FR-005] — verified: both state the same two-file, two-behavior split.
- [x] CHK006 Does this feature's `marketplace.json` field reference (`FR-001`) match the actual current file's contents, not a plausible-looking description of what it should contain? [Consistency, Spec §FR-001] — verified directly against the live `marketplace.json` file during `/speckit-plan`'s research phase (`cat` output), not assumed.

## Acceptance Criteria Quality

- [x] CHK007 Is SC-001's "zero manual file copying at any point" falsifiable given the `/plugin`-verification limitation, or does it remain an assertion about text, not observed behavior? [Measurability, Spec §SC-001] — explicitly scoped in Assumptions/`quickstart.md` as text-traced-and-already-achieved, with live verification tracked separately as blocked — not conflated.
- [ ] CHK008 Is SC-003's "leaves 100% of the other, successful items unchanged" testable with a concrete forced-failure case, or does it require exhausting every possible filesystem failure mode? [Measurability, Spec §SC-003]

## Scenario Coverage

- [x] CHK009 Are requirements defined for a target project that already has `.claude/skills/webapp-uat/` from a prior manual copy, with the plugin then also installed? [Coverage, Edge Case] — explicit, second edge case bullet; deliberately not resolved by this feature, treated as a user-created configuration conflict Setup's existing re-run behavior surfaces.
- [ ] CHK010 Are requirements defined for a target project on a filesystem/OS where the bundled template's file permissions (e.g. `dev.sh.template`'s executable bit) don't survive the copy? [Coverage, Gap]

## Edge Case Coverage

- [x] CHK011 Is behavior specified for `templates/dev.sh.template` and root `scripts/dev.sh` drifting out of sync over time? [Edge Case, Spec Edge Cases] — explicit, first edge case bullet; documented as a maintenance concern, not automated.
- [x] CHK012 Is behavior specified for a target project with both an existing manual copy and a new plugin install of the same skill? [Edge Case, Spec Edge Cases] — explicit, second edge case bullet.
- [x] CHK013 Is behavior specified for a plugin install succeeding but the target's `templates/` directory being missing or incomplete (a broken plugin cache)? [Edge Case, Spec Edge Cases] — explicit, third edge case bullet.

## Non-Functional Requirements

- [ ] CHK014 Is there any bound on how large the bundled `templates/` directory may grow before it affects plugin install/cache size or performance? [Gap, Non-Functional]

## Dependencies & Assumptions

- [x] CHK015 Is the dependency on `UAT-01`'s Setup mode (which this feature extends) documented? [Dependency, Spec Input] — named directly in the feature description.
- [x] CHK016 Is the `/plugin`-verification limitation stated as an explicit, tracked open item rather than implied as equivalent to completion — using the same honest framing `UAT-09` established for its own external-tool limitation? [Dependency, Spec Assumptions] — first Assumptions bullet states this directly, explicitly modeled on `UAT-09`'s precedent.

## Ambiguities & Conflicts

- [x] CHK017 Is a requirement & acceptance-criteria ID scheme established and applied consistently across `spec.md`, `data-model.md`, and the contract file? [Traceability] — same `FR-###`/`US#`/`AC#` scheme as prior features, applied consistently.

## Notes

Defaults applied without an interactive clarification round: Depth = Standard,
Audience = Reviewer, per explicit user input. Focus narrowed to confirming this
feature's unusual premise (retroactive formalization of already-correct code,
zero anticipated `SKILL.md` edits) actually holds, and that the `/plugin`
verification limitation is scoped honestly rather than glossed over. No
user-specified must-have items beyond depth/audience.
