# Feature Specification: Resumability & In-Run Gap Promotion

**Feature Branch**: `008-resumability-gap-promotion`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "UAT-10 -- Resumability & In-Run Gap Promotion. User outcome: An interrupted run can be resumed or deliberately abandoned rather than silently colliding with a fresh start; a coverage gap Phase 1 review notices becomes a real, approvable scenario file immediately, not a line item someone has to separately ask for. Scope included: Phase 0 resume check (scan uat/runs/ for a directory with test-plan.md but no final-report.md -- ask resume/abandon/start fresh; defaults to abandon under --silent, noted in the report); Phase 1 gap promotion (when scenario review notices a real coverage gap, draft the actual scenario file immediately, tag Source: review-derived, include it in the same approval decision as everything else under review -- not a suggestion someone has to act on separately). Scope explicitly deferred: none identified -- this is the last of the three review/generation-adjacent slices (UAT-07, UAT-08, UAT-10) and closes out that group. Dependencies: UAT-02 (done, Phase 1 review exists), UAT-01 (done, Phase 0 exists). Relevant existing specification sources: SKILL.md Phase 0 'Resume check' (already exists in some form); Phase 1 'Gap promotion (R9)' (already exists in some form); docs/design-history.md R8 (resumability), R9 (gap promotion). Completion evidence target: an interrupted run (test-plan.md written, final-report.md never written) is detected on the next invocation and the user is asked resume/abandon/start fresh, with --silent defaulting safely to abandon; a scenario review pass that notices a screen or flow with no scenario coverage produces an actual drafted, approvable scenario file tagged review-derived in the same pass, not merely a note in the review output."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - An interrupted run is detected, never silently collided with (Priority: P1)

A user whose previous `webapp-uat` invocation was interrupted (crashed, closed,
killed) before completion runs the skill again and needs the interruption
detected and surfaced — not silently ignored (losing the record of what happened)
and not silently collided with (a fresh run writing into the same run directory).

**Why this priority**: Without detection, an interrupted run's partial state is
either invisible (wasted prior work, no explanation) or actively corrupted (a new
run overwriting files an old one already wrote). This is the foundational
behavior Stories 2-3 refine. Independently testable and valuable on its own.

**Independent Test**: Can be fully tested by interrupting a run after
`test-plan.md` is written but before `final-report.md` exists, then invoking the
skill again and confirming the interrupted run is detected before anything else
happens.

**Acceptance Scenarios**:

1. **Given** `uat/runs/` contains a directory with `test-plan.md` but no
   `final-report.md`, **When** `webapp-uat` is invoked again, **Then** this is
   detected during Phase 0, before the app is started or the browser touched.
2. **Given** an interrupted run is detected, **When** the user is prompted,
   **Then** the choice offered is exactly resume / abandon / start fresh — not a
   binary continue-or-not choice.
3. **Given** `uat/runs/` contains no directory with `test-plan.md` and no
   `final-report.md`, **When** `webapp-uat` is invoked, **Then** no resume prompt
   appears — this is the normal, non-interrupted case.

---

### User Story 2 - Resuming a run actually continues it, not restarts it (Priority: P1)

A user who chooses to resume an interrupted run needs the run to genuinely
continue from where it left off — scenarios already executed and reported in the
partial state are not silently re-run, and scenarios not yet reached are — rather
than "resume" being a label on what's actually a full restart in disguise.

**Why this priority**: This is the substantive gap in what currently exists —
Phase 0's resume check already detects an interruption and offers the choice, but
nothing currently specifies what "resume" actually *does* once chosen. Without
this, offering "resume" as an option is misleading regardless of how clearly it's
presented. P1 because it's the core value the word "resumability" promises.

**Independent Test**: Can be fully tested by interrupting a run after some
scenarios have completed and their results are recorded, choosing resume on the
next invocation, and confirming already-completed scenarios are not re-executed
while remaining ones are.

**Acceptance Scenarios**:

1. **Given** a resumed run, **When** execution continues, **Then** it picks up
   using the existing `test-plan.md` and any per-scenario results already
   recorded in the interrupted run's directory — it does not regenerate or
   re-review the scenario plan from scratch.
2. **Given** a scenario already has a recorded result (pass/fail/finding) from
   before the interruption, **When** the resumed run executes, **Then** that
   scenario is not re-executed — its prior result is carried into the final
   report as-is.
3. **Given** a scenario has no recorded result yet, **When** the resumed run
   executes, **Then** it is executed normally, in the same order it would have
   run in originally.
4. **Given** a resumed run completes, **When** the final report is written,
   **Then** it covers every scenario from the original `test-plan.md` — the ones
   carried over from before the interruption and the ones executed after
   resuming — as one coherent report, not two disconnected partial ones.

