# Tasks: Scenario Generation — Boundary-Derived + Fixture Synthesis

**Input**: Design documents from `/specs/007-boundary-fixture-synthesis/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/boundary-fixture-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), no compiled source
exists — `quickstart.md`'s 3 scenarios (11 acceptance criteria) are the documented
check, live-verifiable against `demo-app`'s real zod validation and its
deliberately-missing `sample-oversized.pdf`.

**Organization**: Grouped by user story (spec.md P1/P2/P1). Most scope (FR-001,
FR-003, FR-004, FR-007, FR-008, FR-009) already exists in `SKILL.md` — the
synthesis-offer requirements (FR-007–009) live correctly in Phase 0, not
Generation mode. Four genuinely new pieces: FR-002 (drafting cardinality), FR-006
(fixture-list dedup), FR-011 (unreadable-validation skip), FR-012
(zero-constraints-found). FR-010 needed a spec correction, not a `SKILL.md` change
— already consistent with existing R7 text once corrected.

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Primary file: `.claude/skills/webapp-uat/SKILL.md` (Generation mode step 2's
boundary-derived bullet, step 3's fixture list; Phase 0's fixture-check step,
R7 — read-only reference for FR-010).

---

## Phase 1: Setup

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` is on a clean git working tree (or only this session's own prior work) before this feature's edits begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude/skills/webapp-uat/SKILL.md`'s current Generation mode step 2 (boundary-derived bullet), step 3 (fixture list), and Phase 0's fixture-check step against `specs/007-boundary-fixture-synthesis/spec.md`'s FR-001–FR-012 and `data-model.md`'s three entities. **Drift found: exactly the four anticipated gaps, plus one spec correction already made pre-task.** FR-001/003/004 (boundary-derived's per-flow, Critical/High-only, tagged behavior) and FR-007/008/009 (synthesis offer, genuineness, `--silent` auto-synthesis) all already match existing text — the latter three live in Phase 0, not Generation mode, confirmed correct per Constitution Principle V. Missing: FR-002 (cardinality), FR-006 (dedup), FR-011 (unreadable-validation skip), FR-012 (zero-constraints-found). FR-010 required no `SKILL.md` change — R7's existing text already matches the corrected spec wording.

**Checkpoint**: Foundation confirmed — story work can begin

---

## Phase 3: User Story 1 - Boundary-derived scenarios trace to real validation code (Priority: P1) 🎯 MVP

**Independent Test**: Per `spec.md` US1; `quickstart.md` Scenario 1.

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Trace `spec.md` US1's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Generation mode boundary-derived bullet; record pass/fail — **AC1 (per-flow, generation-time introspection) and AC3 (Critical/High-only scoping) pass; AC2 (one draft per distinct constraint category present) and AC4's traceability-to-rule half confirmed missing/underspecified**, as anticipated (folded into T002)

### Implementation for User Story 1

- [X] T004 [US1] Add FR-002's drafting cardinality to Generation mode step 2's boundary-derived bullet — at least one scenario per distinct constraint category present (max-length, required-field, enum, type-mismatch), not one generic case per flow. Also close FR-004's traceability gap found during `/speckit-analyze`: state the specific constraint value each draft targets directly in its own content — done
- [X] T005 [US1] Add FR-011's unreadable-validation-code skip to the same bullet — a flow whose validation can't be confidently read/parsed is skipped for boundary-derived generation, noted explicitly in output, rather than falling back to a generic ungrounded case — done
- [X] T006 [US1] Add FR-012's zero-constraints-found case to the same bullet — a Critical/High-priority flow with no discoverable validation constraints produces no boundary-derived draft, not treated as an error — done
- [X] T007 [US1] Re-trace AC2 and the traceability half of AC4 (both fixed by T004) against the updated text to confirm they land correctly and read as direct extensions of the existing per-flow/Critical-High-only language, not contradictions of it — pass, verified by direct re-read of SKILL.md lines 230-242

**Checkpoint**: Boundary-derived drafting cardinality and graceful degradation verified, including the three new additions

---

## Phase 4: User Story 2 - Every draft's fixture/data needs are consolidated into one structured list (Priority: P2)

**Independent Test**: Per `spec.md` US2; `quickstart.md` Scenario 2.

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T008 [P] [US2] Trace `spec.md` US2's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Generation mode step 3 fixture-list text; record pass/fail — **AC1 (structured list, filename/extension/constraint) and AC3 (seed data distinguishable) pass; AC2 (dedup for a fixture shared by multiple drafts) confirmed missing**, as anticipated (folded into T002)

### Implementation for User Story 2

- [X] T009 [US2] Add FR-006's dedup rule to Generation mode step 3's fixture list — a fixture required by multiple drafts is listed exactly once, not once per requiring draft — done
- [X] T010 [US2] Re-trace AC2 against the updated text to confirm it lands correctly and reads as a direct extension of the existing "one consolidated, structured list" language, not a contradiction of it — pass

**Checkpoint**: Fixture-list dedup verified, including the one new addition

---

## Phase 5: User Story 3 - Missing fixtures are synthesized as real, valid files through the same approval flow (Priority: P1)

**Independent Test**: Per `spec.md` US3; `quickstart.md` Scenario 3.

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T011 [P] [US3] Trace `spec.md` US3's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 0 fixture-check step and R7; record pass/fail — **AC1 (synthesis offered in the same batched approval), AC2 (genuine, parseable file), and AC3 (`--silent` auto-synthesis with a note) all pass, matching Phase 0's existing text near-verbatim; AC4 (fixture-file persistence, distinct from a referencing DB row's `UAT-06` treatment) passes once `spec.md`'s FR-010 correction is applied — verified directly against R7's exact wording, not just plausibly consistent** (folded into T002)

### Implementation for User Story 3

- [X] T012 [US3] No `SKILL.md` change required — Phase 0's fixture-check step and R7 already satisfy FR-007/FR-008/FR-009/FR-010 as written; confirmed by direct comparison during T002/T011, not assumed

**Checkpoint**: Fixture synthesis (offer, genuineness, `--silent` behavior, persistence) verified as already correctly specified — zero `SKILL.md` changes needed for this story

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T013 [P] Perform a manual structural check of every `SKILL.md` section touched by T004/T005/T006/T009 — no Markdown linter installed (constitution Principle VII); confirm all four additions read as coherent extensions of Generation mode steps 2-3, not disconnected bolt-ons — pass, clean Markdown
- [X] T014 [P] Re-evaluate `specs/007-boundary-fixture-synthesis/checklists/readiness.md`'s open items (CHK001, CHK002, CHK004, CHK007, CHK010, CHK015) against the final edited `SKILL.md` text — none required a spec change; all six remain genuine open questions appropriate for future refinement, none safety-relevant enough to block this slice
- [X] T015 Record which `quickstart.md` scenarios remain unverified beyond text-tracing — every one of T003/T008/T011's traces confirms what `SKILL.md`'s instructions say, not a live-observed `generate` run. **Scenario 3 is fully live-verifiable against `demo-app` as-is (its missing `sample-oversized.pdf` is deliberate). Scenario 1 and Scenario 2 are live-verifiable against `demo-app`'s document-creation flow, though confirming Scenario 1's below-Critical/High-priority exclusion needs a project whose priority convention marks some flow below that tier.** Tracked explicitly, not silently treated as done.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only — the story with the most real edits this cycle
- **User Story 2 (Phase 4)**: Depends on Foundational only — independent of US1/US3
- **User Story 3 (Phase 5)**: Depends on Foundational only — confirmed to need zero real edits
- **Polish (Phase 6)**: Depends on whichever stories were completed

### Parallel Opportunities

- T003, T008, T011 (the three initial trace tasks) can run in parallel —
  independent read-only traces of different `SKILL.md` sections, no conflicting
  edits yet.
- T013 and T014 (Polish) can run in parallel.

## Notes

- [P] tasks = different files/sections, no dependency on an incomplete task
- T004/T005/T006 all touch the same boundary-derived bullet — sequenced since each
  extends the same paragraph and T007's re-trace checks all three together for
  consistency
- Commit after each task or logical group
- Avoid: letting FR-002's cardinality language read as replacing the existing
  category list rather than adding a requirement on top of it; letting FR-011's
  skip language read as applying to the whole run rather than per-flow (T007's
  specific job, per the spec's own Assumptions section)
