# Tasks: Bug-Fix Cycle (Spec-Kit Mechanism)

**Input**: Design documents from `/specs/009-bug-fix-cycle-speckit/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/spec-kit-bug-fix-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), no compiled source
exists — `quickstart.md`'s 3 scenarios (12 acceptance criteria) are the
documented check. **Live verification is explicitly blocked** for this slice —
`demo-app` deliberately uses `bug-fix-mechanism: direct` (D6), so text-tracing
against `SKILL.md` and a constructed example `config.md` is the achievable
completion evidence, tracked as a limitation, not silently treated as
equivalent to live verification.

**Organization**: Grouped by user story (spec.md P1/P1/P2). Most scope
(FR-001/002/003/005/006/007/009/010) already exists in `SKILL.md`, living in
Phase 4's shared (not per-mechanism) structure reused from `UAT-04`. Four
genuinely new pieces: FR-004 (assessment-shape correction), FR-008 (slug
reuse on retry), FR-011/FR-012 (tool-invocation failure handling and its
report distinction), FR-013 (test/retest discrepancy note).

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Primary file: `.claude/skills/webapp-uat/SKILL.md` (Phase 4 step 2's spec-kit
branch, Phase 4 step 5's retry text, Phase 5's final report).

---

## Phase 1: Setup

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` is on a clean git working tree (or only this session's own prior work) before this feature's edits begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude/skills/webapp-uat/SKILL.md`'s current Phase 4 step 2's spec-kit branch, step 5's retry text, and Phase 5's final report against `specs/009-bug-fix-cycle-speckit/spec.md`'s FR-001–FR-013 and `data-model.md`'s two entities. **Drift found: four gaps, narrower in scope than initially assumed by the feature description.** FR-001/002/003/005/006/007/009/010 all already match existing text closely, several verbatim — this cycle's shared structure (batching, restart threshold, retry budget, pause-gate re-triggering, commit granularity) already applies identically to both mechanisms, confirmed by direct re-read, not assumed. Missing: FR-004 (the spec-kit branch's review-pause bullet incorrectly copies the direct mechanism's specific assessment shape verbatim), FR-008 (no stated slug-reuse behavior on retry), FR-011/FR-012 (no tool-invocation-failure handling at all, and Phase 5's existing two-way distinction from `UAT-04` doesn't know about this third mode), FR-013 (no stated test/retest discrepancy handling).

**Checkpoint**: Foundation confirmed — story work can begin

---

## Phase 3: User Story 1 - A confirmed bug is assessed, fixed, and tested through the configured Spec Kit commands (Priority: P1) 🎯 MVP

**Independent Test**: Per `spec.md` US1; `quickstart.md` Scenario 1 (text-traced).

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Trace `spec.md` US1's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 4 spec-kit branch and shared batching/commit text; record pass/fail — **all 4 pass** (folded into T002)

### Implementation for User Story 1

- [X] T004 [US1] If T003 finds any gap, update Phase 4 accordingly — no gap found, no change needed

**Checkpoint**: Assess/fix/test command sequencing and batching verified, no changes required

---

## Phase 4: User Story 2 - High-risk and review-pause gates behave identically regardless of mechanism (Priority: P1)

**Independent Test**: Per `spec.md` US2; `quickstart.md` Scenario 2 (text-traced).

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T005 [P] [US2] Trace `spec.md` US2's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 4 spec-kit branch pause-gate text; record pass/fail — **AC1 (unconditional high-risk pause), AC3 (`--silent` skip scope), and AC4 (retry re-applies gates) pass; AC2 (assessment presented as-is, not assumed to match the direct mechanism's specific shape) confirmed failing** — the current text literally copies "summary, proposed fix, affected files," incorrectly implying a guaranteed shape (folded into T002)

### Implementation for User Story 2

- [X] T006 [US2] Fix FR-004's assessment-shape correction in Phase 4 step 2's spec-kit branch — present `<bug-assess-command>`'s own resulting artifact as-is at the review pause, not assumed to match the direct mechanism's summary/proposed-fix/affected-files shape — done
- [X] T007 [US2] Re-trace AC2 against the corrected text to confirm it reads as an accurate description of an external, unstandardized tool's output rather than a copy-paste of the direct mechanism's guarantee — pass

**Checkpoint**: Safety-gate parity with the direct mechanism verified, including the one correction

---

## Phase 5: User Story 3 - Retries and failures are handled explicitly, not silently assumed to succeed (Priority: P2)

**Independent Test**: Per `spec.md` US3; `quickstart.md` Scenario 3 (text-traced).

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T008 [P] [US3] Trace `spec.md` US3's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Phase 4 step 5 retry text and Phase 5's final report; record pass/fail — **AC2 (retry budget, restart threshold apply identically) passes; AC1 (slug reuse on retry), AC3 (tool-invocation failure reported and pauses the run), and AC4 (three-way report distinction) all confirmed missing**, as anticipated (folded into T002)

### Implementation for User Story 3

- [X] T009 [US3] Add FR-008's slug-reuse rule to Phase 4 step 5's retry text — a spec-kit retry reuses the existing assessment slug and re-runs `<bug-fix-command>`/`<bug-test-command>`, not `<bug-assess-command>` — done
- [X] T010 [US3] Add FR-011's tool-invocation-failure handling to Phase 4 step 2's spec-kit branch — any of the three configured commands failing to execute (not found, non-zero exit, unparseable output) is reported explicitly and pauses the run, distinct from the bug being unfixable. This pause is never skipped by `--silent` (fixed during `/speckit-analyze`: initially left unstated, corrected to match the restart-failure threshold's unconditional treatment). — done
- [X] T011 [US3] Add FR-013's test/retest discrepancy note to the same section — a disagreement between `<bug-test-command>`'s result and the browser retest is noted as additional context, without overriding the browser retest as what actually closes the bug out — done
- [X] T012 [US3] Add FR-012's three-way report distinction to Phase 5's final report — a tool-invocation failure is distinguished from a retry-budget-exhausted unresolved bug and from a restart-failure-threshold stop, extending `UAT-04`'s existing two-way distinction to three — done
- [X] T013 [US3] Re-trace AC1/AC3/AC4 against the updated text to confirm all three read as coherent additions to the existing retry/report language, not disconnected bolt-ons — pass, verified by direct re-read of SKILL.md lines 432-513

**Checkpoint**: Retry slug-reuse, tool-invocation-failure handling, and its report distinction verified

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T014 [P] Perform a manual structural check of every `SKILL.md` section touched by T006/T009/T010/T011/T012 — no Markdown linter installed (constitution Principle VII); confirm all five changes read as coherent extensions of Phase 4/Phase 5, not disconnected bolt-ons — pass, clean Markdown
- [X] T015 [P] Re-evaluate `specs/009-bug-fix-cycle-speckit/checklists/readiness.md`'s open items (CHK002, CHK004, CHK007, CHK010, CHK015) against the final edited `SKILL.md` text — none required a spec change; all five remain genuine open questions appropriate for future refinement, none safety-relevant enough to block this slice
- [X] T016 Record this slice's live-verification status explicitly — every one of T003/T005/T008's traces confirms what `SKILL.md`'s instructions say, not a live-observed spec-kit cycle. **All 3 `quickstart.md` scenarios remain text-traced only. Live verification stays blocked**, per `spec.md`'s own Assumptions — `demo-app` deliberately uses `bug-fix-mechanism: direct` (D6), and no project in this repo's own tooling has a real installed Spec Kit bug-workflow extension. Tracked explicitly as an open item for whoever next has access to one, not silently treated as done.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational only — the story with the one safety-relevant correction this cycle
- **User Story 3 (Phase 5)**: Depends on Foundational only — the story with the most new content this cycle
- **Polish (Phase 6)**: Depends on whichever stories were completed

### Parallel Opportunities

- T003, T005, T008 (the three initial trace tasks) can run in parallel —
  independent read-only traces of different `SKILL.md` sections, no conflicting
  edits yet.
- T014 and T015 (Polish) can run in parallel.

## Notes

- [P] tasks = different files/sections, no dependency on an incomplete task
- T009/T010/T011 all touch the same spec-kit branch/retry text — sequenced since
  each extends the same paragraphs and T013's re-trace checks them together for
  coherence
- Commit after each task or logical group
- Avoid: letting FR-004's correction read as weakening the review pause itself
  (it only changes what shape the presented assessment is assumed to have, not
  whether the pause happens); letting FR-011's tool-invocation-failure handling
  read as a new kind of bug-resolution outcome rather than a run-blocking
  condition requiring explicit human attention (T013's specific job)
