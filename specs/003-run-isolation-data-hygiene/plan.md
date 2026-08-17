# Implementation Plan: Run Isolation & Data Hygiene

**Branch**: `003-run-isolation-data-hygiene` | **Date**: 2026-08-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-run-isolation-data-hygiene/spec.md`

## Summary

Verify and extend `webapp-uat`'s existing R7 naming section, Phase 0 start-of-run
cleanup, and Phase 5 end-of-run cleanup in `.claude/skills/webapp-uat/SKILL.md` so
they fully match the clarified spec. As with the prior two features, most of this
spec's scope already exists — the naming scheme (FR-001), both purge timings
(FR-002/FR-005), both confirmations (FR-003/FR-006/FR-009/FR-010), the
unresolved-bugs-don't-block-cleanup rule (FR-007), and the generation-time seed-data
confirmation (FR-008, itself a fix made earlier this session) are all already
written. The two likely gaps, to be confirmed during `/speckit-implement`'s
diff-first step rather than assumed here: (1) the no-op/no-prompt behavior when
start-of-run cleanup finds nothing to purge (FR-004), and (2) the differentiated
decline-consequence this session's `/speckit-clarify` just established (FR-011) —
blocking the run vs. not, depending on which purge is declined.

## Technical Context

**Language/Version**: N/A — agent operating instructions (Markdown, in `SKILL.md`),
same nature as `UAT-01`/`UAT-02`.

**Primary Dependencies**: Claude Code's Skill invocation mechanism; whatever
database/data-store mechanism the target project uses for seeded data (discovered,
not assumed, per Phase 0.5 — this feature doesn't itself introduce a storage
choice).

**Storage**: The target project's own data store(s) for UAT-marked records (seeded
users, seeded rows, DB-tracked synthesized fixtures) — this feature defines the
naming/cleanup *contract* around those writes, not the storage mechanism itself.

**Testing**: Live invocation against a target project with UAT-marked data present
(interrupted-run simulation for Story 2, a real generation run for Story 4),
observed directly. Same rationale as `UAT-01`/`UAT-02`: no separate automated test
suite for this product's own behavior. Unlike `UAT-02`, this feature's core
guarantees (naming format, confirmation gating, decline consequences) are mostly
text-traceable against `SKILL.md`, since they're about *what the instructions say to
do*, not about live browser/accessibility behavior — closer to `UAT-01`'s
verifiability than `UAT-02`'s.

**Target Platform**: A Claude Code CLI session with the skill installed; macOS or
Linux.

**Project Type**: Claude Code Skill (an agent instruction set), not a standalone
application.

**Performance Goals**: N/A.

**Constraints**: MUST NOT skip any of the three DB-write confirmations under any
flag (FR-009); MUST NOT provide a way to quietly reduce them over time (FR-010);
MUST NOT purge a run's own data before its report exists (FR-005).

**Scale/Scope**: One run's worth of UAT-marked data at a time; concurrent-run
collision handling explicitly out of scope (spec Assumptions).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | Traces to `spec.md`, grounded in `SKILL.md`'s existing R7/Phase 0/Phase 5 text. |
| II. Reconcile Conflicts Before Implementation | PASS | The one identified ambiguity (decline consequence) was resolved via `/speckit-clarify` before this plan. |
| III. Vertical-Slice Delivery | PASS | `UAT-06` is one independently testable, independently demonstrable slice. |
| IV. Testable Acceptance Criteria | PASS | Every requirement traces to a Given/When/Then acceptance scenario. |
| V. Reuse Before Reinvention | PASS | Extends the existing R7/Phase 0/Phase 5 sections in place. |
| VI. Usability Is Not Optional | PASS | The no-op-when-nothing-to-purge rule (FR-004) and differentiated decline behavior (FR-011) are both usability requirements — don't nag when there's nothing to confirm, don't silently proceed when proceeding is actually risky. |
| VII. Deliberate Dependencies | PASS (trivial) | No new framework/library/dependency. |
| VIII. Automated Quality Gates | **PASS, same documented interpretation as `UAT-01`/`UAT-02`** | No compiled source; Markdown lint + quickstart validation stand in. |
| IX. Human Approval Before Consequential Change | PASS | This entire feature *is* the human-approval gate for a specific class of consequential change (database writes) — directly reinforces this principle rather than needing to satisfy it incidentally. |

No violations requiring Complexity Tracking justification.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
.claude/skills/webapp-uat/
└── SKILL.md              # EDIT (pending T002 confirmation): Phase 0's start-of-run
                           #   cleanup step (FR-004's no-op case, FR-011's
                           #   decline-blocks-the-run case) and Phase 5's
                           #   end-of-run cleanup step (FR-011's
                           #   decline-does-not-block-completion case)

specs/003-run-isolation-data-hygiene/
├── plan.md                # this file
├── research.md
├── data-model.md
├── contracts/
├── quickstart.md
└── tasks.md                # /speckit-tasks output, not created by this command
```

**Structure Decision**: Same as `UAT-01`/`UAT-02` — no application source tree, a
targeted edit to already-existing `SKILL.md` sections.

## Complexity Tracking

No Constitution Check violations — this section is intentionally empty.

## Post-Design Constitution Re-Check

*Performed after Phase 1 (`data-model.md`, `contracts/`, `quickstart.md`).* No new
dependency, architecture, or data-model concern introduced by the Phase 1 artifacts.
All nine principles remain **PASS** as evaluated pre-design.
