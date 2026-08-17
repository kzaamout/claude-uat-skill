# Implementation Plan: One-Command Install

**Branch**: `010-one-command-install` | **Date**: 2026-08-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/010-one-command-install/spec.md`

## Summary

Formalize already-built, already-committed work: `.claude-plugin/marketplace.json`
(repo root) and `SKILL.md`'s Setup mode step 6 (template-copy logic). Re-reading
the current text against every FR in `spec.md` found **all 8 FRs already match
exactly**, several verbatim — this feature was built directly in a prior
session, ahead of this session's practice of running every slice through the
full Spec Kit cycle. This plan's job is retroactive formalization and gap
verification, not new design; no `SKILL.md` edit is anticipated.

## Technical Context

**Language/Version**: N/A — agent operating instructions (Markdown, in
`SKILL.md`) plus a JSON manifest (`marketplace.json`).

**Primary Dependencies**: Claude Code's plugin/marketplace system
(`/plugin marketplace add`, `/plugin install`) — external to this repo,
verified against live Claude Code docs in a prior session's research pass, not
re-verified in this planning pass.

**Storage**: N/A.

**Testing**: The `/plugin` install flow itself cannot be invoked in this
session (interactive CLI meta-command, no tool access) — text-tracing against
`SKILL.md` and `marketplace.json` is the achievable completion evidence; live
verification is explicitly blocked, per `spec.md`'s Assumptions.

**Target Platform**: A Claude Code CLI session; macOS or Linux.

**Project Type**: Claude Code Skill (an agent instruction set) plus a plugin
manifest.

**Performance Goals**: N/A.

**Constraints**: MUST NOT overwrite an existing `scripts/dev.sh`'s placeholders
from the bundled template (FR-005); a partial write-step failure MUST NOT roll
back already-successful items (FR-006).

**Scale/Scope**: One setup run's file-write behavior, plus the marketplace
manifest's schema. This is the last roadmap slice.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | Traces to `spec.md`, grounded in existing `SKILL.md`/`marketplace.json` text (built directly in a prior session, now given a written spec retroactively). |
| II. Reconcile Conflicts Before Implementation | PASS | `/speckit-clarify` found zero critical ambiguities; no conflict found between the prior direct build and this feature's FRs. |
| III. Vertical-Slice Delivery | PASS | `UAT-11` is one independently testable, independently demonstrable slice (text-tracing, given the stated `/plugin`-verification limitation). |
| IV. Testable Acceptance Criteria | PASS | Every requirement traces to a Given/When/Then acceptance scenario. |
| V. Reuse Before Reinvention | PASS | Setup mode's template-copy logic reuses the same propose→confirm→write, best-effort-not-atomic pattern already used for `config.md` — confirmed by direct re-read, not assumed. |
| VI. Usability Is Not Optional | PASS | Per-item outcome reporting (FR-007) instead of a generic success/failure is itself a usability requirement. |
| VII. Deliberate Dependencies | PASS (trivial) | Claude Code's own plugin system is the only "dependency," already the platform this skill runs on — no new adoption. |
| VIII. Automated Quality Gates | PASS, same documented interpretation as prior slices | No compiled source; Markdown/JSON, text-tracing stands in given the stated `/plugin`-verification limitation. |
| IX. Human Approval Before Consequential Change | PASS (N/A-by-design) | Setup's file writes flow into the existing propose→confirm→write gate — this feature doesn't change approval, only how files land afterward. |

No violations requiring Complexity Tracking justification.

## Project Structure

### Documentation (this feature)

```text
specs/010-one-command-install/
├── plan.md, research.md, data-model.md, quickstart.md, contracts/, tasks.md
```

### Source Code (repository root)

```text
.claude-plugin/marketplace.json   # NO EDIT NEEDED — already matches FR-001
.claude/skills/webapp-uat/
├── SKILL.md   # NO EDIT NEEDED — Setup mode step 6 already matches FR-002–008
└── templates/
    ├── dev.sh.template   # already exists, already verified present
    └── _template.md      # already exists, already verified present
```

**Structure Decision**: Unlike every prior slice this session, no `SKILL.md`
edit is anticipated — this plan verifies and formalizes already-correct,
already-committed work rather than closing a gap. `/speckit-analyze` will
confirm this expectation holds before `/speckit-implement` runs (as a no-op).

## Complexity Tracking

No Constitution Check violations.

## Post-Design Constitution Re-Check

No new dependency/architecture/data-model concern from Phase 1 artifacts. All nine
principles remain PASS.
