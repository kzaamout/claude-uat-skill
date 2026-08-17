# Tasks: One-Command Install

**Input**: Design documents from `/specs/010-one-command-install/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/setup-template-copy-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), no compiled source
exists — `quickstart.md`'s 3 scenarios (9 acceptance criteria) are the
documented check, text-traced against `SKILL.md` and `marketplace.json`. **Live
verification of the `/plugin` install flow itself is explicitly blocked** —
`/plugin` is an interactive CLI meta-command with no tool access available in
this session.

**Organization**: Grouped by user story (spec.md P1/P1/P2). Unlike every prior
slice this session, **all 8 FRs already match existing, already-committed text
exactly** — this feature retroactively formalizes work built directly in a
prior session. No `SKILL.md` or `marketplace.json` edit is anticipated;
`/speckit-analyze` confirms this before `/speckit-implement` runs as a no-op.

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Reference files (no edits anticipated):
`.claude-plugin/marketplace.json`, `.claude/skills/webapp-uat/SKILL.md` (Setup
mode step 6), `.claude/skills/webapp-uat/templates/`.

---

## Phase 1: Setup

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` and `.claude-plugin/marketplace.json` are on a clean git working tree (or only this session's own prior work) before this feature's verification begins

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude-plugin/marketplace.json` and `.claude/skills/webapp-uat/SKILL.md`'s current Setup mode step 6 against `specs/010-one-command-install/spec.md`'s FR-001–FR-008 and `data-model.md`'s three entities. **Drift found: none.** All 8 FRs already match existing text exactly — `marketplace.json`'s `source`/`skills` fields already resolve to `.claude/skills/webapp-uat` (`FR-001`); step 6 already states the bundled-template-copy-when-missing behavior (`FR-003`/`FR-004`), the fill-in-place-when-existing behavior (`FR-005`), and the best-effort/per-item-reporting/safe-re-run behavior (`FR-006`/`FR-007`/`FR-008`) near-verbatim against this spec's own phrasing. Also confirmed `.claude/skills/webapp-uat/templates/dev.sh.template` and `templates/_template.md` both exist on disk.

**Checkpoint**: Foundation confirmed — zero gaps found, story work is verification-only

---

## Phase 3: User Story 1 - A stranger installs the skill with two commands, no manual copying (Priority: P1) 🎯 MVP

**Independent Test**: Per `spec.md` US1; `quickstart.md` Scenario 1 (text-traced; live `/plugin` check blocked).

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Trace `spec.md` US1's 3 acceptance scenarios against `marketplace.json` and `SKILL.md`'s Setup mode steps 1-5; record pass/fail — **all 3 pass** (folded into T002)

### Implementation for User Story 1

- [X] T004 [US1] If T003 finds any gap, update `marketplace.json`/`SKILL.md` accordingly — no gap found, no change needed

**Checkpoint**: Two-command install flow and skill-source resolution verified, no changes required

---

## Phase 4: User Story 2 - Project-tree files land correctly despite the plugin's `.claude/`-only limitation (Priority: P1)

**Independent Test**: Per `spec.md` US2; `quickstart.md` Scenario 2 (text-traced; live check blocked).

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T005 [P] [US2] Trace `spec.md` US2's 3 acceptance scenarios against `SKILL.md` Setup mode step 6's template-copy text; record pass/fail — **all 3 pass** (folded into T002)

### Implementation for User Story 2

- [X] T006 [US2] If T005 finds any gap, update Setup mode step 6 accordingly — no gap found, no change needed

**Checkpoint**: Bundled-template-copy and fill-in-place behaviors verified, no changes required

---

## Phase 5: User Story 3 - Install failures are partial and safely re-runnable (Priority: P2)

**Independent Test**: Per `spec.md` US3; `quickstart.md` Scenario 3 (text-traced; live check blocked).

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T007 [P] [US3] Trace `spec.md` US3's 3 acceptance scenarios against `SKILL.md` Setup mode step 6's best-effort/reporting/re-run text; record pass/fail — **all 3 pass**, matching the worked example already in `SKILL.md` (folded into T002)

### Implementation for User Story 3

- [X] T008 [US3] If T007 finds any gap, update Setup mode step 6 accordingly — no gap found, no change needed

**Checkpoint**: Partial-failure handling and safe re-run behavior verified, no changes required

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T009 [P] Confirm `.claude/skills/webapp-uat/templates/dev.sh.template` and `templates/_template.md` remain present and non-empty on disk — pass, both verified present via `ls -la` during `/speckit-plan`
- [X] T010 [P] Re-evaluate `specs/010-one-command-install/checklists/readiness.md`'s open items (CHK001, CHK004, CHK008, CHK010, CHK014) against the final (unedited) `SKILL.md`/`marketplace.json` text — none required a spec or code change; all five remain genuine open questions appropriate for future refinement, none safety-relevant enough to block this slice
- [X] T011 Record this slice's live-verification status explicitly — every one of T003/T005/T007's traces confirms what `SKILL.md`/`marketplace.json` already say, not a live-observed `/plugin` install. **All 3 `quickstart.md` scenarios are text-traced only. Live verification of the actual `/plugin marketplace add` + `/plugin install` flow stays blocked**, per `spec.md`'s own Assumptions — no tool access to `/plugin` is available in this session. Tracked explicitly as an open item for the user or a fresh session, not silently treated as done.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational only — independent of US1/US3
- **User Story 3 (Phase 5)**: Depends on Foundational only — independent of US1/US2
- **Polish (Phase 6)**: Depends on whichever stories were completed

### Parallel Opportunities

- T003, T005, T007 (the three initial trace tasks) can run in parallel —
  independent read-only traces of different `SKILL.md` sections, no edits at
  all this cycle.
- T009 and T010 (Polish) can run in parallel.

## Notes

- [P] tasks = different files/sections, no dependency on an incomplete task
- Every implementation task this cycle (T004/T006/T008) is a no-op by design —
  the foundational diff (T002) already confirmed zero drift; this is the first
  slice this session to converge without a single `SKILL.md` edit
- Commit after each task or logical group (a documentation-only commit this
  time, since no source file changes)
- Avoid: treating the zero-edit outcome as a shortcut to skip verification
  steps — each trace task still ran independently against the actual current
  text, not assumed correct from the feature description alone
