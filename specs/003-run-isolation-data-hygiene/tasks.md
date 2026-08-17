# Tasks: Run Isolation & Data Hygiene

**Input**: Design documents from `/specs/003-run-isolation-data-hygiene/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/cleanup-confirmation-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), no compiled source
exists — `quickstart.md`'s 9 scenarios are the documented check. Unlike `UAT-02`,
most of these are text-traceable against `SKILL.md` (confirmation-prompt wording,
decline consequences, naming pattern), needing only a minimal seed-data-capable
target for live confirmation, not a full browser-execution app.

**Organization**: Grouped by user story (spec.md P1/P1/P1/P2). Most scope already
exists in `SKILL.md`'s R7/Phase 0/Phase 5/Generation-mode sections; the two likely
new pieces are FR-004 (no-op case) and FR-011 (differentiated decline consequence).

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Primary file: `.claude/skills/webapp-uat/SKILL.md` (R7 naming section, Phase 0
start-of-run cleanup, Phase 5 end-of-run cleanup, Generation mode's data/fixture
confirmation).

---

## Phase 1: Setup

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` is on a clean git working tree (or only this session's own prior work) before this feature's edits begin — has uncommitted changes, all from this session's own prior work; proceeding

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude/skills/webapp-uat/SKILL.md`'s current R7 naming section, Phase 0 start-of-run cleanup, Phase 5 end-of-run cleanup, and Generation mode's seed-data confirmation against `specs/003-run-isolation-data-hygiene/spec.md`'s FR-001–FR-011 and `data-model.md`'s four entities. **Drift found: exactly the two anticipated gaps.** FR-001/002/003/005/006/007/008/009/010 all match exactly — FR-010 in particular matches near-verbatim ("This confirmation doesn't lapse automatically... that's a manual edit to this file"). Missing: FR-004 (no-op-when-nothing-to-purge case) and both halves of FR-011 (neither purge's decline consequence is stated at all in current text).

**Checkpoint**: Foundation confirmed — story work can begin

---

## Phase 3: User Story 1 - Collision-resistant naming (Priority: P1) 🎯 MVP

**Independent Test**: Per `spec.md` User Story 1; `quickstart.md` Scenario 1.

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Trace `spec.md` US1's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s R7 naming section; record pass/fail — **all 3 pass** (folded into T002)

### Implementation for User Story 1

- [X] T004 [US1] If T003 finds any gap, update the R7 naming section accordingly — no gap found, no change needed

**Checkpoint**: Naming guarantee verified

---

## Phase 4: User Story 2 - Self-healing start-of-run purge (Priority: P1)

**Independent Test**: Per `spec.md` User Story 2; `quickstart.md` Scenarios 2-3.

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T005 [P] [US2] Trace `spec.md` US2's 4 acceptance scenarios (AC1/2/4 pre-existing, AC3 the newly-clarified decline-blocks behavior) against `.claude/skills/webapp-uat/SKILL.md`'s Phase 0 start-of-run cleanup text; record pass/fail — **AC1/2/4 pass** (folded into T002); **AC3 (decline-blocks) confirmed missing**, as anticipated

### Implementation for User Story 2

- [X] T006 [US2] Add FR-004's no-op-when-nothing-to-purge behavior and FR-011's decline-blocks-the-run behavior to Phase 0's start-of-run cleanup step, if T005 found either missing — done, both added
- [X] T007 [US2] Re-trace AC3/AC4 against the updated text to confirm both land correctly — **pass**, matches both exactly

**Checkpoint**: Start-of-run purge verified, including the new decline-blocks behavior

---

## Phase 5: User Story 3 - Report-gated end-of-run purge (Priority: P1)

**Independent Test**: Per `spec.md` User Story 3; `quickstart.md` Scenarios 4-6.

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T008 [P] [US3] Trace `spec.md` US3's 4 acceptance scenarios (AC1/2/4 pre-existing, AC3 the newly-clarified decline-does-not-block behavior) against `.claude/skills/webapp-uat/SKILL.md`'s Phase 5 end-of-run cleanup text; record pass/fail — **AC1/2/4 pass** (folded into T002); **AC3 (decline-doesn't-block) confirmed missing**, as anticipated

### Implementation for User Story 3

- [X] T009 [US3] Add FR-011's decline-does-not-block-completion behavior to Phase 5's end-of-run cleanup step, if T008 found it missing — done
- [X] T010 [US3] Re-trace AC3 against the updated text to confirm it lands correctly and doesn't contradict US2's blocking behavior (they must read as deliberately different, not inconsistent) — **pass**: text explicitly says "unlike the start-of-run purge," reading as deliberate, not contradictory

**Checkpoint**: End-of-run purge verified, including the new non-blocking decline behavior

---

## Phase 6: User Story 4 - Uniform confirmation, no silent exceptions (Priority: P2)

**Independent Test**: Per `spec.md` User Story 4; `quickstart.md` Scenarios 7-9.

### Tests for User Story 4 (MANDATORY per constitution Principle VIII)

- [X] T011 [P] [US4] Trace `spec.md` US4's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Generation mode confirmation text (already added earlier this session) and against `SKILL.md`/`USAGE.md`/`config.md.example` for the absence of any confirmation-skipping setting; record pass/fail — **all 3 pass**: AC1/AC2 confirmed via T002's trace; AC3 confirmed by grepping all three files for any skip/disable/no-confirm setting — zero matches

### Implementation for User Story 4

- [X] T012 [US4] If T011 finds any gap, update the relevant section accordingly — no gap found, no change needed

**Checkpoint**: All three DB-write confirmations verified uniform, with no runtime escape hatch

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T013 [P] Perform a manual structural check of every `SKILL.md` section touched by T004/T006/T09/T012 — no Markdown linter installed (constitution Principle VII); also confirm the start-of-run (blocks) vs. end-of-run (doesn't block) decline behaviors read as deliberately differentiated, not contradictory, on a fresh read — **pass**: both sections read cleanly, no broken formatting, differentiation explicit via "unlike the start-of-run purge" (already confirmed in T010)
- [X] T014 [P] Re-evaluate `specs/003-run-isolation-data-hygiene/checklists/readiness.md` CHK007 and CHK008 (decline-consequence consistency across data-model/contract) against the final edited text and update their checkbox state — already checked off pre-implementation; T006/T009's edits made `SKILL.md` match the data-model/contract wording that was already correct, no change to their status
- [X] T015 Record which `quickstart.md` scenarios remain unverified beyond text-tracing — **Scenario 9 is fully confirmed** (text-only check, done via T011's grep). **Scenarios 1-8 remain unverified by live execution** — every one of them passed as a trace of what `SKILL.md`'s instructions say, not as a live-observed run against a real target with seed-data capability. This feature's completion evidence is "the rules are written correctly, including the two behaviors this feature added," not yet "the rules hold when actually run." Tracked explicitly, not silently treated as done.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational only — independent of US1/US3 (different `SKILL.md` sections)
- **User Story 3 (Phase 5)**: Depends on Foundational only — independent of US1/US2, but T010 cross-checks against US2's outcome for consistency
- **User Story 4 (Phase 6)**: Depends on Foundational only
- **Polish (Phase 7)**: Depends on whichever stories were completed

### Parallel Opportunities

- T003, T005, T008, T011 (the four initial trace tasks) can run in parallel —
  independent `SKILL.md` sections.
- T013 and T014 (Polish) can run in parallel.

## Notes

- [P] tasks = different files/sections, no dependency on an incomplete task
- This feature is more text-traceable than `UAT-02` but still not fully
  live-verified — `T015` exists to keep that honest rather than implied-complete
- Commit after each task or logical group
- Avoid: letting US2's blocking and US3's non-blocking decline behaviors drift into
  reading as inconsistent rather than deliberately different (T010's specific job)
