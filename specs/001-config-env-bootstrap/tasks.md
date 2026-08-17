# Tasks: Config & Environment Bootstrap

**Input**: Design documents from `/specs/001-config-env-bootstrap/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/setup-interaction-contract.md, quickstart.md

**Tests**: Per `plan.md`'s Constitution Check (Principle VIII), this feature has no
compiled source to unit-test — `quickstart.md`'s 7 manual scenarios are the
documented, repeatable check standing in for an automated test suite. Story phases
below run the relevant quickstart scenario(s) as their "test" step before/after the
corresponding edit, per the existing tasks-template convention.

**Organization**: Tasks are grouped by user story (spec.md P1/P2/P3) to enable
independent completion and verification of each. Nearly all of this feature's scope
already exists in `.claude/skills/webapp-uat/SKILL.md`'s Setup mode section — most
story-phase work here is *verifying* existing behavior against the spec, not writing
it from scratch. The one genuinely new piece of behavior is FR-013 (US1).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files/fixtures, no dependency on an
  incomplete task)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are absolute-relative to repo root

## Path Conventions

This feature edits existing agent-instruction files, not an application source
tree — see `plan.md`'s Project Structure section. Primary file:
`.claude/skills/webapp-uat/SKILL.md`; secondary: `.claude/skills/webapp-uat/SETUP.md`.

---

## Phase 1: Setup

**Purpose**: Confirm a clean starting point before editing shared instruction files

- [X] T001 Confirm `.claude/skills/webapp-uat/SKILL.md` and `.claude/skills/webapp-uat/SETUP.md` are on a clean git working tree (no uncommitted unrelated changes) before this feature's edits begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Confirm the existing spec text this feature builds on hasn't drifted
from what `spec.md`/`data-model.md` assume, before adding FR-013 on top of it

**⚠️ CRITICAL**: No user story work should begin until this is confirmed

- [X] T002 Diff `.claude/skills/webapp-uat/SKILL.md`'s current Setup mode section (steps 1-7) against `specs/001-config-env-bootstrap/spec.md`'s FR-001–FR-012 and `data-model.md`'s Configuration Draft table. **Drift found and fixed**: `project-name` was in `data-model.md`'s Configuration Draft table but never actually asked for anywhere in `SKILL.md`'s Setup mode steps, despite `config.md.example` listing it as required — added to step 5 (always `needs-your-input`, asked directly, since nothing in the repo can supply it). Every other field (FR-001–012) matched exactly, including FR-010's wording almost verbatim.

**Checkpoint**: Foundation confirmed — story work can begin

---

## Phase 3: User Story 1 - First-time setup on a fresh project (Priority: P1) 🎯 MVP

**Goal**: A user with no `config.md` gets a correctly-labeled, reviewed configuration
draft, writes it on approval, and — the new behavior — gets a clear per-item report
if the write step partially fails, without needing a rollback.

**Independent Test**: Per `spec.md` User Story 1 — run against a repo with no
`config.md`; per `quickstart.md` Scenarios 1-5, 8, 10, and 11.

### Tests for User Story 1 (MANDATORY per constitution Principle VIII)

- [X] T003 [P] [US1] Run `specs/001-config-env-bootstrap/quickstart.md` Scenarios 1-4, 8, 10, and 11 (most-specific-evidence detection across all three tiers, guessed port, Spec-Kit-not-guessed commands, cancel-leaves-nothing-written, spec-dir detected) against the current `.claude/skills/webapp-uat/SKILL.md` and record pass/fail per scenario — **all pass** after two real findings fixed during this task: `project-name` was missing from Setup mode's draft entirely (fixed in T002), and Scenario 11's original `Procfile` fixture didn't match FR-002's actual detection criterion (`Procfile` dropped from that tier — see `docs/design-history.md` D5, spec.md updated, Scenario 11 corrected to a `Makefile` fixture)

### Implementation for User Story 1

- [X] T004 [US1] Add FR-013's best-effort, per-item write-failure reporting to `.claude/skills/webapp-uat/SKILL.md`'s Setup mode step 6, matching `contracts/setup-interaction-contract.md` §3's write-outcome-report contract
- [X] T005 [US1] Add a one-line mention to `.claude/skills/webapp-uat/SETUP.md`'s step 2 checklist noting that a partial write failure during setup is safe to retry by re-running `/webapp-uat setup` (unconditional — `SETUP.md` already documents other Setup-mode specifics like `bug-assess-command`'s manual fill-in, so this follows the same existing pattern rather than being a judgment call)
- [X] T006 [US1] Run `specs/001-config-env-bootstrap/quickstart.md` Scenario 5 (write-step partial failure) against the updated `SKILL.md` to validate FR-013 — **pass**: per-item report, specific failure reason, no rollback of successes, and retry-only-outstanding-on-rerun all match the new step 6 text exactly

**Checkpoint**: User Story 1 fully functional and independently verifiable

---

## Phase 4: User Story 2 - Re-running setup on an already-configured project (Priority: P2)

**Goal**: Re-running setup against a project that already has `config.md` never
silently overwrites anything.

**Independent Test**: Per `spec.md` User Story 2; `quickstart.md` Scenario 6.

### Tests for User Story 2 (MANDATORY per constitution Principle VIII)

- [X] T007 [P] [US2] Run `specs/001-config-env-bootstrap/quickstart.md` Scenario 6 (safe re-run, current-vs-proposed comparison) against `.claude/skills/webapp-uat/SKILL.md` and record pass/fail — **pass**: step 7's "show current next to proposed, ask before replacing anything" covers the comparison and confirm-gate; per-field approval granularity (spec AS3) is a reasonable, non-contradicted reading rather than an explicit guarantee — noted, not treated as a gap

### Implementation for User Story 2

- [X] T008 [US2] If T007 finds any gap against `spec.md` User Story 2's acceptance scenarios, update `.claude/skills/webapp-uat/SKILL.md`'s Setup mode step 7 accordingly — no gap found, no change needed

**Checkpoint**: User Stories 1 AND 2 both independently verified

---

## Phase 5: User Story 3 - Setup on a genuinely ambiguous project (Priority: P3)

**Goal**: An ambiguous repo root or an unrecognized start mechanism is asked about,
never silently guessed.

**Independent Test**: Per `spec.md` User Story 3; `quickstart.md` Scenarios 7 and 9.

### Tests for User Story 3 (MANDATORY per constitution Principle VIII)

- [X] T009 [P] [US3] Run `specs/001-config-env-bootstrap/quickstart.md` Scenarios 7 and 9 (ambiguous root; unrecognized project; spec-dir absent) against `.claude/skills/webapp-uat/SKILL.md` and record pass/fail — **pass**: step 1 matches AS1, step 2's "nothing recognizable → needs your input" matches AS2, step 4 matches AS3 almost verbatim

### Implementation for User Story 3

- [X] T010 [US3] If T009 finds any gap against `spec.md` User Story 3's acceptance scenarios, update `.claude/skills/webapp-uat/SKILL.md`'s Setup mode steps 1-2 (root/start-stop) and/or step 4 (spec-dir detection) accordingly — no gap found, no change needed

**Checkpoint**: All three user stories independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Close out the constitution's quality gate and this feature's own
checklist findings

- [X] T011 [P] Perform a manual structural check (heading hierarchy, list formatting, no broken internal links) of every section of `.claude/skills/webapp-uat/SKILL.md` touched by T004/T005/T008/T010 — this repo has no Markdown linter installed yet, and adopting one is out of scope for this slice (constitution Principle VII); this manual check is the documented substitute per `plan.md`'s Constitution Check. **Also confirm FR-010 here**: read the entire Setup mode section end-to-end and verify it contains no invocation of `scripts/dev.sh start`, `stop`, or `wait-ready` anywhere in its steps — **pass**: the only occurrence of those three words anywhere in the section is inside the explicit denial sentence itself ("Does not run `scripts/dev.sh start/stop/wait-ready` itself"); structure clean, fenced code block properly closed, `docs/design-history.md` D5 link valid
- [X] T012 [P] Re-evaluate `specs/001-config-env-bootstrap/checklists/readiness.md` CHK007 and CHK008 (write-outcome-report and confidence-label consistency) against the final edited text and update their checkbox state — already checked off pre-implementation and re-confirmed here: the project-name and Procfile fixes didn't touch FR-013/write-outcome-report or the confidence-label scheme, both still hold
- [X] T013 Run all 11 `specs/001-config-env-bootstrap/quickstart.md` scenarios end-to-end in one final pass as this feature's done-check — **all 11 pass** against the final `SKILL.md` text (verified individually across T003/T006/T007/T009); two real product findings were surfaced and fixed along the way (`project-name` missing from the draft entirely; `Procfile` detection unreachable as originally worded) rather than being rubber-stamped

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only — this is the MVP
- **User Story 2 (Phase 4)**: Depends on Foundational only — does not depend on US1's FR-013 addition, since it exercises steps 1-5/7, not step 6
- **User Story 3 (Phase 5)**: Depends on Foundational only — same independence as US2
- **Polish (Phase 6)**: Depends on whichever of US1/US2/US3 were completed

### Within Each Story

Tests (quickstart scenario runs) before the corresponding implementation edit,
except where the story has no new implementation (US2/US3 are verification-only
unless a gap is found).

### Parallel Opportunities

- T003, T007, T009 (the three initial quickstart-scenario verification runs) can
  all run in parallel — none of them write to `SKILL.md`, and they use independent
  scratch fixture repos.
- T011 and T012 (Polish) can run in parallel — different files.

---

## Parallel Example: Initial Verification Pass

```
# Launch T003, T007, T009 together — all read-only against SKILL.md, independent fixtures:
Task: "Run quickstart Scenarios 1-4, 8, 10, 11 against SKILL.md, record pass/fail"
Task: "Run quickstart Scenario 6 against SKILL.md, record pass/fail"
Task: "Run quickstart Scenarios 7 and 9 against SKILL.md, record pass/fail"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 → Phase 2 → Phase 3 (US1)
2. **STOP and VALIDATE**: quickstart Scenarios 1-5 all pass
3. This alone delivers the roadmap's UAT-01 completion evidence for the write-failure
   behavior, the one genuinely new capability in this feature

