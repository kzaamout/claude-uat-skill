# Implementation Plan: Config & Environment Bootstrap

**Branch**: `001-config-env-bootstrap` | **Date**: 2026-08-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-config-env-bootstrap/spec.md`

## Summary

Extend `webapp-uat`'s existing Setup mode (`.claude/skills/webapp-uat/SKILL.md`) so it
fully matches the clarified spec: repo-root detection with ask-don't-guess on
ambiguity, most-specific-evidence-first start/stop/port detection,
bug-fix-mechanism and spec-dir detection, three-way detected/guessed/needs-input
labeling, a propose→confirm→write flow with safe re-run, and — the one genuinely
new behavior this plan adds — best-effort, per-item failure reporting if the write
step fails partway through (FR-013), rather than requiring atomic rollback. This is
an edit to existing agent operating instructions, not new application code: nearly
all of this spec's scope is already written into `SKILL.md`'s Setup mode section
(steps 1–7); only FR-013's failure-handling behavior is net-new text.

## Technical Context

**Language/Version**: N/A — this feature is authored as agent operating instructions
(Markdown, in `SKILL.md`) that Claude Code follows when invoked, not compiled or
interpreted application code.

**Primary Dependencies**: Claude Code's Skill invocation mechanism
(`.claude/skills/webapp-uat/`); the target project's own filesystem conventions the
wizard inspects (`git`, `docker-compose.yml`/`compose.yaml`, `package.json`,
`Makefile`, `.specify/`, `specs/`).

**Storage**: Files only — `config.md`, `scripts/dev.sh`, and four `uat/`
subdirectories (`scenarios`, `runs`, `artifacts`, `fixtures`) written directly to the
target project's own filesystem. No database.

**Testing**: Live invocation of `/webapp-uat setup` against real and constructed
target repos (a fresh repo, an already-configured repo, a monorepo-nested-package
repo, and a repo with a simulated write failure), observed directly — this product
has no separate automated test suite of its own for this behavior, since verifying
it correctly *is* what the product does elsewhere for other projects. A Markdown
lint pass over the edited `SKILL.md` section is the applicable automated check here
(see Constitution Check, Principle VIII below).

**Target Platform**: A Claude Code CLI session with the skill installed, operating
against any target project's repo; macOS or Linux (Chrome integration — used
elsewhere in this skill, not by this slice — is unsupported under WSL per the
project's own `README.md`).

**Project Type**: Claude Code Skill (an agent instruction set), not a standalone
application.

**Performance Goals**: N/A — a one-time, human-paced interactive wizard; no
throughput or latency target applies.

**Constraints**: MUST NOT write to disk without explicit confirmation (FR-008); MUST
remain safe to invoke repeatedly without unreviewed side effects (FR-012); MUST NOT
start or stop the target application itself (FR-010).

**Scale/Scope**: One target project per invocation. Concurrent/simultaneous setup
runs against the same project are out of scope (flagged Outstanding/low-impact and
deliberately not resolved during `/speckit-clarify` — a single-developer CLI tool).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | This plan traces to `spec.md`, itself grounded in `SKILL.md`'s existing Setup mode section, `SETUP.md`, and `config.md.example`. |
| II. Reconcile Conflicts Before Implementation | PASS | The one identified gap (write-step failure handling) was resolved via `/speckit-clarify` before this plan; the rest of the spec restates existing, non-conflicting `SKILL.md` text. |
| III. Vertical-Slice Delivery | PASS | UAT-01 is one independently testable, independently demonstrable slice per the product roadmap; nothing else needs to exist first. |
| IV. Testable Acceptance Criteria | PASS | Every requirement traces to a Given/When/Then acceptance scenario in `spec.md`. |
| V. Reuse Before Reinvention | PASS | This plan explicitly extends the existing Setup mode section in place — it does not introduce a parallel or duplicate setup mechanism. |
| VI. Usability Is Not Optional | PASS | The detected/guessed/needs-input labeling (FR-007) and per-item failure reporting (FR-013) are usability requirements, not polish. |
| VII. Deliberate Dependencies | PASS (trivial) | No new framework, library, or major dependency is introduced by this slice. |
| VIII. Automated Quality Gates | **PASS, with documented interpretation** | This "codebase" is Markdown agent instructions, not compiled/interpreted source — there is no applicable test runner or type checker. The gate is satisfied here by (a) a Markdown lint pass over the edited section and (b) the quickstart validation scenarios below serving as this slice's repeatable, documented check, run manually since no CI exists yet for this repo. This is recorded here rather than silently treated as not applicable. |
| IX. Human Approval Before Consequential Change | PASS | FR-008 already requires explicit confirmation before any write; this slice doesn't itself make an architectural change. |

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
├── SKILL.md              # EDIT: "Setup mode" section (steps 1-7) — add FR-013's
│                          #   best-effort/per-item-failure-report behavior to step 6
├── SETUP.md               # EDIT (if the write-failure behavior needs a user-facing
│                          #   mention in the one-time checklist — confirm during Phase 1)
└── config.md.example       # no change expected — already documents every field this
                             # slice's draft proposes values for

specs/001-config-env-bootstrap/
├── plan.md                # this file
├── research.md
├── data-model.md
├── contracts/
├── quickstart.md
└── tasks.md                # /speckit-tasks output, not created by this command
```

**Structure Decision**: None of the template's generic options (single project /
web application / mobile+API) apply — this feature has no application source tree of
its own to lay out. It is a targeted edit to an existing agent instruction file
(`SKILL.md`'s already-existing Setup mode section) plus, if Phase 1 design finds a
user-facing gap, a small addition to `SETUP.md`. No new directories are created by
this feature outside the `specs/001-config-env-bootstrap/` documentation tree itself.

## Complexity Tracking

No Constitution Check violations — this section is intentionally empty.

## Post-Design Constitution Re-Check

*Performed after Phase 1 (`data-model.md`, `contracts/`, `quickstart.md`).* No new
dependency, architecture, or data-model concern was introduced by the Phase 1
artifacts — the data model is file/field documentation only, the contract describes
an existing CLI interaction, and the quickstart is a manual runbook. All nine
principles remain **PASS** as evaluated pre-design; no entries added to Complexity
Tracking.
