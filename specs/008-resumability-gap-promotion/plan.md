# Implementation Plan: Resumability & In-Run Gap Promotion

**Branch**: `008-resumability-gap-promotion` | **Date**: 2026-08-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/008-resumability-gap-promotion/spec.md`

## Summary

Extend `webapp-uat`'s existing Phase 0 "Resume check" and Phase 1 "Gap promotion
(R9)" sections in `.claude/skills/webapp-uat/SKILL.md`. Re-reading both against
every FR in `spec.md` found the *detection* half of resumability (FR-001–003,
FR-009–012) and the *promotion mechanics* half of gap promotion (FR-013–015)
already present, several near-verbatim — Phase 0's resume check already states
the scan condition, the three-way choice, and the `--silent` abandon default with
a report note; Phase 1's R9 text already states in-line drafting, the
`review-derived` tag, and same-pass approval inclusion. Three real gaps: (1)
**FR-004** — no stated tie-break for multiple interrupted runs existing
simultaneously; (2) **FR-005–008, FR-017** — the single largest gap: nothing in
the current text says what "resume" actually *does* once chosen (`docs/design-
history.md` R8 confirms this was never specified, only detection was); (3)
**FR-016** — no stated bound against recursively re-reviewing a newly
gap-promoted scenario within the same pass.

## Technical Context

**Language/Version**: N/A — agent operating instructions (Markdown, in `SKILL.md`).

**Primary Dependencies**: Claude Code's Skill invocation mechanism; the
filesystem state under `uat/runs/<run-id>/` (`test-plan.md`, per-scenario result
records, `final-report.md`) as the sole source of truth for what a resumed run
picks up from — no live process/browser state carries across invocations.

**Storage**: N/A — this feature reads/writes run-tracking Markdown files under
`uat/runs/`, not application data.

**Testing**: Live invocation against a deliberately interrupted run (kill the
skill after `test-plan.md` is written but before `final-report.md` exists,
ideally after at least one scenario has a recorded result) and separately against
a Phase 1 review pass with an evident, real coverage gap.

**Target Platform**: A Claude Code CLI session with the skill installed; macOS or
Linux.

**Project Type**: Claude Code Skill (an agent instruction set).

**Performance Goals**: N/A.

**Constraints**: MUST NOT re-execute a scenario with a pre-interruption recorded
result (FR-006); MUST NOT recursively re-review a gap-promoted scenario within
the same pass (FR-016).

**Scale/Scope**: One run's resume decision and continuation; one review pass's
gap-promotion behavior. `UAT-07`/`UAT-08`'s other three `Source:` tags are
already done — this completes the fourth.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | Traces to `spec.md`, grounded in existing Phase 0/Phase 1 text plus `docs/design-history.md` R8/R9. |
| II. Reconcile Conflicts Before Implementation | PASS | `/speckit-clarify` found zero critical ambiguities; the one substantive open question (resume mechanics) was resolved with a documented default in `spec.md` itself, not left implicit. |
| III. Vertical-Slice Delivery | PASS | `UAT-10` is one independently testable, independently demonstrable slice. |
| IV. Testable Acceptance Criteria | PASS | Every requirement traces to a Given/When/Then acceptance scenario. |
| V. Reuse Before Reinvention | PASS | Extends the existing Phase 0/Phase 1 sections in place; resume reads existing run-directory artifacts rather than inventing a second tracking mechanism. |
| VI. Usability Is Not Optional | PASS | Explicit reporting of automatic decisions (FR-011, FR-017) instead of silent behavior is itself a usability requirement. |
| VII. Deliberate Dependencies | PASS (trivial) | No new framework/library/dependency. |
| VIII. Automated Quality Gates | PASS, same documented interpretation as prior slices | No compiled source; Markdown lint + quickstart stand in. |
| IX. Human Approval Before Consequential Change | PASS (N/A-by-design) | Resume/abandon/fresh and gap-promoted scenarios both flow into existing approval gates (Phase 0's prompt, Phase 1's approve/adjust/cancel) — this feature only affects what's detected/proposed, not approval itself. |

No violations requiring Complexity Tracking justification.

## Project Structure

### Documentation (this feature)

```text
specs/008-resumability-gap-promotion/
├── plan.md, research.md, data-model.md, quickstart.md, contracts/, tasks.md
```

### Source Code (repository root)

```text
.claude/skills/webapp-uat/
└── SKILL.md   # EDIT: Phase 0's "Resume check" (FR-004 tie-break; FR-005–008/
               #   FR-017 resume mechanics — the substantive new content) and
               #   Phase 1's "Gap promotion (R9)" (FR-016 no-recursion bound)
```

**Structure Decision**: Same as prior slices — targeted edit to existing
`SKILL.md` text, though this slice's resume-mechanics addition is substantively
larger than `UAT-07`/`UAT-08`'s edits since it's genuinely new content, not a
symmetric extension of an existing sentence.

## Complexity Tracking

No Constitution Check violations.

## Post-Design Constitution Re-Check

No new dependency/architecture/data-model concern from Phase 1 artifacts. All nine
principles remain PASS.
