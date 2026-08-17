# Tasks: Scenario Generation — Spec-Derived + Route-Gap-Derived

**Input**: Design documents from `/specs/006-spec-route-gap-generation/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/generation-source-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), no compiled source
exists — `quickstart.md`'s 4 scenarios (13 acceptance criteria) are the documented
check, live-verifiable against a `spec-dir`-bearing project and `demo-app`'s
discoverable-routing/no-`spec-dir` state.

**Organization**: Grouped by user story (spec.md P1/P1/P2/P2). Most scope
(FR-001–FR-007, FR-011) already exists in `SKILL.md`'s Generation mode; two
genuinely new pieces: FR-008/FR-009 (symmetric routing-source-undiscoverable
degradation, and the neither-prerequisite-met case) and FR-010/FR-012 (broader
`--priority` scoping language, and the zero-eligible-flows outcome).

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

Primary file: `.claude/skills/webapp-uat/SKILL.md` (Generation mode, steps 1-2).

---

## Phase 1: Setup

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` is on a clean git working tree (or only this session's own prior work) before this feature's edits begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude/skills/webapp-uat/SKILL.md`'s current Generation mode (steps 1-2) against `specs/006-spec-route-gap-generation/spec.md`'s FR-001–FR-012 and `data-model.md`'s four entities. **Drift found: exactly the two anticipated gaps.** FR-001/002/003/004/005/006/007/011 all match existing text closely, several near-verbatim. Missing: (1) FR-008/FR-009 — step 1 states the spec-dir-unconfigured degradation but never the symmetric routing-source-undiscoverable case, nor the neither-met case; (2) FR-010/FR-012 — step 2's `--priority` bullet ties priority only to boundary-derived treatment, not spec-derived/route-gap-derived broadly, and never addresses a zero-eligible-flows outcome.

**Checkpoint**: Foundation confirmed — story work can begin

---

## Phase 3: User Story 1 - Spec-derived scenarios trace back to real acceptance criteria (Priority: P1) 🎯 MVP

**Independent Test**: Per `spec.md` US1; `quickstart.md` Scenario 1.

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Trace `spec.md` US1's 4 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Generation mode step 1 text; record pass/fail — **all 4 pass** (folded into T002)

### Implementation for User Story 1

- [X] T004 [US1] If T003 finds any gap, update Generation mode step 1 accordingly — no gap found, no change needed

**Checkpoint**: Spec-derived drafting and persona-variant behavior verified, no changes required

---

## Phase 4: User Story 2 - Route-gap-derived stubs cover screens nothing tests yet (Priority: P1)

**Independent Test**: Per `spec.md` US2; `quickstart.md` Scenario 2.

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T005 [P] [US2] Trace `spec.md` US2's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Generation mode route-gap-derived text; record pass/fail — **all 3 pass** (folded into T002)

### Implementation for User Story 2

- [X] T006 [US2] If T005 finds any gap, update Generation mode accordingly — no gap found, no change needed

**Checkpoint**: Route-gap stub drafting and no-duplicate-stub behavior verified, no changes required

---

## Phase 5: User Story 3 - Generation degrades gracefully when a source's prerequisite is missing (Priority: P2)

**Independent Test**: Per `spec.md` US3; `quickstart.md` Scenario 3.

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T007 [P] [US3] Trace `spec.md` US3's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Generation mode degradation text; record pass/fail — **AC1 (spec-dir-unconfigured degradation) passes; AC2 (routing-source-undiscoverable degradation) and AC3 (neither-met case) confirmed missing**, as anticipated (folded into T002)

### Implementation for User Story 3

- [X] T008 [US3] Add FR-008's symmetric degradation case to Generation mode step 1 — when Phase 0.5 discovery found no routing source, route-gap-derived generation is skipped, noted explicitly in output, and spec-derived generation still runs if `spec-dir` is configured — done
- [X] T009 [US3] Add FR-009's neither-prerequisite-met case to Generation mode step 1 — when neither `spec-dir` nor a discovered routing source is available, `generate` completes with an explicit note that no drafts were produced, rather than erroring — done
- [X] T010 [US3] Re-trace AC2/AC3 against the updated text to confirm both land correctly and read as a direct, symmetric extension of the existing spec-dir-unconfigured case, not a contradiction of it — pass, reads as a natural symmetric extension

**Checkpoint**: Independent per-source degradation (both directions) and the neither-met case verified, including the two new additions

---

## Phase 6: User Story 4 - Priority scoping and consistent source tagging (Priority: P2)

**Independent Test**: Per `spec.md` US4; `quickstart.md` Scenario 4.

### Tests for User Story 4 (MANDATORY per constitution Principle VIII)

- [X] T011 [P] [US4] Trace `spec.md` US4's 3 acceptance scenarios against `.claude/skills/webapp-uat/SKILL.md`'s Generation mode `--priority` and `Source:` tagging text; record pass/fail — **AC2 (universal `Source:` tagging) passes; AC1 (priority scoping tied only to boundary-derived treatment, not spec-derived/route-gap-derived broadly) and AC3 (zero-eligible-flows outcome, and independence from a narrow `scope` path) confirmed missing**, as anticipated (folded into T002)

### Implementation for User Story 4

- [X] T012 [US4] Broaden Generation mode step 2's `--priority` bullet (FR-010) to scope all active sources (spec-derived and route-gap-derived, not boundary-derived alone) to the requested priority tiers, and to state explicitly that it applies across the full `spec-dir`/routing source without requiring a narrow `scope` path — done
- [X] T013 [US4] Add FR-012's zero-eligible-flows outcome to the same bullet — `--priority` scoping that excludes every flow completes with zero drafts and an explicit note, not an error, matching US3's neither-met treatment — done
- [X] T014 [US4] Re-trace AC1/AC3 against the updated text to confirm both land correctly and don't contradict the bullet's existing boundary-derived-scoping language — pass, reads as a broadening not a replacement

**Checkpoint**: Priority scoping (broadened) and universal source tagging verified, including the two new additions

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T015 [P] Perform a manual structural check of every `SKILL.md` section touched by T008/T009/T012/T013 — no Markdown linter installed (constitution Principle VII); confirm all four additions read as coherent extensions of Generation mode steps 1-2, not disconnected bolt-ons — pass, clean Markdown, verified by direct re-read of SKILL.md lines 209-241
- [X] T016 [P] Re-evaluate `specs/006-spec-route-gap-generation/checklists/readiness.md`'s open items (CHK001, CHK002, CHK003, CHK007, CHK010, CHK015) against the final edited `SKILL.md` text — none required a spec change; all six remain genuine open questions appropriate for future refinement, none safety-relevant enough to block this slice (consistent with `/speckit-analyze`'s finding of zero CRITICAL/HIGH issues)
- [X] T017 Record which `quickstart.md` scenarios remain unverified beyond text-tracing — every one of T003/T005/T007/T011's traces confirms what `SKILL.md`'s instructions say, not a live-observed `generate` run. **Scenario 2 and Scenario 3 Part A are live-verifiable against `demo-app` as-is (discoverable routing, no `spec-dir`). Scenario 1, Scenario 3 Part B/C, and Scenario 4 need a project with a real `spec-dir` (or a deliberately routing-undiscoverable/prerequisite-free setup) constructed for the purpose.** Tracked explicitly, not silently treated as done.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational only — independent of US1/US3/US4
- **User Story 3 (Phase 5)**: Depends on Foundational only — the first story with real edits this cycle
- **User Story 4 (Phase 6)**: Depends on Foundational only — the second story with real edits this cycle
- **Polish (Phase 7)**: Depends on whichever stories were completed

### Parallel Opportunities

- T003, T005, T007, T011 (the four initial trace tasks) can run in parallel —
  independent read-only traces of the same file, no conflicting edits yet.
- T015 and T016 (Polish) can run in parallel.

## Notes

- [P] tasks = different files/sections, no dependency on an incomplete task
- T008/T009 and T012/T013 touch the same two `SKILL.md` bullets (step 1 and step 2
  respectively) — sequenced within each story since they build on each other
  directly (symmetric case then neither-met case; broadened scoping then
  zero-eligible outcome)
- Commit after each task or logical group
- Avoid: letting FR-008's symmetric case read as replacing rather than extending the
  existing spec-dir-unconfigured language (T010's specific job); letting FR-010's
  broadened `--priority` wording read as narrowing what boundary-derived scoping
  already had (T014's specific job)
