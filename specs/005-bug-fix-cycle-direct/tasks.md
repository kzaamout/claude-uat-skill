# Tasks: Bug-Fix Cycle (Direct Mechanism)

**Input**: Design documents from `/specs/005-bug-fix-cycle-direct/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/fix-cycle-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), no compiled source
exists — `quickstart.md`'s 4 scenarios (13 acceptance criteria) are the documented
check, live-verifiable against `demo-app`'s three `DEMO_BUG_*` flags.

**Organization**: Grouped by user story (spec.md P1/P1/P2/P2). Most scope
(FR-001–FR-010, FR-012) already exists in `SKILL.md`'s Phase 4; two genuinely new
pieces: FR-011a (pause-gate re-triggering on retry) and FR-013 (distinct
failure-mode reporting in Phase 5).

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Primary file: `.claude/skills/webapp-uat/SKILL.md` (Phase 4 bug-fix cycle, Phase 5
final report).

---

## Phase 1: Setup

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` is on a clean git working tree (or only this session's own prior work) before this feature's edits begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude/skills/webapp-uat/SKILL.md`'s current Phase 4 (`direct` branch) and Phase 5 report structure against `specs/005-bug-fix-cycle-direct/spec.md`'s FR-001–FR-013 and `data-model.md`'s four entities. **Drift found: exactly the two anticipated gaps.** FR-001/002/003/004/005/006/007/008/009/010/011/012 all match existing text closely, several near-verbatim. Missing: FR-011a (retry cycles don't currently say they re-apply the pause gates) and FR-013 (Phase 5's report has one undivided "unresolved" bucket, no distinction between a restart-failure-threshold stop and a per-bug retry-budget exhaustion).

**Checkpoint**: Foundation confirmed — story work can begin

---

## Phase 3: User Story 1 - Fix only counts after a real browser retest (Priority: P1) 🎯 MVP

**Independent Test**: Per `spec.md` User Story 1; `quickstart.md` Scenario 1.

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Trace `spec.md` US1's 6 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 4 text; record pass/fail — **all 6 pass** (folded into T002)

### Implementation for User Story 1

- [X] T004 [US1] If T003 finds any gap, update Phase 4 accordingly — no gap found, no change needed

**Checkpoint**: Core single-bug cycle verified, no changes required

---

## Phase 4: User Story 2 - Multiple bugs share one restart/retest (Priority: P1)

**Independent Test**: Per `spec.md` User Story 2; `quickstart.md` Scenario 2.

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T005 [P] [US2] Trace `spec.md` US2's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 4 batching text; record pass/fail — **all 3 pass** (folded into T002)

### Implementation for User Story 2

- [X] T006 [US2] If T005 finds any gap, update Phase 4 accordingly — no gap found, no change needed

**Checkpoint**: Multi-bug batching verified, no changes required

---

## Phase 5: User Story 3 - High-risk bugs always pause (Priority: P2)

**Independent Test**: Per `spec.md` User Story 3; `quickstart.md` Scenario 3.

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T007 [P] [US3] Trace `spec.md` US3's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 4 pause-gate text; record pass/fail — **all 4 pass** (folded into T002)

### Implementation for User Story 3

- [X] T008 [US3] If T007 finds any gap, update Phase 4 accordingly — no gap found, no change needed

**Checkpoint**: High-risk pause behavior verified, no changes required

---

## Phase 6: User Story 4 - Retry budgets and failure thresholds (Priority: P2)

**Independent Test**: Per `spec.md` User Story 4; `quickstart.md` Scenario 4.

### Tests for User Story 4 (MANDATORY per constitution Principle VIII)

- [X] T009 [P] [US4] Trace `spec.md` US4's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 4/Phase 5 text; record pass/fail — **AC1 (retry budget), AC2 (continue with independent scenarios), AC3 (restart-failure threshold) pass** (folded into T002); **AC4 (distinct reporting, FR-013) confirmed missing**, as anticipated; **FR-011a's pause-gate re-triggering also confirmed missing** (part of AC1's now-expanded scope)

### Implementation for User Story 4

- [X] T010 [US4] Add FR-011a's pause-gate re-triggering to Phase 4's retry-cycle step (step 5) — each of the up-to-2 additional diagnose/fix cycles re-applies the same high-risk/routine pause gates as the original attempt — done
- [X] T011 [US4] Add FR-013's distinct failure-mode reporting to Phase 5's bug-reporting bullet — a restart-failure-threshold stop and a per-bug retry-budget exhaustion must not be conflated under one undivided "unresolved" label — done
- [X] T012 [US4] Re-trace AC4 and FR-011a against the updated text to confirm both land correctly and don't contradict Phase 4's existing retry-cycle language — pass, both read as direct extensions, step 3's existing restart-threshold text and step 5's new retry-gate text are textually distinct and non-contradictory

**Checkpoint**: Retry/threshold behavior verified, including the two new additions

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T013 [P] Perform a manual structural check of every `SKILL.md` section touched by T010/T011 — no Markdown linter installed (constitution Principle VII); confirm both additions read as coherent extensions of Phase 4/Phase 5, not disconnected bolt-ons — pass, clean Markdown
- [X] T014 [P] Re-evaluate `specs/005-bug-fix-cycle-direct/checklists/readiness.md` CHK006 (data-model/contract consistency for FR-013) against the final edited `SKILL.md` text and update its checkbox state — already resolved during `/speckit-analyze`, no change needed
- [X] T015 Record which `quickstart.md` scenarios remain unverified beyond text-tracing — every one of T003/T005/T007/T009's traces confirms what `SKILL.md`'s instructions say, not a live-observed run. **Scenario 1 and Scenario 3 are live-verifiable against `demo-app` as-is (single-bug cycle, high-risk pause). Scenario 2 needs a constructed multi-bug case; Scenario 4 needs deliberate interference (a non-fixing "fix," a broken start command) to force both failure paths.** Tracked explicitly, not silently treated as done.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational only — independent of US1/US3/US4
- **User Story 3 (Phase 5)**: Depends on Foundational only — independent of US1/US2/US4
- **User Story 4 (Phase 6)**: Depends on Foundational only — the only story with real edits this cycle
- **Polish (Phase 7)**: Depends on whichever stories were completed

### Parallel Opportunities

- T003, T005, T007, T009 (the four initial trace tasks) can run in parallel —
  independent read-only traces of the same file, no conflicting edits yet.
- T013 and T014 (Polish) can run in parallel.

## Notes

- [P] tasks = different files/sections, no dependency on an incomplete task
- T010/T011 touch different sections (Phase 4 vs. Phase 5) — could run in parallel,
  but sequenced here since T012's re-trace checks both together for consistency
- Commit after each task or logical group
- Avoid: letting FR-011a's retry-gate re-triggering read as contradicting Phase 4's
  existing single-pass pause-gate language rather than an explicit extension of it
  (T012's specific job)
