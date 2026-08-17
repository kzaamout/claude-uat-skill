# Tasks: Backend Verification

**Input**: Design documents from `/specs/004-backend-verification/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/verification-path-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), no compiled source
exists — `quickstart.md`'s 8 scenarios are the documented check, live-verifiable
against `demo-app` (its dual API/direct-DB paths and silent-comment-failure bug were
purpose-built for this feature).

**Organization**: Grouped by user story (spec.md P1/P2/P3). Most of Story 1 and all
of Story 2 already exist in `SKILL.md`'s Phase 0.5/Phase 2 step 7; Story 1's AC6
(FR-009) and all of Story 3 (FR-008) are the new pieces.

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Primary file: `.claude/skills/webapp-uat/SKILL.md` (Phase 0.5 "Backend verification
path" discovery step, Phase 2 step 7 execution-time check).

---

## Phase 1: Setup

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` is on a clean git working tree (or only this session's own prior work) before this feature's edits begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude/skills/webapp-uat/SKILL.md`'s current Phase 0.5 "Backend verification path" and Phase 2 step 7 against `specs/004-backend-verification/spec.md`'s FR-001–FR-009 and `data-model.md`'s two entities. **Drift found: exactly the three anticipated gaps.** FR-001/002/003/004/005/007 all match existing text (API-first preference, direct-store fallback, UI-only degradation with a note, read-not-write, scoped to scenarios naming data). Missing: FR-006 (discrepancy not explicitly called out as its own surfaced behavior), FR-008 (no verification-failure-is-TEST_ENVIRONMENT rule exists anywhere), FR-009 (no single-store disclosure language exists).

**Checkpoint**: Foundation confirmed — story work can begin

---

## Phase 3: User Story 1 - A false UI success is caught (Priority: P1) 🎯 MVP

**Independent Test**: Per `spec.md` User Story 1; `quickstart.md` Scenarios 1-4, 5a.

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Trace `spec.md` US1's 6 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 0.5/Phase 2 step 7 text; record pass/fail — **AC1/2/3/5 pass** (folded into T002); **AC4 (discrepancy surfacing, FR-006) and AC6 (single-store disclosure, FR-009) confirmed missing**, as anticipated

### Implementation for User Story 1

- [X] T004 [US1] Add FR-006's explicit discrepancy-surfacing behavior to Phase 2 step 7 — when the backend contradicts the UI's claim, the finding states both signals rather than silently preferring either — done
- [X] T005 [US1] Add FR-009's single-primary-store disclosure to Phase 2 step 7 — when more than one discovered store is plausibly relevant, the finding states only the primary store was checked, not full multi-store coverage — done
- [X] T006 [US1] Re-trace AC4 and AC6 against the updated text to confirm both land correctly — pass, both match

**Checkpoint**: Core verification behavior (path selection, degradation, discrepancy surfacing, multi-store disclosure) fully specified

---

## Phase 4: User Story 2 - Graceful degradation with no discoverable backend (Priority: P2)

**Independent Test**: Per `spec.md` User Story 2; `quickstart.md` Scenarios 5-6.

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T007 [P] [US2] Trace `spec.md` US2's 2 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 2 step 7 text; record pass/fail — **both pass** (folded into T002) — UI-only note (FR-004) and scoped-to-claims-only (FR-007) are both already present

### Implementation for User Story 2

- [X] T008 [US2] If T007 finds any gap, update Phase 2 step 7 accordingly — no gap found, no change needed

**Checkpoint**: Degradation behavior verified, no changes required

---

## Phase 5: User Story 3 - Verification failures distinguished from app failures (Priority: P3)

**Independent Test**: Per `spec.md` User Story 3; `quickstart.md` Scenario 7.

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T009 [P] [US3] Trace `spec.md` US3's 2 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 2 step 7 and Phase 3 classification text; record pass/fail — **both fail (confirmed missing)**, as anticipated — no rule anywhere distinguishes a verification-connection failure from an app defect

### Implementation for User Story 3

- [X] T010 [US3] Add FR-008's verification-failure classification rule to Phase 2 step 7, mirroring Phase 3's existing app-crash-is-BUG-never-TEST_ENVIRONMENT precedent — done; also extended Phase 3's existing paragraph itself for a single source of truth on the distinction
- [X] T011 [US3] Re-trace both AC against the updated text; also confirm the new rule doesn't contradict Phase 3's existing classification table — pass, reads as a direct extension of the existing app-crash precedent, not a separate/inconsistent rule

**Checkpoint**: Verification-failure classification verified, consistent with existing Phase 3 precedent

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T012 [P] Perform a manual structural check of every `SKILL.md` section touched by T004/T005/T010 — no Markdown linter installed (constitution Principle VII); confirm the three additions read as a coherent extension of Phase 2 step 7, not three disconnected bolt-ons — pass, clean Markdown, no broken lists/formatting
- [X] T013 [P] Re-evaluate `specs/004-backend-verification/checklists/readiness.md` CHK007/CHK008 (data-model/contract consistency) against the final edited `SKILL.md` text and update their checkbox state — already resolved during `/speckit-analyze`, no change needed
- [X] T014 Record which `quickstart.md` scenarios remain unverified beyond text-tracing — every one of T003/T007/T009's traces confirms what `SKILL.md`'s instructions say, not a live-observed run. **Scenarios 1-4, 6-7 are live-verifiable against `demo-app` as-is; Scenario 5a (multi-store) and Scenario 5 (fully backend-opaque) need a setup `demo-app` doesn't provide by default.** Tracked explicitly, not silently treated as done.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational only — independent of US1/US3 (verified, no edit needed)
- **User Story 3 (Phase 5)**: Depends on Foundational only — independent of US1/US2, but T011 cross-checks against Phase 3's existing table for consistency
- **Polish (Phase 6)**: Depends on whichever stories were completed

### Parallel Opportunities

- T003, T007, T009 (the three initial trace tasks) can run in parallel — independent
  read-only traces of the same file, no conflicting edits yet.
- T012 and T013 (Polish) can run in parallel.

## Notes

- [P] tasks = different files/sections, no dependency on an incomplete task
- Story 1's two new behaviors (T004/T005) touch the same Phase 2 step 7 paragraph —
  sequenced, not parallel, to avoid one edit clobbering the other
- Commit after each task or logical group
- Avoid: letting FR-008's new classification rule read as inconsistent with Phase 3's
  existing app-crash precedent rather than a direct extension of it (T011's specific job)
