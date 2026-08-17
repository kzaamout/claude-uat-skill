# Implementation Plan: Bug-Fix Cycle (Direct Mechanism)

**Branch**: `005-bug-fix-cycle-direct` | **Date**: 2026-08-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/005-bug-fix-cycle-direct/spec.md`

## Summary

Verify and extend `webapp-uat`'s existing Phase 4 (`bug-fix-mechanism: direct`
branch) and Phase 5 report structure in `.claude/skills/webapp-uat/SKILL.md`. This
feature is unusually well-precedented — FR-001 through FR-012 all trace to text
already present in Phase 4 nearly verbatim. One genuine gap identified while
grounding this plan (not assumed, confirmed by re-reading the current text): FR-013
requires the final report to distinguish a whole-run stop from the
two-consecutive-restart-failure threshold from a per-bug unresolved marking from its
own retry budget — Phase 5's current report structure has only a single undivided
"unresolved" bucket, with no language separating these two distinct failure modes.

## Technical Context

**Language/Version**: N/A — agent operating instructions (Markdown, in `SKILL.md`),
same nature as `UAT-01`/`UAT-02`/`UAT-05`/`UAT-06`.

**Primary Dependencies**: Claude Code's Skill invocation mechanism; `scripts/dev.sh`
(stop/start/wait-ready); the target project's own test suite, if one exists
(discovered, not assumed).

**Storage**: N/A — this feature governs a process (assess/fix/test/restart/retest),
not data storage.

**Testing**: Live invocation against `demo-app`, whose three `DEMO_BUG_*` flags give
this feature real completion evidence — toggling one on produces exactly the kind of
BUG finding this cycle exists to fix, restart, and browser-retest.

**Target Platform**: A Claude Code CLI session with the skill installed; macOS or
Linux.

**Project Type**: Claude Code Skill (an agent instruction set), not a standalone
application.

**Performance Goals**: N/A.

**Constraints**: MUST NOT skip the high-risk pause under any flag (FR-003/FR-005);
MUST NOT restart more than once per scenario's batch of bugs (FR-008); MUST NOT
conflate the two distinct failure-mode reports (FR-013).

**Scale/Scope**: One scenario's batch of bugs per fix cycle; one run at a time.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | Traces to `spec.md`, grounded in `SKILL.md`'s existing Phase 4/Phase 5 text. |
| II. Reconcile Conflicts Before Implementation | PASS | `/speckit-clarify` found zero critical ambiguities. |
| III. Vertical-Slice Delivery | PASS | `UAT-04` is one independently testable, independently demonstrable slice. |
| IV. Testable Acceptance Criteria | PASS | Every requirement traces to a Given/When/Then acceptance scenario. |
| V. Reuse Before Reinvention | PASS | Extends the existing Phase 4/Phase 5 sections in place; no new mechanism invented. |
| VI. Usability Is Not Optional | PASS | The distinct restart-failure vs. per-bug-retry thresholds (FR-012/FR-013) exist precisely so a flaky environment doesn't get misdiagnosed as a hard bug, or vice versa — a usability/trust requirement, not just a technical one. |
| VII. Deliberate Dependencies | PASS (trivial) | No new framework/library/dependency. |
| VIII. Automated Quality Gates | **PASS, same documented interpretation as prior slices** | No compiled source; Markdown lint + quickstart validation stand in. |
| IX. Human Approval Before Consequential Change | PASS | This entire feature *is* a human-approval gate for a specific class of consequential change (unattended code fixes) — the high-risk carve-out (FR-003) directly reinforces this principle. |

No violations requiring Complexity Tracking justification.

## Project Structure

### Documentation (this feature)

```text
specs/005-bug-fix-cycle-direct/
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
└── SKILL.md              # EDIT (pending diff-first confirmation): Phase 5's final
                           #   report structure (FR-013's distinct-failure-mode
                           #   reporting — the one anticipated gap). Phase 4 itself
                           #   is expected to need no change (FR-001–012 already
                           #   match).

specs/005-bug-fix-cycle-direct/
├── plan.md                # this file
├── research.md
├── data-model.md
├── contracts/
├── quickstart.md
└── tasks.md                # /speckit-tasks output, not created by this command
```

**Structure Decision**: Same as prior slices — no application source tree, a targeted
edit to already-existing `SKILL.md` sections.

## Complexity Tracking

No Constitution Check violations — this section is intentionally empty.

## Post-Design Constitution Re-Check

*Performed after Phase 1 (`data-model.md`, `contracts/`, `quickstart.md`).* No new
dependency, architecture, or data-model concern introduced by the Phase 1 artifacts.
All nine principles remain **PASS** as evaluated pre-design.
