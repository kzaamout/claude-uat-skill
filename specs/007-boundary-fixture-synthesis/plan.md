# Implementation Plan: Scenario Generation — Boundary-Derived + Fixture Synthesis

**Branch**: `007-boundary-fixture-synthesis` | **Date**: 2026-08-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/007-boundary-fixture-synthesis/spec.md`

## Summary

Extend `webapp-uat`'s existing Generation mode (step 2's boundary-derived bullet,
step 3's fixture list) in `.claude/skills/webapp-uat/SKILL.md`. Most FRs already
match existing text closely: FR-001, FR-003, FR-004 (boundary-derived's per-flow,
Critical/High-only, tagged behavior) and FR-007/FR-008/FR-009 (the synthesis offer,
genuineness requirement, and `--silent` auto-synthesis) all already exist —
the last three live in Phase 0's fixture-check step, not Generation mode itself,
which is the correct place per Constitution Principle V (one synthesis mechanism,
not duplicated per-caller). Four real gaps: (1) **FR-002** — the boundary-derived
bullet lists constraint categories but never states the one-per-category-present
cardinality; (2) **FR-006** — step 3's fixture list has no stated dedup rule for a
fixture shared by multiple drafts; (3) **FR-011** — no stated behavior for
validation code that can't be read/parsed; (4) **FR-012** — no stated behavior for
a Critical/High flow with zero discoverable constraints. One important correction
made during drafting: FR-010 initially assumed synthesized fixtures follow
`UAT-06`'s run-id-suffixed cleanup discipline like DB rows — re-reading R7's exact
wording ("synthesized fixtures *tracked in the DB*" get suffixed) and Generation
mode step 3's own example (plain filenames, no run-id) showed this was backwards:
fixture files persist as reusable static assets; only a DB row referencing one
follows R7. Spec corrected before this plan was written, so FR-010 needs no
`SKILL.md` change — already consistent.

## Technical Context

**Language/Version**: N/A — agent operating instructions (Markdown, in `SKILL.md`).

**Primary Dependencies**: Claude Code's Skill invocation mechanism; the target
project's actual validation/schema/ORM code (read per-flow, at generation time, not
assumed or cataloged upfront).

**Storage**: N/A — this feature drafts scenario files and fixture files, not
application data. A synthesized fixture is a file artifact; any DB row referencing
it (out of this feature's direct control) follows `UAT-06`.

**Testing**: Live invocation against a project with a Critical/High-priority flow
carrying real validation constraints (max-length, required, enum, type), and
against `demo-app`, which deliberately ships without `sample-oversized.pdf` so
fixture synthesis can be demonstrated live.

**Target Platform**: A Claude Code CLI session with the skill installed; macOS or
Linux.

**Project Type**: Claude Code Skill (an agent instruction set).

**Performance Goals**: N/A.

**Constraints**: MUST NOT draft boundary-derived scenarios below Critical/High
priority (FR-003); a synthesized fixture MUST genuinely satisfy its claimed
constraint (FR-008).

**Scale/Scope**: One `generate` invocation's worth of drafting plus its fixture
list; spec-derived and route-gap-derived generation are `UAT-07`, already done.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | Traces to `spec.md`, grounded in existing Generation mode + Phase 0 text. |
| II. Reconcile Conflicts Before Implementation | PASS | The FR-010 run-isolation misassumption was caught and corrected in `spec.md` during drafting, before this plan was written — not left as a latent conflict. |
| III. Vertical-Slice Delivery | PASS | `UAT-08` is one independently testable, independently demonstrable slice. |
| IV. Testable Acceptance Criteria | PASS | Every requirement traces to a Given/When/Then acceptance scenario. |
| V. Reuse Before Reinvention | PASS | Fixture synthesis stays a single mechanism in Phase 0, not duplicated in Generation mode — confirmed, not just assumed, by re-reading Phase 0's existing text. |
| VI. Usability Is Not Optional | PASS | Explicit, non-blocking degradation (FR-011/FR-012) instead of erroring or drafting ungrounded generic cases is itself a usability requirement. |
| VII. Deliberate Dependencies | PASS (trivial) | No new framework/library/dependency. |
| VIII. Automated Quality Gates | PASS, same documented interpretation as prior slices | No compiled source; Markdown lint + quickstart stand in. |
| IX. Human Approval Before Consequential Change | PASS (N/A-by-design) | Boundary-derived drafts and fixture synthesis both flow into the same existing approval gates (Phase 1, Phase 0's batched fixture approval) — this feature only affects what gets proposed, not approval itself. |

No violations requiring Complexity Tracking justification.

## Project Structure

### Documentation (this feature)

```text
specs/007-boundary-fixture-synthesis/
├── plan.md, research.md, data-model.md, quickstart.md, contracts/, tasks.md
```

### Source Code (repository root)

```text
.claude/skills/webapp-uat/
└── SKILL.md   # EDIT: Generation mode step 2's boundary-derived bullet
               #   (FR-002 cardinality, FR-011 unreadable-validation skip,
               #   FR-012 zero-constraints-found) and step 3's fixture list
               #   (FR-006 dedup rule)
               # NO EDIT NEEDED: Phase 0's fixture-check step already
               #   satisfies FR-007/FR-008/FR-009 as written; R7 already
               #   satisfies the corrected FR-010 as written
```

**Structure Decision**: Same as prior slices — targeted edit to existing SKILL.md
text; this slice touches fewer sections than `UAT-07` since more of its scope
already lived correctly in Phase 0.

## Complexity Tracking

No Constitution Check violations.

## Post-Design Constitution Re-Check

No new dependency/architecture/data-model concern from Phase 1 artifacts. All nine
principles remain PASS.
