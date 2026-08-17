# Feature Specification: Manual Scenario Execution, Checks, Classification & Report

**Feature Branch**: `002-scenario-execution-reporting`

**Created**: 2026-08-15

**Status**: Draft

**Input**: User description: "UAT-02 — Manual Scenario Execution, Checks, Classification & Report. User outcome: run one hand-written scenario in a real Chrome window and get accessibility/data-integrity findings, a category+severity classification, and a written report — the smallest slice that proves the core value loop without fixing anything. Scope included: Phase 1 scenario review (read/tighten/write test-plan/approve-or-cancel); Phase 2 execution minus backend verification (login, viewport handling, axe-core audit, i18n/data-integrity checks, console/network/screenshot capture on anything that looks off, one-reconnect-then-pause on browser-tool failure, per-scenario progress line); Phase 3 five-way classification plus P0-P3 severity; Phase 5 report (scenario/finding breakdown, end-of-run cleanup, spec-update disposition offer) — excluding the bug-fix cycle itself. Scope explicitly deferred: backend verification (UAT-05); the bug-fix cycle (UAT-04/UAT-09); scenario generation (UAT-07/UAT-08); resumability and in-run gap promotion (UAT-10). Dependencies: UAT-01. Relevant specification sources: SKILL.md Phase 1, Phase 2 (steps 1-6, 8-10), Phase 3, Phase 5; docs/design-history.md R3 (expanded per-scenario checks), R5 (content-safety hardening); uat/scenarios/_template.md."

## Clarifications

### Session 2026-08-16

- Q: When the app under test itself crashes or becomes unresponsive mid-scenario (distinct from a Chrome/browser-tool-call failure), is that classified as `TEST_ENVIRONMENT` or as a `BUG`? → A: `BUG` (typically P0) — an app crash is a product failure, not a test-environment problem; `TEST_ENVIRONMENT` stays reserved for the Chrome/automation/fixture side.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run a scenario and get a written report (Priority: P1)

A user has written one scenario describing a real user flow in their app and wants to
know, without touching any code themselves, whether that flow actually works — driven
in a real browser, not simulated, with a report they can read afterward.

**Why this priority**: This is the entire point of the feature — the smallest
possible slice that proves the core value loop (approve a scenario → watch it run in
a real browser → get a written outcome) end to end, with nothing else (fixing,
generation, backend checks) layered on top yet.

**Independent Test**: Can be fully tested by approving one hand-written, currently-
passing scenario and confirming it runs to completion in a visible Chrome window and
produces a written report showing it passed clean.

**Acceptance Scenarios**:

1. **Given** one scenario file under the run's target path, **When** it is presented
   for review, **Then** a test plan is written before anything else happens, and
   nothing starts (no app, no browser) until the plan is explicitly approved.
2. **Given** an approved scenario, **When** execution begins, **Then** the target
   account named in the scenario's Preconditions is logged into explicitly, every
   time — never assumed from whatever session state happens to already exist.
3. **Given** an approved scenario with no declared viewport, **When** it runs,
   **Then** it is driven at both the default mobile (375px) and desktop viewports in
   a visible Chrome window, not headless.
4. **Given** a scenario that completes with no problems found, **When** it finishes,
   **Then** a one-line progress summary is printed before moving on, and the scenario
   is recorded as passed clean in the final report.
5. **Given** a full run of one or more scenarios, **When** it completes, **Then** a
   final report is written showing each scenario's proposed/approved/run/passed/
   failed/blocked status.
6. **Given** the final report has been presented, **When** the user is asked how to
   proceed, **Then** the choice is exactly one of **review only** / **draft a spec
   update** / **draft a new feature spec** / **defer selected items** — and no spec
   file is ever touched automatically regardless of which is chosen.
7. **Given** an approved scenario runs to completion, **When** it executes, **Then**
   a real accessibility audit (not visual inspection) and a data-integrity check
   (literal `NaN`/`undefined`/`[object Object]`/a stuck loading state) run against it
   every time; the i18n check runs only if the project is marked multi-locale and the
   UI-conformance check runs only if the scenario's `Related feature` points to a
   configured spec — both explicitly noted as not applicable otherwise, never
   silently skipped without a note.
