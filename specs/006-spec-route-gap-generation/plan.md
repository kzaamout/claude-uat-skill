# Implementation Plan: Scenario Generation — Spec-Derived + Route-Gap-Derived

**Branch**: `006-spec-route-gap-generation` | **Date**: 2026-08-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/006-spec-route-gap-generation/spec.md`

## Summary

Extend `webapp-uat`'s existing Generation mode (`.claude/skills/webapp-uat/SKILL.md`).
FR-001–007 and FR-011 already match existing text closely. Two real gaps, confirmed
by re-reading the current text against every FR: (1) FR-008/FR-009 — the current text
only states what happens when `spec-dir` is unconfigured (spec-derived skips,
route-gap-derived still runs); it never states the symmetric case (routing source
undiscoverable → route-gap-derived skips, spec-derived still runs) or the
neither-met case; (2) FR-010/FR-012 — `--priority`'s current wording ties it only to
"which flows get boundary-derived treatment," not to spec-derived/route-gap-derived
scoping broadly, and says nothing about a zero-eligible-flows outcome.

## Technical Context

**Language/Version**: N/A — agent operating instructions (Markdown, in `SKILL.md`).

**Primary Dependencies**: Claude Code's Skill invocation mechanism; the target
project's `spec-dir` convention (if configured) and Phase 0.5's discovered routing
source (if found) — both discovered, not assumed.

**Storage**: N/A — this feature drafts scenario files, not application data.

**Testing**: Live invocation against a project with a real `spec-dir` and discoverable
routing (spec-derived path), and separately against `demo-app` (which has a
discoverable routing source but deliberately no `spec-dir` yet — exercises FR-007's
existing degradation and, once built, route-gap-derived generation for `/profile` and
the settings landing page, both deliberately left uncovered by the bundled scenarios).

**Target Platform**: A Claude Code CLI session with the skill installed; macOS or Linux.

**Project Type**: Claude Code Skill (an agent instruction set).

**Performance Goals**: N/A.

**Constraints**: MUST NOT draft a route-gap stub for an already-covered screen
(FR-006); MUST NOT error when a source's prerequisite is unmet (FR-009).

**Scale/Scope**: One `generate` invocation's worth of drafting; boundary-derived and
fixture synthesis explicitly out of scope (`UAT-08`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | Traces to `spec.md`, grounded in existing Generation mode text. |
| II. Reconcile Conflicts Before Implementation | PASS | `/speckit-clarify` found zero critical ambiguities. |
| III. Vertical-Slice Delivery | PASS | `UAT-07` is one independently testable, independently demonstrable slice. |
| IV. Testable Acceptance Criteria | PASS | Every requirement traces to a Given/When/Then acceptance scenario. |
| V. Reuse Before Reinvention | PASS | Extends the existing Generation mode section in place. |
| VI. Usability Is Not Optional | PASS | Graceful, explicit degradation (FR-007–009) instead of erroring is itself a usability requirement. |
| VII. Deliberate Dependencies | PASS (trivial) | No new framework/library/dependency. |
| VIII. Automated Quality Gates | PASS, same documented interpretation as prior slices | No compiled source; Markdown lint + quickstart stand in. |
| IX. Human Approval Before Consequential Change | PASS (N/A-by-design) | Drafts still flow into Phase 1's existing approval gate — this feature only affects what gets proposed, not approval itself. |

No violations requiring Complexity Tracking justification.

## Project Structure

### Documentation (this feature)

```text
specs/006-spec-route-gap-generation/
├── plan.md, research.md, data-model.md, quickstart.md, contracts/, tasks.md
```

### Source Code (repository root)

```text
.claude/skills/webapp-uat/
└── SKILL.md   # EDIT: Generation mode step 1 (FR-008/009 symmetric degradation)
               #   and step 2's --priority bullet (FR-010/012 broader scoping)
```

**Structure Decision**: Same as prior slices — targeted edit to existing SKILL.md text.

## Complexity Tracking

No Constitution Check violations.

## Post-Design Constitution Re-Check

No new dependency/architecture/data-model concern from Phase 1 artifacts. All nine
principles remain PASS.
