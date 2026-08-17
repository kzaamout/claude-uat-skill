<!--
Sync Impact Report
- Version change: 1.0.0 → 2.0.0 (MAJOR — full replacement of Core Principles)
- Modified principles: replaced wholesale, not renamed —
  OLD (v1.0.0, self-derived with no user input at the time): I. Config-Driven,
  Project-Agnostic; II. Real Browser Verification (NON-NEGOTIABLE); III.
  Human-in-the-Loop for High-Risk Actions; IV. Test Data Isolation & Untrusted
  Content; V. Transparent Confidence Labeling.
  NEW (v2.0.0, explicit user-supplied scope): I. Written Requirements Are the Source
  of Truth; II. Reconcile Conflicts Before Implementation; III. Vertical-Slice
  Delivery; IV. Testable Acceptance Criteria; V. Reuse Before Reinvention; VI.
  Usability Is Not Optional; VII. Deliberate Dependencies; VIII. Automated Quality
  Gates; IX. Human Approval Before Consequential Change.
- Added sections: Quality Gates (Section 2), Development Workflow (Section 3,
  rewritten to operationalize the new principles instead of the old ones).
- Removed sections: v1.0.0's "Additional Constraints" (permission-scope pairing,
  no-config-no-run, spec-update opt-in) — these are webapp-uat-skill operational
  rules already fully specified in SKILL.md/USAGE.md; removed from the constitution
  per this amendment's explicit instruction to keep Core Principles durable and
  general rather than a restatement of one skill's product behavior. Not a claim
  that those rules stopped being true — they remain in force where SKILL.md states
  them; they just don't belong in this document.
- Templates requiring updates:
  - ✅ .specify/templates/tasks-template.md — removed "(OPTIONAL - only if tests
    requested)" framing on every per-user-story Tests subsection and Polish's
    "Additional unit tests (if requested)" line (direct conflict with new Principle
    VIII); T003 now names type-checking alongside linting; Polish phase gained an
    explicit "tests/type-check/lint must pass" gate line.
  - ✅ .specify/templates/plan-template.md — Constitution Check gate already generic
    ("[Gates determined based on constitution file]"); no edit required.
  - ✅ .specify/templates/spec-template.md — P1/P2/P3 prioritized user-story
    structure and per-story Acceptance Scenarios already directly align with
    Principles III and IV; no edit required.
  - ✅ .specify/templates/checklist-template.md — reviewed, generic, no conflicts.
  - ✅ .claude/skills/speckit-*/SKILL.md (all ten) — reviewed, generic Spec Kit
    integration logic, no outdated principle references found.
- Follow-up TODOs: none new this amendment.
-->

# webapp-uat Constitution

## Core Principles

### I. Written Requirements Are the Source of Truth

All implementation work traces to a written, current specification or an approved
design record — a `spec.md`, a `plan.md`, or an equivalent recorded decision — never
to an unrecorded conversation, a verbal agreement, or an assumption inferred only from
reading existing code. Where no written requirement yet exists for a piece of work,
the work MUST NOT proceed until one is written down, even when the answer seems
obvious to whoever is about to build it.

**Rationale**: An undocumented decision decays the moment the conversation that
produced it is forgotten, and nobody who wasn't in the room can check it. Written
requirements are what let a disagreement be resolved by pointing at text instead of
competing memories of what was meant.

### II. Reconcile Conflicts Before Implementation

Before implementation of any feature or fix begins, any known contradiction between
its governing spec, its plan, and prior related decisions MUST be identified and
resolved explicitly — recorded as a decision, not silently picked by whichever
engineer happens to write the code first. A conflict discovered mid-implementation
halts that piece of work until it is reconciled, rather than being built around or
worked past.

**Rationale**: Two written sources that disagree are worse than one missing source —
resolving the conflict after the fact means something has already been built on the
wrong assumption; resolving it before means the work only has to happen once.

### III. Vertical-Slice Delivery

Work is decomposed and delivered as independently testable, independently
demonstrable vertical slices — each usable end-to-end on its own — rather than
horizontal layers (all data models, then all services, then all UI) that produce
nothing usable until everything is finished. Every slice carries an explicit
priority, and the highest-priority slice alone MUST constitute a viable,
demonstrable increment on its own.

**Rationale**: Horizontal layering defers all real feedback to the end of a project.
Slices mean real, working functionality exists throughout, and a lower-priority slice
can be cut or deferred without unwinding partially-built layers underneath it.

### IV. Testable Acceptance Criteria

Every user story or requirement MUST carry acceptance criteria specific and concrete
enough that someone other than its author can determine pass/fail without asking a
clarifying question — Given/When/Then scenarios, a measurable success criterion, or
equivalent. "Works correctly" or "is user-friendly" stated on their own are not
acceptance criteria; they restate the goal without making it checkable.

**Rationale**: Criteria that cannot be checked cannot be disagreed with productively —
every disagreement becomes a debate about original intent instead of a look at
whether the stated condition actually holds.

### V. Reuse Before Reinvention

Before adding a new component, utility, or abstraction, an explicit check for an
existing one that already does the job — in this codebase, or as an
already-approved dependency — is required, and reuse is preferred unless a
documented reason makes the existing option unsuitable. Shared components are built
to be genuinely reusable (clear inputs, no hidden coupling to one call site's
assumptions) from the point they're introduced, not patched into reusability later.