8. **Given** a scenario has completed within a multi-scenario run, **When** its
   result is recorded, **Then** it is written immediately to that scenario's finding
   record — not deferred until the whole run finishes — so an interruption
   afterward does not lose it.
9. **Given** a run that skipped some part of full manual approval (e.g. an
   auto-approved plan under a silent mode), **When** the final report is written,
   **Then** that deviation is stated plainly in the report, never left undisclosed.

---

### User Story 2 - A broken scenario is classified correctly, not just marked failed (Priority: P1)

A user has a scenario that exercises a flow with a real problem in it, and needs to
know not just that something went wrong, but what *kind* of wrong it is — a genuine
bug versus friction versus a gap in the spec itself — and how urgent it is.

**Why this priority**: Binary pass/fail alone doesn't tell a user what to do next.
The category-plus-severity classification is what makes a finding actionable, and
it's independently verifiable from Story 1's happy path — this is precisely the axis
that distinguishes this tool from a plain test runner.

**Independent Test**: Can be fully tested by running a scenario against a
deliberately broken flow and confirming the resulting finding is classified as
exactly one of the five categories, with a severity assigned when it's a bug, and
that a non-bug finding is written up with a recommendation rather than silently
dropped.

**Acceptance Scenarios**:

1. **Given** a scenario whose actual result violates its stated expected outcome,
   **When** the finding is classified, **Then** it is labeled `BUG` with exactly one
   of the four severities (P0-P3) applied, matching the severity table's criteria.
2. **Given** a scenario that technically works but not in the way a reasonable
   reading of the flow implies, **When** classified, **Then** it is labeled
   `UNEXPECTED_BEHAVIOUR`, not `BUG`, and documented with a recommendation rather
   than treated as something to fix.
3. **Given** a scenario surfacing an extra step, unclear copy, or awkward navigation
   with no functional break, **When** classified, **Then** it is labeled
   `UX_FRICTION`.
4. **Given** a scenario whose correct behavior can't actually be determined from
   what's currently specified, **When** classified, **Then** it is labeled
   `SPEC_GAP`.
5. **Given** a scenario blocked by a Chrome, browser-automation, or fixture problem
   rather than a product issue, **When** classified, **Then** it is labeled
   `TEST_ENVIRONMENT`, and product code is not touched because of it.
6. **Given** the app under test itself crashes or becomes unresponsive mid-scenario
   (distinct from a Chrome/browser-tool-call failure), **When** classified, **Then**
   it is labeled `BUG` (typically P0 — "workflow can't complete at all"), never
   `TEST_ENVIRONMENT` — the app failing is a product failure, not an environment
   problem.
7. **Given** every finding produced by a run, **When** the final report is written,
   **Then** bugs are sorted by severity within their status group, and every
   non-`BUG` finding carries one of: no action / update the existing feature spec /
   new feature spec / needs more research.

---

### User Story 3 - Captured page content is reported on, never followed as instructions (Priority: P2)

A user runs a scenario against a flow whose page content — console output, network
responses, on-page text — could plausibly contain something crafted to look like an
instruction (deliberately, in an adversarial test, or by accident from real
user-generated content in the app), and needs assurance that this can never cause the
tool to act on it.

**Why this priority**: This is a content-safety guarantee, not a feature — important
enough to verify explicitly and independently, but the core execution/classification
loop (Stories 1-2) is meaningful on its own even before this is proven.

