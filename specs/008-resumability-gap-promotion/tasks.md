# Tasks: Resumability & In-Run Gap Promotion

**Input**: Design documents from `/specs/008-resumability-gap-promotion/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/resume-and-gap-promotion-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), no compiled source
exists — `quickstart.md`'s 4 scenarios (14 acceptance criteria) are the documented
check, live-verifiable against `demo-app` via a deliberately interrupted session
and a deliberately gap-containing review batch.

**Organization**: Grouped by user story (spec.md P1/P1/P2/P1). Detection
(FR-001–003, FR-009–012) and gap-promotion mechanics (FR-013–015) already exist
in `SKILL.md`. Three genuinely new pieces: FR-004 (multi-interruption tie-break),
FR-005–008/FR-017 (resume mechanics — the substantive new content), FR-016
(no-recursion bound).

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Primary file: `.claude/skills/webapp-uat/SKILL.md` (Phase 0 "Resume check", Phase
1 "Gap promotion (R9)").

---

## Phase 1: Setup

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` is on a clean git working tree (or only this session's own prior work) before this feature's edits begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude/skills/webapp-uat/SKILL.md`'s current Phase 0 "Resume check" and Phase 1 "Gap promotion (R9)" against `specs/008-resumability-gap-promotion/spec.md`'s FR-001–FR-017 and `data-model.md`'s three entities. **Drift found: four gaps, one caught only during `/speckit-analyze`.** FR-001/002/003/010/011/012 (detection, the three-way choice, `--silent` default and reporting) and FR-013/014/015 (gap-drafting, tagging, same-pass approval) all already match existing text closely. Missing: FR-004 (multi-interruption tie-break), FR-005/006/007/008/017 (resume mechanics — nothing currently states what "resume" does once chosen, confirmed against `docs/design-history.md` R8 never having specified it), FR-016 (no-recursion bound on gap promotion), and **FR-009** — initially miscategorized as already-matching; `/speckit-analyze` caught that the existing text never actually states "start fresh" leaves the interrupted run's directory untouched, only `spec.md`'s Edge Cases did.

**Checkpoint**: Foundation confirmed — story work can begin

---

## Phase 3: User Story 1 - An interrupted run is detected, never silently collided with (Priority: P1) 🎯 MVP

**Independent Test**: Per `spec.md` US1; `quickstart.md` Scenario 1.

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Trace `spec.md` US1's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 0 "Resume check" text; record pass/fail — **AC1 (detection before app/browser touch) and AC3 (no prompt when nothing found) pass; AC2 (exactly resume/abandon/start-fresh, not binary) passes textually but the multi-interruption tie-break (FR-004) is confirmed missing**, as anticipated (folded into T002)

### Implementation for User Story 1

- [X] T004 [US1] Add FR-004's multi-interruption tie-break to Phase 0's "Resume check" — when multiple interrupted-run directories exist, act only on the most recent by `run-id`; leave others untouched, no auto-purge, no auto-merge. Also close FR-009's gap found during `/speckit-analyze`: state explicitly that "start fresh" (chosen manually, not just under `--silent`) begins a new run under a new `run-id` and leaves the interrupted run's directory untouched — not deleted, not merged. — done
- [X] T005 [US1] Re-trace AC2 against the updated text to confirm it reads as a direct extension of the existing three-way-choice language, not a contradiction of it — pass

**Checkpoint**: Interrupted-run detection (including the multi-run tie-break) verified

---

## Phase 4: User Story 2 - Resuming a run actually continues it, not restarts it (Priority: P1)

**Independent Test**: Per `spec.md` US2; `quickstart.md` Scenario 2.

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T006 [P] [US2] Trace `spec.md` US2's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 0 "Resume check" text for what "resume" actually does; record pass/fail — **all 4 confirmed missing** — the current text detects and offers the choice but never specifies resume's mechanics, matching `docs/design-history.md` R8's own acknowledgment that this was never specified (folded into T002)

### Implementation for User Story 2

- [X] T007 [US2] Add FR-005's plan-reuse rule to Phase 0's "Resume check" — resuming reuses the existing `test-plan.md` without regenerating or re-reviewing it — done
- [X] T008 [US2] Add FR-006's already-recorded-result skip to the same section — a scenario with a pre-interruption recorded result is not re-executed; its result carries forward into the final report unchanged — done
- [X] T009 [US2] Add FR-007's remaining-scenario execution rule — scenarios with no recorded result execute normally, in the plan's original order — done
- [X] T010 [US2] Add FR-008's single-coherent-report rule — the resumed run's final report covers every scenario from the original plan as one document, not separate pre-/post-interruption reports — done
- [X] T011 [US2] Add FR-017's missing-scenario-file handling to the same section — a `test-plan.md` reference to a since-deleted scenario file is reported as unable to resume/execute, explicitly, rather than silently dropped or aborting the whole resume — done
- [X] T012 [US2] Re-trace all 4 acceptance scenarios against the updated text to confirm the new resume-mechanics content reads as a coherent addition to the existing detection/choice text, not a disconnected bolt-on — pass

**Checkpoint**: Resume mechanics verified — the substantive new content this feature adds

---

## Phase 5: User Story 3 - `--silent` defaults safely to abandon, never to blind resume (Priority: P2)

**Independent Test**: Per `spec.md` US3; `quickstart.md` Scenario 3.

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T013 [P] [US3] Trace `spec.md` US3's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 0 `--silent` default text; record pass/fail — **all 3 pass** (folded into T002)

### Implementation for User Story 3

- [X] T014 [US3] If T013 finds any gap, update Phase 0 accordingly — no gap found, no change needed

**Checkpoint**: `--silent` default behavior verified, no changes required

---

## Phase 6: User Story 4 - A coverage gap noticed during review becomes a real scenario immediately (Priority: P1)

**Independent Test**: Per `spec.md` US4; `quickstart.md` Scenario 4.

### Tests for User Story 4 (MANDATORY per constitution Principle VIII)

- [X] T015 [P] [US4] Trace `spec.md` US4's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 1 "Gap promotion (R9)" text; record pass/fail — **AC1 (in-line drafting), AC2 (`review-derived` tag), AC3 (same-pass approval), and AC4 (no mandatory quota) all pass; the no-recursion bound (FR-016) confirmed missing**, as anticipated (folded into T002)

### Implementation for User Story 4

- [X] T016 [US4] Add FR-016's no-recursion bound to Phase 1's "Gap promotion (R9)" — a newly gap-promoted scenario is not itself re-reviewed for further gaps within the same pass; a deeper gap is available on a subsequent run's review — done
- [X] T017 [US4] Re-trace the recursion-adjacent edge case against the updated text to confirm it reads as a direct extension of the existing gap-promotion language, not a contradiction of it — pass

**Checkpoint**: Gap-promotion mechanics (including the recursion bound) verified

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T018 [P] Perform a manual structural check of every `SKILL.md` section touched by T004/T007/T008/T009/T010/T011/T016 — no Markdown linter installed (constitution Principle VII); confirm all additions read as coherent extensions of Phase 0/Phase 1, not disconnected bolt-ons — pass, clean Markdown, verified by direct re-read
- [X] T019 [P] Re-evaluate `specs/008-resumability-gap-promotion/checklists/readiness.md`'s open items (CHK002, CHK004, CHK007, CHK010, CHK015) against the final edited `SKILL.md` text — none required a spec change; all five remain genuine open questions appropriate for future refinement, none safety-relevant enough to block this slice
- [X] T020 Record which `quickstart.md` scenarios remain unverified beyond text-tracing — every one of T003/T006/T013/T015's traces confirms what `SKILL.md`'s instructions say, not a live-observed run. **All 4 scenarios are live-verifiable against `demo-app` as-is — Scenario 1/2/3 need a deliberately interrupted session (killing the CLI mid-run), Scenario 4 needs a deliberately gap-containing review batch — both straightforward to construct.** Tracked explicitly, not silently treated as done.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational only — the story with the most substantive new content this cycle
- **User Story 3 (Phase 5)**: Depends on Foundational only — independent of US1/US2/US4
- **User Story 4 (Phase 6)**: Depends on Foundational only — independent of US1/US2/US3
- **Polish (Phase 7)**: Depends on whichever stories were completed

### Parallel Opportunities

- T003, T006, T013, T015 (the four initial trace tasks) can run in parallel —
  independent read-only traces of different `SKILL.md` sections, no conflicting
  edits yet.
- T018 and T019 (Polish) can run in parallel.

## Notes

- [P] tasks = different files/sections, no dependency on an incomplete task
- T007/T008/T009/T010/T011 all touch the same Resume-check section — sequenced
  since each extends the same paragraph and T012's re-trace checks all five
  together for coherence
- Commit after each task or logical group
- Avoid: letting the resume-mechanics addition (T007-T011) read as describing a
  live process/browser-state resurrection rather than the deliberately
  filesystem-artifact-only mechanism `research.md` settled on; letting FR-016's
  recursion bound read as disabling gap promotion generally rather than scoping
  it to originally-reviewed scenarios only (T017's specific job)
