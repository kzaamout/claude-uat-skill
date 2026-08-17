# Feature Specification: Bug-Fix Cycle (Spec-Kit Mechanism)

**Feature Branch**: `009-bug-fix-cycle-speckit`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "UAT-09 -- Bug-Fix Cycle (Spec-Kit Mechanism). User outcome: Same fix cycle as UAT-04, but delegated to an installed Spec Kit bug-workflow extension's assess/fix/test commands instead of Claude fixing the bug in-session -- for teams that already run bug work through a Spec Kit extension and want webapp-uat's findings to flow into that same pipeline rather than a parallel one. Scope included: bug-fix-mechanism: spec-kit branch -- running the configured bug-assess-command / bug-fix-command / bug-test-command (from config.md) against a finding instead of in-session assessment; identical high-risk carve-outs (security/auth/data-deletion/architecture pause, no flag skips it) and identical review-pause behavior (REVIEW_BEFORE_FIX, --silent) as the direct mechanism; identical batching (one restart/retest per scenario's bugs), per-bug commit granularity, retry budget, and restart-failure threshold as UAT-04 -- this slice only swaps WHO performs the assess/fix/test step, not the surrounding cycle's structure. Scope explicitly deferred: none -- this is the last bug-fix-cycle slice, delegating to Spec Kit is the only mechanism variant beyond direct (UAT-04, done). Dependencies: UAT-04 (done), UAT-03 (done). Relevant existing specification sources: SKILL.md Phase 4 (bug-fix-mechanism: spec-kit branch); config.md.example; specs/005-bug-fix-cycle-direct/. Completion evidence target: expected to land specified-but-not-live-verified -- demo-app deliberately uses bug-fix-mechanism: direct (see docs/design-history.md D6), so there is no real Spec Kit bug-workflow extension installed anywhere in this repo's own tooling to demonstrate against live. Text-tracing against SKILL.md and a constructed example config.md is the achievable completion evidence for this slice; live verification is called out explicitly as blocked, not silently skipped."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A confirmed bug is assessed, fixed, and tested through the configured Spec Kit commands (Priority: P1)

A user whose project has `bug-fix-mechanism: spec-kit` configured, with an
installed Spec Kit bug-workflow extension and its three commands named in
`config.md`, needs a confirmed BUG finding to flow through that same
assess/fix/test pipeline their team already uses for other bug work — not a
parallel, Claude-in-session process that produces artifacts their existing
pipeline doesn't know about.

**Why this priority**: This is the core value of the spec-kit mechanism —
routing findings into an already-adopted pipeline instead of introducing a
second, disconnected one. Independently testable and valuable before Stories 2-3
exist.

**Independent Test**: Can be fully tested by configuring `bug-fix-mechanism:
spec-kit` with three named commands, triggering a BUG finding, and confirming
each command runs in order against the finding with the resulting artifacts
(assessment, fix, test result) traceable to the tool's own output rather than an
in-session write-up.

**Acceptance Scenarios**:

1. **Given** `bug-fix-mechanism: spec-kit` and all three commands configured,
   **When** a BUG finding needs fixing, **Then** `<bug-assess-command>` runs
   against the finding file and produces an identifier (a slug) that the
   subsequent fix and test steps reference.
2. **Given** an assessment slug exists for a bug, **When** the fix proceeds,
   **Then** `<bug-fix-command>` runs with that slug, followed by
   `<bug-test-command>` with the same slug — in that order, not concurrently or
   reversed.
3. **Given** a completed spec-kit cycle for a bug, **When** the bug is
   committed, **Then** the commit includes the bug-workflow tool's own records
   alongside the fix and finding file — not just the code change on its own.
4. **Given** the same scenario surfaces multiple BUG findings, **When** they are
   fixed under `bug-fix-mechanism: spec-kit`, **Then** every bug goes through its
   own assess/fix/test cycle individually, still sharing one restart/retest for
   the whole batch — identical batching to the direct mechanism.

---

### User Story 2 - High-risk and review-pause gates behave identically regardless of mechanism (Priority: P1)

A user relying on `bug-fix-mechanism: spec-kit` needs the same safety guarantees
as the direct mechanism — a security/auth/data-deletion/architecture-scoped bug
always pauses for human sign-off, and routine bugs respect `REVIEW_BEFORE_FIX`/
`--silent` — regardless of which mechanism is doing the actual fixing.

**Why this priority**: Safety gates that only apply to one mechanism would be a
real, exploitable gap — a team using spec-kit shouldn't get weaker human-approval
guarantees than a team using direct. P1: this is a safety requirement, not a
refinement.

**Independent Test**: Can be fully tested by triggering a high-risk-scoped bug
under `bug-fix-mechanism: spec-kit` with both `--silent` and
`--no-review-before-fix` set, and confirming the pause still happens before
`<bug-fix-command>` runs.

**Acceptance Scenarios**:

1. **Given** `bug-fix-mechanism: spec-kit` and a bug whose assessed scope
   touches security, auth, data deletion/migration, or broad architectural
   impact, **When** the fix cycle reaches that bug, **Then** it pauses
   unconditionally before `<bug-fix-command>` runs — no flag skips this,
   identical to the direct mechanism.
2. **Given** a routine (non-high-risk) bug and `REVIEW_BEFORE_FIX` on, **When**
   the assessment (`<bug-assess-command>`'s output) is ready, **Then** it is
   presented for a proceed/adjust/skip decision before `<bug-fix-command>` runs
   — using whatever assessment artifact the configured tool actually produces,
   not a format assumed to match the direct mechanism's in-session write-up.
3. **Given** `--silent` is set for a routine bug, **When** the assessment is
   ready, **Then** the review pause is skipped and the cycle proceeds directly
   to `<bug-fix-command>` — the high-risk pause from AC1 is never skipped by
   this flag regardless.
4. **Given** a bug's retry cycle (Story 3) re-enters the pause gates, **When**
   the retry proceeds, **Then** the same unconditional high-risk pause and
   routine review-pause behavior apply again — no carried-forward approval from
   the original attempt, identical to the direct mechanism's existing rule.

---

### User Story 3 - Retries and failures are handled explicitly, not silently assumed to succeed (Priority: P2)

A user whose spec-kit cycle hits a failed retest, or whose configured command
itself fails to run (not found, non-zero exit, or similar), needs that handled
explicitly — a retry that's clear about whether it re-assesses from scratch or
reuses the existing assessment, and a tool-invocation failure that's reported
plainly rather than silently treated as if the bug were fixed or the run
continuing normally.

**Why this priority**: Without explicit retry/failure semantics specific to an
external tool dependency, a spec-kit cycle could either loop on a broken
assumption (re-running the same failing command indefinitely) or silently
misreport a tool failure as something else. P2: refines Story 1's cycle rather
than standing alone — only relevant once a cycle is already running.

**Independent Test**: Can be fully tested by (a) forcing a bug's browser retest
to fail after a fix, confirming the retry cycle's assessment-reuse behavior; and
separately (b) making one of the three configured commands fail to execute (bad
path, non-zero exit), confirming this is reported explicitly rather than
silently proceeding.

**Acceptance Scenarios**:

1. **Given** a bug's browser retest fails after a spec-kit fix attempt, **When**
   a retry cycle begins, **Then** it reuses the existing assessment slug and
   runs `<bug-fix-command>`/`<bug-test-command>` again against it — it does not
   re-run `<bug-assess-command>` from scratch, since the underlying finding
   hasn't changed.
2. **Given** the per-bug retry budget (2 further cycles) is exhausted under
   `bug-fix-mechanism: spec-kit`, **When** the bug is still unresolved, **Then**
   it is marked unresolved and the run continues with independent scenarios —
   identical to the direct mechanism's existing behavior.
3. **Given** any of `<bug-assess-command>`, `<bug-fix-command>`, or
   `<bug-test-command>` fails to execute (command not found, non-zero exit,
   unexpected output it can't parse), **When** this is detected, **Then** it is
   reported explicitly as a tool-invocation failure — distinct from the bug
   being genuinely unfixable — and the run pauses to flag it rather than
   silently treating the bug as resolved, abandoned, or continuing as if nothing
   happened.
4. **Given** a tool-invocation failure is flagged, **When** the final report is
   written, **Then** it names which command failed and for which bug, distinct
   from an ordinary retry-budget-exhausted unresolved bug or a
   restart-failure-threshold stop.

---

### Edge Cases

- What happens when `<bug-assess-command>`'s output can't be mapped to the
  "summary, proposed fix, affected files" shape the review pause presents for
  the direct mechanism? The review pause presents whatever the tool's own
  assessment artifact actually contains — this feature does not require the
  external tool's output to be reshaped or reformatted to match the direct
  mechanism's in-session write-up structure.
- What happens when the bug-workflow tool's own test command reports failure
  but the subsequent browser retest passes (or vice versa)? The browser retest
  is what closes a bug out, per the cycle's existing shared step — an automated
  result from `<bug-test-command>` alone, in either direction, does not
  override that; a discrepancy between the two is noted in the commit/report as
  additional context, not treated as a blocking contradiction.
- What happens when this feature can't be live-verified because no project in
  this repo's own tooling has a real Spec Kit bug-workflow extension installed?
  This is stated explicitly as a completion-evidence limitation (Assumptions),
  not silently treated as equivalent to live verification.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Under `bug-fix-mechanism: spec-kit`, system MUST run
  `<bug-assess-command>` against a BUG finding's file to produce an assessment
  identifier (slug).
- **FR-002**: System MUST run `<bug-fix-command>` with that slug, followed by
  `<bug-test-command>` with the same slug, in that order.
- **FR-003**: A bug whose assessed scope touches security, authentication, data
  deletion/migration, or broad architectural impact MUST pause unconditionally
  before `<bug-fix-command>` runs — no flag skips this, identical to the direct
  mechanism.
- **FR-004**: For a routine bug with `REVIEW_BEFORE_FIX` on, system MUST present
  `<bug-assess-command>`'s own resulting assessment artifact for a
  proceed/adjust/skip decision before `<bug-fix-command>` runs — MUST NOT
  require or assume this artifact matches the direct mechanism's specific
  summary/proposed-fix/affected-files shape.
- **FR-005**: Under `--silent`, the routine review pause (FR-004) MUST be
  skipped; the high-risk pause (FR-003) MUST NOT be skipped by this flag under
  any circumstance.
- **FR-006**: When multiple BUG findings come from the same scenario, each MUST
  go through its own assess/fix/test cycle individually, while still sharing one
  restart/retest for the whole batch — identical batching to the direct
  mechanism.
- **FR-007**: A committed spec-kit-fixed bug MUST include the bug-workflow
  tool's own records alongside the fix and finding file in that bug's commit.
- **FR-008**: When a bug's browser retest fails after a spec-kit fix attempt, a
  retry cycle MUST reuse the existing assessment slug and re-run
  `<bug-fix-command>`/`<bug-test-command>` — MUST NOT re-run
  `<bug-assess-command>` from scratch for the same finding.
- **FR-009**: Each retry cycle MUST re-apply FR-003's and FR-004's pause gates
  in full — no approval from a prior attempt carries forward, identical to the
  direct mechanism's existing rule.
- **FR-010**: The per-bug retry budget (up to 2 further cycles) and the
  two-consecutive-restart-failure threshold MUST apply identically to the
  spec-kit mechanism as they do to the direct mechanism.
- **FR-011**: When `<bug-assess-command>`, `<bug-fix-command>`, or
  `<bug-test-command>` fails to execute (not found, non-zero exit, unparseable
  output), system MUST report this explicitly as a tool-invocation failure,
  distinct from the bug itself being unfixable, and MUST pause the run to flag
  it rather than silently treating the bug as resolved or continuing
  unattended. This pause MUST NOT be skipped by `--silent` under any
  circumstance — identical in this respect to the restart-failure threshold,
  since both represent something outside the bug itself breaking, not a
  routine decision `--silent` is meant to streamline.
- **FR-012**: The final report MUST distinguish a tool-invocation failure
  (FR-011) from a retry-budget-exhausted unresolved bug and from a
  restart-failure-threshold stop — three separate failure modes, never
  conflated under one undivided label.
- **FR-013**: A discrepancy between `<bug-test-command>`'s own result and the
  subsequent browser retest's result MUST be noted as additional context in the
  commit/report, and MUST NOT override the browser retest as the mechanism that
  actually closes a bug out.

### Key Entities

- **Spec-Kit Assessment**: The output of `<bug-assess-command>` run against a
  finding — an identifier (slug) plus whatever assessment artifact the
  configured tool produces, referenced by the subsequent fix/test commands and,
  where applicable, presented at the routine review pause.
- **Tool-Invocation Failure**: A distinct failure mode where one of the three
  configured commands itself fails to execute, reported explicitly and
  distinguished in the final report from an unresolved bug or a restart
  failure.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of BUG findings fixed under `bug-fix-mechanism: spec-kit` are
  routed through all three configured commands, in order, with no step skipped
  or reordered.
- **SC-002**: 100% of high-risk-scoped bugs under `bug-fix-mechanism: spec-kit`
  pause for human sign-off before any fix command runs, regardless of `--silent`
  or `--no-review-before-fix`.
- **SC-003**: 100% of bug retries under `bug-fix-mechanism: spec-kit` reuse the
  existing assessment slug rather than re-running assessment from scratch.
- **SC-004**: 100% of tool-invocation failures are reported as their own
  distinct failure mode in the final report, never conflated with an unresolved
  bug or a restart-failure stop.

## Assumptions

- **Expected to land specified-but-not-live-verified**: `demo-app` deliberately
  uses `bug-fix-mechanism: direct` (see `docs/design-history.md` D6), so no
  project in this repo's own tooling has a real Spec Kit bug-workflow extension
  installed to demonstrate this feature against live. Completion evidence for
  this slice is text-tracing against `SKILL.md` and a constructed example
  `config.md` with three plausible command values — live verification is
  explicitly blocked, not silently skipped, and is called out as an open item
  for whoever next has access to a real installed extension.
- **This is the last bug-fix-cycle slice**: `UAT-04` (direct) and this feature
  (spec-kit) are the only two `bug-fix-mechanism` values this product supports;
  no further mechanism variant is anticipated or deferred.
- **The external tool's assessment artifact shape is not standardized by this
  feature**: unlike the direct mechanism, where Claude's in-session write-up is
  guaranteed to have a summary/proposed-fix/affected-files shape, a Spec Kit
  bug-workflow extension's actual output format is whatever that specific tool
  produces — this feature presents it as-is rather than imposing a shape on it.