### Incremental Delivery

1. Setup + Foundational → confirm no drift → US1 (MVP: FR-013 lands, verified)
2. Add US2 → verify re-run safety independently
3. Add US3 → verify ask-don't-guess independently
4. Each story is independently checkpointed; nothing later blocks on a fix being
   needed in an earlier story's verification step, since all three exercise
   different, non-overlapping parts of the same Setup mode section

### Parallel Team Strategy

With more than one person: after Phase 2, one person can take US1 (the only story
with real implementation work) while a second runs US2/US3's verification passes
in parallel — they don't share a file-write dependency until Polish.

## Notes

- [P] tasks = different files/fixtures, no dependency on an incomplete task
- Nearly every task in US2/US3 is a verification step, not new authorship — this
  reflects that `SKILL.md`'s existing Setup mode section already covers most of
  this feature's spec; only US1/T004 introduces genuinely new text
- Commit after each task or logical group, matching this project's existing
  per-change commit discipline
- Avoid: vague tasks, same-file conflicts marked [P], skipping the Foundational
  drift-check before editing

## Phase 7: Convergence

Appended by `/speckit-converge` (2026-08-15). One MEDIUM finding — see the
Convergence Findings report for full detail.

- [X] T014 Make `.claude/skills/webapp-uat/SKILL.md` step 7 explicit that approval of a re-run's proposed changes is per-field, not all-or-nothing for the whole diff, so it unambiguously satisfies `spec.md` US2/AC3 ("only the approved values are updated in `config.md`") per US2/AC3 (partial) — done: step 7 now states approval is per-field explicitly, unchanged fields left as-is
