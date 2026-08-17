# Implementation Plan: Bug-Fix Cycle (Spec-Kit Mechanism)

**Branch**: `009-bug-fix-cycle-speckit` | **Date**: 2026-08-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/009-bug-fix-cycle-speckit/spec.md`

## Summary

Extend `webapp-uat`'s existing Phase 4 spec-kit branch and Phase 5 final report
in `.claude/skills/webapp-uat/SKILL.md`. Re-reading the current text against
every FR found it more complete than the feature description assumed —
FR-001/002/003/005/006/007/009/010 already match existing text closely, several
verbatim, because most of the cycle's structure (batching, restart threshold,
retry-budget, pause-gate re-triggering, commit granularity) lives in Phase 4's
*shared* steps 1/3/5/6, not duplicated per mechanism, and already applies to
both branches identically. Four real gaps: (1) **FR-004** — the spec-kit
branch's review-pause bullet currently reuses the direct mechanism's literal
"summary, proposed fix, affected files" phrasing verbatim, which incorrectly
implies the external tool's output is guaranteed to have that specific shape;
(2) **FR-008** — no stated behavior for whether a retry re-runs
`<bug-assess-command>` or reuses the existing slug; (3) **FR-011/FR-012** — no
stated behavior at all for a configured command itself failing to execute, and
Phase 5's existing two-way failure-mode distinction (from `UAT-04`) doesn't yet
know about this third mode; (4) **FR-013** — no stated behavior for a
discrepancy between `<bug-test-command>`'s result and the browser retest.

## Technical Context

**Language/Version**: N/A — agent operating instructions (Markdown, in `SKILL.md`).

**Primary Dependencies**: Claude Code's Skill invocation mechanism; an
externally installed Spec Kit bug-workflow extension supplying the three
configured commands — outside this feature's control, treated as a black box
whose output shape isn't assumed.

**Storage**: N/A — this feature only touches the agent instruction text.

**Testing**: Text-tracing against `SKILL.md` and a constructed example
`config.md` with three plausible command values. Live invocation is explicitly
blocked — `demo-app` deliberately uses `bug-fix-mechanism: direct` (D6), so no
project in this repo's own tooling has a real installed Spec Kit bug-workflow
extension to demonstrate against.

**Target Platform**: A Claude Code CLI session with the skill installed; macOS or
Linux.

**Project Type**: Claude Code Skill (an agent instruction set).

**Performance Goals**: N/A.

**Constraints**: MUST NOT skip or reorder the assess/fix/test command sequence
(FR-002); the high-risk pause MUST NOT be skippable by any flag (FR-003).

**Scale/Scope**: One bug-fix cycle's spec-kit-specific behavior; the cycle's
shared structure (batching, thresholds, retry budget, commit granularity) is
`UAT-04`'s scope, already done and reused here without modification.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | Traces to `spec.md`, grounded in existing Phase 4/Phase 5 text and `specs/005-bug-fix-cycle-direct/`'s already-converged spec. |
| II. Reconcile Conflicts Before Implementation | PASS | `/speckit-clarify` found zero critical ambiguities; the assessment-shape inconsistency (FR-004) was identified and its fix scoped during this planning pass, not left implicit. |
| III. Vertical-Slice Delivery | PASS | `UAT-09` is one independently testable, independently demonstrable slice (text-tracing, given the stated live-verification limitation). |
| IV. Testable Acceptance Criteria | PASS | Every requirement traces to a Given/When/Then acceptance scenario. |
| V. Reuse Before Reinvention | PASS | Reuses Phase 4's shared batching/threshold/retry/commit structure rather than duplicating it per mechanism — confirmed, not assumed, by re-reading the actual current text. |
| VI. Usability Is Not Optional | PASS | Explicit tool-invocation-failure reporting (FR-011/FR-012) instead of silent misattribution is itself a usability requirement. |
| VII. Deliberate Dependencies | PASS (trivial) | No new framework/library/dependency — the external bug-workflow tool is the target project's own choice, not this skill's dependency. |
| VIII. Automated Quality Gates | PASS, same documented interpretation as prior slices | No compiled source; Markdown lint + quickstart (text-tracing only, per the stated limitation) stand in. |
| IX. Human Approval Before Consequential Change | PASS (N/A-by-design) | High-risk and routine review pauses are identical to the direct mechanism's existing approval gates — this feature only affects who performs assess/fix/test, not approval itself. |

No violations requiring Complexity Tracking justification.

## Project Structure

### Documentation (this feature)

```text
specs/009-bug-fix-cycle-speckit/
├── plan.md, research.md, data-model.md, quickstart.md, contracts/, tasks.md
```

### Source Code (repository root)

```text
.claude/skills/webapp-uat/
└── SKILL.md   # EDIT: Phase 4 step 2's spec-kit branch (FR-004 assessment-
               #   shape correction, FR-011 tool-invocation-failure handling,
               #   FR-013 test/retest discrepancy note), Phase 4 step 5's
               #   retry text (FR-008 slug-reuse), Phase 5's final report
               #   (FR-012 third failure-mode distinction)
```

**Structure Decision**: Same as prior slices — targeted edits to existing
`SKILL.md` text, spread across Phase 4's spec-kit branch, its shared retry step,
and Phase 5's report — narrower in scope than `UAT-04` since most of the cycle's
structure is already shared and unmodified.

## Complexity Tracking

No Constitution Check violations.

## Post-Design Constitution Re-Check

No new dependency/architecture/data-model concern from Phase 1 artifacts. All nine
principles remain PASS.