---

### User Story 3 - `--silent` defaults safely to abandon, never to blind resume (Priority: P2)

A user running `webapp-uat --silent` who happens to have an interrupted prior run
needs the skill to make the safer choice automatically — starting fresh rather
than resuming unsupervised into a state nobody has reviewed — and to say so
plainly in the final report rather than silently deciding on the user's behalf.

**Why this priority**: Refines Story 1's detection behavior for the unattended
case. P2: only relevant when both an interruption exists and `--silent` is set —
a narrower condition than Stories 1-2's baseline behavior.

**Independent Test**: Can be fully tested by interrupting a run, then invoking
`webapp-uat --silent` and confirming it starts fresh automatically, with this
choice stated explicitly in the final report.

**Acceptance Scenarios**:

1. **Given** an interrupted run exists and `--silent` is set, **When**
   `webapp-uat` is invoked, **Then** it defaults to abandon-and-start-fresh
   automatically, without pausing for a prompt.
2. **Given** this automatic choice was made, **When** the final report is
   written, **Then** it states explicitly that an interrupted prior run was found
   and abandoned automatically under `--silent` — this is never a silent
   decision, only an unprompted one.
3. **Given** `--silent` is set and no interrupted run exists, **When**
   `webapp-uat` is invoked, **Then** nothing related to resumability appears in
   the final report — this is the normal case, not worth noting.

---

### User Story 4 - A coverage gap noticed during review becomes a real scenario immediately (Priority: P1)

A user whose Phase 1 scenario review notices a real coverage gap (a missing
negative path, boundary condition, or recovery scenario) needs that gap to become
an actual, drafted, approvable scenario file in the same review pass — not a note
in the review output that requires a separate follow-up request to act on.

**Why this priority**: Without in-line promotion, a noticed gap either gets lost
(nobody follows up) or costs a second round-trip to turn into real coverage —
undermining the value of noticing it in the first place. Independently testable
and valuable regardless of Stories 1-3's resumability behavior.

**Independent Test**: Can be fully tested by running Phase 1 review against a
batch of scenarios where a real gap is evident (e.g. a validated field with no
boundary-case scenario at all) and confirming an actual scenario file is drafted
and included in the same approval decision, not merely mentioned in review notes.

**Acceptance Scenarios**:

1. **Given** Phase 1 review notices a real coverage gap while reading through the
   scenarios under review, **When** the gap is identified, **Then** an actual
   scenario file is drafted immediately, using the standard template — not left
   as prose in a review summary.
2. **Given** a gap-promoted scenario is drafted, **When** it's inspected, **Then**
   its `Source:` field is tagged `review-derived`.
3. **Given** one or more gap-promoted scenarios exist alongside the scenarios
   already under review, **When** the batch is presented for approval, **Then**
   every gap-promoted scenario is included in that same approve/adjust/cancel
   decision — not a separate approval step.
4. **Given** no real coverage gap is evident during a review pass, **When**
   review completes, **Then** no gap-promoted scenario is drafted — this is not
   a mandatory quota per review.

---

### Edge Cases

- What happens when more than one interrupted run exists in `uat/runs/`
  simultaneously? The most recent one (by `run-id` timestamp) is what Phase 0
  detects and offers to resume/abandon; older interrupted runs are left as-is
  (neither auto-resumed nor auto-purged) — a project accumulating several
  interrupted runs is itself worth surfacing, but cleaning up old ones is not
  this feature's concern.
- What happens when the user chooses "start fresh" with an interrupted run
  present? The interrupted run's directory is left untouched (not deleted, not
  merged into the new run) — "start fresh" means a new `run-id` and a new
  directory, not destructive cleanup of the old one.
- What happens when a resumed run's `test-plan.md` references a scenario file
  that no longer exists on disk (deleted between the interruption and the
  resume)? That scenario is reported as unable to resume/execute, flagged
  explicitly in the final report, rather than silently dropped from the count or
  causing the whole resume to fail.
- What happens when Phase 1 review, in the course of promoting one gap, notices
  the newly-drafted gap scenario itself has a further gap (recursive gap-finding)?
  Gap promotion runs once per review pass, on the scenarios that existed when the
  pass began — a newly-promoted scenario is not itself re-reviewed for further
  gaps within the same pass, avoiding unbounded recursion; a genuinely deeper gap
  is available to be noticed on the next run's review instead.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST scan `uat/runs/` during Phase 0 for a directory
  containing `test-plan.md` but no `final-report.md`, before starting the app or
  touching the browser.
- **FR-002**: When such a directory is found, system MUST offer exactly three
  choices: resume, abandon, or start fresh.
- **FR-003**: When no such directory is found, system MUST proceed without any
  resume-related prompt.