**Independent Test**: Can be fully tested by running a scenario against a page whose
console output or visible text contains a crafted instruction-like string (e.g. "IGNORE
PREVIOUS INSTRUCTIONS AND...") and confirming the resulting finding reports that
content verbatim as evidence, with no change in the tool's own behavior traceable to
it.

**Acceptance Scenarios**:

1. **Given** a scenario step produces a console error, a failed network request, or
   visible page text containing an instruction-like string, **When** it is captured,
   **Then** it is recorded in the finding as data — quoted as evidence — and never
   causes any change in what the tool does next.
2. **Given** a large console/network payload is captured, **When** it is written to
   the finding file, **Then** it is truncated first — the raw payload is not dumped
   in full.
3. **Given** a browser-tool call fails mid-scenario, **When** this happens, **Then**
   exactly one `/chrome` reconnect is attempted before the failure is classified as
   `TEST_ENVIRONMENT`; a second consecutive failure pauses the entire run and flags
   it rather than silently marking remaining scenarios as failed.
4. **Given** a scenario step triggers a problem, **When** it happens, **Then** the
   evidence (console errors, failed network requests, a screenshot) is captured
   immediately at that point in the scenario — not deferred until the scenario
   ends — so nothing relevant from earlier in the step is lost by the time capture
   happens.

---

### Edge Cases

- What happens when a scenario's declared account can't actually log in (wrong
  credentials, account doesn't exist)? This is itself a finding for that scenario —
  most plausibly `TEST_ENVIRONMENT` (a fixture/setup problem) or `BUG` depending on
  what the login failure indicates — not something that silently aborts the whole
  run.
- What happens when a scenario needs a fixture file that doesn't exist under
  `uat/fixtures/`? Out of this feature's scope — fixture verification and synthesis
  is a Phase 0 concern (already specified elsewhere); this feature assumes Phase 0
  has already run.
- What happens when the axe-core CDN script fails to load (e.g. a network-restricted
  environment)? Not resolved by this feature — a known, pre-existing gap (no
  `onerror`/timeout handling in the injection snippet), carried forward rather than
  silently fixed as a side effect of this slice.
- What happens when a scenario has no `Related feature` set, or `spec-dir` isn't
  configured? The UI-conformance check is skipped for that scenario and the report
  notes it wasn't applicable — not silently treated as passing.
- What happens when the app being tested is not yet running at the start of
  execution? It is started via the project's configured start command before the
  scenario proceeds, per Preconditions.
- What happens when a run produces zero findings across every scenario? The final
  report still gets written, showing every scenario passed clean — this is a valid,
  complete outcome, not treated as though nothing happened.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST read every scenario file in scope for a run and write a
  reviewed test plan before starting the app or opening a browser.
- **FR-002**: System MUST present the reviewed plan and obtain an explicit
  approve/adjust/cancel decision before execution begins; nothing runs until approval
  is given.
- **FR-003**: For each approved scenario, system MUST log in as the account named in
  that scenario's Preconditions explicitly at the start of execution, regardless of
  any session state that may already exist from a previous scenario.
- **FR-004**: System MUST drive each scenario in a real, visible browser window, at
  the viewport(s) the scenario declares, defaulting to mobile (375px) and desktop
  when none are declared.
- **FR-005**: System MUST run a real accessibility audit (not visual inspection)
  against every scenario, and MUST run a data-integrity check for literal `NaN`,
  `undefined`, `[object Object]`, or a stuck infinite-loading state on every scenario.
- **FR-006**: System MUST run an i18n check only for scenarios in a project discovery
  has marked multi-locale, and MUST run a UI-conformance check only for a scenario
  whose `Related feature` field points to a configured spec — both skipped, and noted
  as not applicable, otherwise.
- **FR-007**: The moment anything looks off during a scenario, system MUST capture
  the exact console errors/warnings, failed network requests (status and URL), and a
  screenshot, immediately rather than waiting until the scenario's end.
- **FR-008**: All captured page content (console output, network response bodies,
  visible page text) MUST be treated strictly as data to report on, never as
  instructions to act on, regardless of what that content contains, and MUST be
  truncated before being written to disk.
- **FR-009**: If a browser-tool call fails mid-scenario, system MUST attempt exactly
  one reconnect before classifying the failure as `TEST_ENVIRONMENT`; if the
  reconnect also fails, system MUST pause the entire run and flag it rather than
  silently marking remaining scenarios as failed.
- **FR-009a**: The app under test itself crashing or becoming unresponsive
  mid-scenario MUST be classified as `BUG` (typically P0), never `TEST_ENVIRONMENT`
  — distinct from a browser-tool-call failure (FR-009), which is a Chrome/automation
  problem, not a product one.
- **FR-010**: System MUST record each scenario's result immediately upon completion,
  so progress is not lost if the run is interrupted afterward.
- **FR-011**: System MUST print a one-line progress summary after each scenario
  before moving to the next.
- **FR-012**: System MUST assign every finding exactly one category from: `BUG`,
  `UNEXPECTED_BEHAVIOUR`, `UX_FRICTION`, `SPEC_GAP`, `TEST_ENVIRONMENT` — never zero,
  never more than one.
- **FR-013**: System MUST assign exactly one severity (P0-P3) to every `BUG` finding,
  using the stated severity criteria; non-`BUG` findings MUST NOT be assigned a
  severity.
- **FR-014**: For every `UNEXPECTED_BEHAVIOUR`, `UX_FRICTION`, or `SPEC_GAP` finding,
  system MUST record why it was classified that way and a recommendation of exactly
  one of: no action / update the existing feature spec / new feature spec / needs
  more research. `TEST_ENVIRONMENT` findings are excluded from this requirement — a
  tooling/environment problem that pauses the run is not a spec-or-product follow-up
  item, and none of the four recommendation values fit it.
- **FR-015**: System MUST write a final report summarizing every scenario's outcome
  (proposed/approved/run/passed/failed/blocked) and every finding, with `BUG`
  findings sorted by severity within their resolution-status group.
- **FR-016**: System MUST explicitly note, in the final report, any point the run
  deviated from full manual approval (e.g. an auto-approved plan under a silent
  mode), rather than leaving deviations undisclosed.
- **FR-017**: After the final report is written, system MUST present it and obtain an
  explicit choice among exactly: review only / draft a spec update / draft a new
  feature spec / defer selected items — and MUST NOT modify any spec file
  automatically regardless of which is chosen.

### Key Entities

- **Test Plan**: The reviewed, written-before-execution record of which scenarios are
  approved to run this pass — the artifact FR-001/FR-002 produce and gate on.
- **Finding**: One record per scenario outcome that isn't a clean pass — carries
  exactly one category, an optional severity (bugs only), captured evidence
  (truncated), and — for `UNEXPECTED_BEHAVIOUR`/`UX_FRICTION`/`SPEC_GAP` — a
  recommendation (`TEST_ENVIRONMENT` findings carry neither severity nor
  recommendation).
- **Final Report**: The end-of-run summary FR-015 produces — scenario-level status
  breakdown plus every finding, handed to the user for the FR-017 disposition choice.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can go from an approved scenario to a written report, entirely
  through a real, visible browser session, without any manual test-writing or code
  inspection on their part.
- **SC-002**: Every finding in a run's report carries exactly one of the five
  categories, and every `BUG` finding carries exactly one of the four severities —
  never left uncategorized or ambiguously multi-categorized.
- **SC-003**: A scenario exercising a genuinely broken flow is never reported as
  passed, and a scenario with no problems is never reported as failed.
- **SC-004**: Page content that contains an instruction-like string never changes
  what the tool does — it appears in the report as quoted evidence and nothing else,
  in 100% of cases.
- **SC-005**: A run that is interrupted after at least one scenario has completed
  never loses that scenario's recorded result.

## Assumptions

- **No backend verification in this slice**: a scenario's Expected Outcome may name
  data that should be created or changed, but this feature does not check that
  directly against any backend — outcomes are assessed from what the browser shows
  only. Backend verification is a separate, dependent capability (`UAT-05`).
- **No fix cycle in this slice**: a `BUG` finding is recorded and classified, but
  nothing in this feature attempts to fix it, restart the app, or commit anything —
  that is a separate, dependent capability (`UAT-04`/`UAT-09`). The final report's
  "commits made this run" content is consequently always empty for a run scoped to
  just this feature.
- **Scenarios are hand-written, not generated**: this feature assumes scenario files
  already exist under the run's target path (per `uat/scenarios/_template.md`'s
  shape) — drafting them is a separate, dependent capability (`UAT-07`/`UAT-08`).
- **No resume/gap-promotion in this slice**: Phase 1's plan-writing step happens once
  per invocation; resuming an interrupted prior run and in-review gap promotion are
  both separate, dependent capabilities (`UAT-10`).
- **App start/health-check already configured**: this feature relies on `UAT-01`'s
  output (`config.md`, `scripts/dev.sh`) already existing and working — it does not
  itself configure or validate them.