**Rationale**: Duplicate near-identical logic drifts apart silently over time — each
copy gets patched differently — and that drift is exactly what makes a codebase's
actual behavior untrustworthy to reason about from reading only one of the copies.

### VI. Usability Is Not Optional

Every user-facing surface — a CLI prompt, a config file, a web UI, an error message —
is designed for the person using it, not only for correctness. Ambiguous prompts,
unlabeled controls, unexplained failures, and jargon-only error output are treated as
defects, not polish deferred to later. Where a decision affects what a user sees or
does, usability is part of what "done" means for that decision, not a follow-up pass.

**Rationale**: A technically correct feature nobody can figure out how to use, or
trusts enough to run unattended, delivers none of the value it was built for.

### VII. Deliberate Dependencies

No architectural framework, library, or other major dependency is adopted without a
documented rationale — what problem it solves, what alternatives were considered, and
why this one — recorded alongside the decision, not left only in the adopter's
memory. This applies at every layer of this project, not only application code.
Swapping or removing an already-adopted dependency needs the same documented
reasoning as adopting one did.

**Rationale**: Every dependency is a standing liability — a surface this project
doesn't control, an upgrade obligation, a new failure mode. A choice made and
explained once is cheap to revisit later; a choice made silently has to be
reverse-engineered before it can even be questioned.

### VIII. Automated Quality Gates

Automated tests, type checking, and linting are wired into a repeatable check for
every codebase in this project, and a change that fails any of them does not merge.
"Tests deferred" or "tests optional, if requested" is not a valid state for work
considered done. The specific tools differ per sub-project; the requirement that all
three run automatically and gate merges does not.

**Rationale**: Manual verification doesn't scale past the person who did it, and
decays the moment they stop doing it by hand every time. Automated gates are what
make "this still works" a checkable fact instead of a claim.

### IX. Human Approval Before Consequential Change

A change with consequential architectural impact — adopting a new framework or major
dependency, a data-model or storage change, an authentication/authorization change, a
change to how a system is deployed or operated — is presented for explicit human
approval before it is built, not after the fact. "Consequential" is judged by blast
radius and reversibility, not by how much code the change happens to touch.

**Rationale**: The cost of asking first is a short pause; the cost of an unwanted
architectural decision that's already built and merged is redoing it, or living with
it.

## Quality Gates

- Every vertical slice's acceptance criteria (Principle IV) are recorded in its spec
  before implementation begins, not drafted retroactively to match whatever got
  built.
- Every sub-project's test/type-check/lint commands (Principle VIII) are documented
  in that sub-project's own setup instructions, so "run the gates" is never
  guesswork for the next person.
- A `plan.md`'s Complexity Tracking table is where Principle VII's dependency
  rationale gets recorded whenever a plan's Constitution Check flags one — not left
  as an unrecorded verbal justification.

## Development Workflow

- Vertical slices (Principle III) are tracked as prioritized user stories in each
  feature's `spec.md`, using `.specify/templates/spec-template.md`'s existing
  P1/P2/P3 structure — already aligned with this constitution, no template change
  needed there.
- Conflict reconciliation (Principle II) happens explicitly during `/speckit-clarify`
  or `/speckit-analyze`, or as a recorded decision in the relevant `spec.md`/`plan.md`
  before `/speckit-implement` runs — never silently discovered and worked around
  during implementation itself.
- Human-approval gates (Principle IX) are exercised through the existing plan-mode
  approval step for implementation plans, and are not skipped for
  architecture-adjacent work just because it wasn't packaged as a formal plan.

## Governance

This constitution supersedes conflicting guidance elsewhere in the repo for any
question of process, architecture, or delivery practice. Where a sub-project's own
documentation (e.g. `SKILL.md`, a sub-project's `README.md`) describes a behavior in
more operational detail, that detail MUST remain consistent with the principles here;
a conflict is resolved in favor of this document, and the conflicting file is updated
to match.

**Amendment procedure**: Propose the change (principle wording, addition, or
removal) with its rationale; update this file via `/speckit-constitution`, which also
re-checks `plan-template.md`, `spec-template.md`, `tasks-template.md`, and any
sub-project's own guidance docs for drift against the new wording; record the outcome
in this file's Sync Impact Report comment.

**Versioning policy** (semantic versioning applied to governance):
- **MAJOR** — a principle is removed or redefined in a backward-incompatible way.
- **MINOR** — a new principle or constraint section is added, or existing guidance is
  materially expanded.
- **PATCH** — wording, clarification, typo, or non-semantic refinement.

**Compliance review**: A plan produced by `/speckit-plan` MUST pass this
constitution's Constitution Check gate before Phase 0 research and be re-checked
after Phase 1 design; violations are recorded in that plan's Complexity Tracking
table with an explicit justification, not silently absorbed. Any change to a
sub-project's own test/lint/type-check configuration, or to what its tasks mark as
optional, MUST be checked against Principle VIII before merge.

**Version**: 2.0.0 | **Ratified**: 2026-08-14 | **Last Amended**: 2026-08-14