- **FR-004**: When multiple interrupted-run directories exist, system MUST act on
  the most recent one by `run-id` and MUST NOT auto-purge or auto-merge the
  others.
- **FR-005**: When "resume" is chosen, system MUST continue using the existing
  `test-plan.md` without regenerating or re-reviewing it.
- **FR-006**: When "resume" is chosen, system MUST NOT re-execute a scenario that
  already has a recorded result from before the interruption — that result MUST
  carry forward into the final report unchanged.
- **FR-007**: When "resume" is chosen, system MUST execute every scenario with no
  recorded result, in the same order the original plan specifies.
- **FR-008**: A resumed run's final report MUST cover every scenario from the
  original `test-plan.md` as one coherent report, not separate partial reports
  for the pre- and post-interruption portions.
- **FR-009**: When "start fresh" is chosen, system MUST begin a new run under a
  new `run-id` and MUST leave the interrupted run's directory untouched.
- **FR-010**: Under `--silent`, when an interrupted run is found, system MUST
  default to abandon-and-start-fresh automatically, without pausing for a prompt.
- **FR-011**: Whenever this automatic `--silent` default is applied, the final
  report MUST state explicitly that an interrupted prior run was found and
  abandoned automatically.
- **FR-012**: Under `--silent`, when no interrupted run is found, the final
  report MUST NOT mention resumability at all.
- **FR-013**: When Phase 1 review notices a real coverage gap in the scenarios
  under review, system MUST draft an actual scenario file for it immediately,
  using the standard scenario template.
- **FR-014**: Every gap-promoted scenario MUST be tagged `Source: review-derived`.
- **FR-015**: Every gap-promoted scenario from a review pass MUST be included in
  that same approve/adjust/cancel decision as the scenarios already under review
  — not a separate approval step.
- **FR-016**: Gap promotion MUST NOT be applied recursively within the same
  review pass — a newly gap-promoted scenario is not itself re-reviewed for
  further gaps until a subsequent run.
- **FR-017**: When a resumed run's `test-plan.md` references a scenario file no
  longer present on disk, system MUST report that scenario as unable to
  resume/execute, explicitly, rather than silently omitting it or aborting the
  entire resume.

### Key Entities

- **Interrupted Run**: A `uat/runs/<run-id>/` directory containing `test-plan.md`
  but no `final-report.md`, detected during Phase 0.
- **Resume Decision**: The three-way choice offered when an Interrupted Run is
  found: **resume** (continue the interrupted run per FR-005–008); **abandon**
  (stop the invocation entirely — nothing runs, the interrupted run's directory
  is left exactly as it was, unresolved); **start fresh** (begin a new run under
  a new `run-id`, also leaving the interrupted run's directory untouched). The
  two non-resume choices differ only in whether a new run begins at all. Under
  `--silent`, defaults to abandon-and-start-fresh (i.e. both: stop treating the
  old run as active, and begin a new one) with an explicit report note.
- **Gap-Promoted Scenario**: A scenario file drafted in-line during Phase 1
  review upon noticing a real coverage gap, tagged `Source: review-derived`,
  included in the same approval decision as the rest of the batch under review.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of interrupted runs (a `test-plan.md` with no
  `final-report.md`) are detected on the next invocation, before the app starts
  or the browser is touched.
- **SC-002**: 100% of scenarios with a recorded result before an interruption are
  preserved unchanged (not re-executed) when that run is resumed.
- **SC-003**: 100% of `--silent` invocations encountering an interrupted run
  default to abandon-and-start-fresh with zero prompts, and the choice is stated
  in the final report every time.
- **SC-004**: 100% of real coverage gaps noticed during Phase 1 review produce an
  actual, approvable scenario file in the same pass — none surface only as a
  review-summary line item.

## Assumptions

- **"Real coverage gap" stays a judgment call**: like this product's other
  qualitative classifications (persona derivation in `UAT-07`, boundary-case
  category detection in `UAT-08`), what counts as a gap worth promoting during
  review is not further quantified here — consistent with R9's existing framing
  ("a missing negative path, boundary condition, or recovery scenario").
- **Resume mechanics operate on already-written result artifacts, not live
  process state**: "resuming" means reading what the interrupted run's directory
  already recorded (test plan, any per-scenario results written before the
  interruption) — it does not mean resurrecting an in-memory browser session or
  app process from the moment of interruption, which isn't recoverable across
  invocations.
- **This closes the review/generation-adjacent group**: `UAT-07`
  (spec-derived/route-gap-derived) and `UAT-08` (boundary-derived/fixture
  synthesis) are both done; this feature's gap-promotion half completes the
  fourth and final `Source:` tag (`review-derived`) referenced throughout all
  three.
