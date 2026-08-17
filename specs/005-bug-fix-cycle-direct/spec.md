# Feature Specification: Bug-Fix Cycle (Direct Mechanism)

**Feature Branch**: `005-bug-fix-cycle-direct`

**Created**: 2026-08-16

**Status**: Draft

**Input**: User description: "UAT-04 — Bug-Fix Cycle (Direct Mechanism). User outcome: a confirmed BUG finding gets stopped, assessed, optionally paused for review, fixed, restarted, and retested in the browser -- not just re-run as an automated test -- before being considered resolved, with no external bug-workflow tool required. Scope included: stop-assess-(optional pause)-fix-test-restart-browser-retest-per-bug-commit cycle; multi-bug-per-scenario batching (one restart/retest covering every bug from that scenario); high-risk carve-outs (security/auth/data-deletion/architecture) that no flag can skip; two-consecutive-restart-failure abort; per-bug retry budget (2 more cycles before marking unresolved). Scope explicitly deferred: Spec-Kit delegation (UAT-09). Dependencies: UAT-02, UAT-03. Relevant existing specification sources: SKILL.md Phase 4 (bug-fix-mechanism: direct branch); docs/design-history.md 'Phase 4 clarification -- multiple bugs from one scenario'; D4."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A confirmed bug only counts as fixed after a real browser retest (Priority: P1)

A user's run finds a genuine BUG. They need it stopped, assessed, fixed, and then
proven fixed by actually driving the same scenario steps in the browser again after
a restart — not just trusting that the code change looks right or that an automated
test passes.

**Why this priority**: This is the entire value proposition of the fix cycle — a
fix that "looks right" but wasn't actually re-verified in the real app is not
meaningfully different from not fixing it at all. Independently testable and
valuable on its own, even before Stories 2-4 exist.

**Independent Test**: Can be fully tested by seeding a single, deliberately broken
scenario (e.g. `demo-app` with one `DEMO_BUG_*` flag on), running it, and confirming
the fix cycle stops the app, produces an assessment, fixes the code, restarts, and
re-drives the exact scenario steps in Chrome before considering it resolved.

**Acceptance Scenarios**:

1. **Given** a scenario surfaces a BUG finding, **When** Phase 4 begins for it,
   **Then** the app is stopped before any fix is attempted.
2. **Given** `bug-fix-mechanism: direct` is configured, **When** the bug is assessed,
   **Then** the assessment is produced in-session (root cause, proposed fix, affected
   files) without invoking any external bug-workflow tool.
3. **Given** a fix has been made and the app restarted successfully, **When** the fix
   is verified, **Then** verification is the exact original scenario steps re-driven
   in a real Chrome browser — an automated test passing alone does not close out the
   bug.
4. **Given** a project's existing test suite covers the affected area, **When** the
   fix is made, **Then** that test suite is run as an additional check, scoped to the
   affected area — but the browser retest (Scenario 3) still runs regardless of the
   automated test's result.
5. **Given** no relevant automated test suite exists for the affected area, **When**
   the fix is verified, **Then** the finding notes that the browser retest is this
   fix's only verification, rather than silently treating "no test suite" as "nothing
   to verify."
6. **Given** the browser retest passes, **When** the fix is finalized, **Then** it is
   committed as its own commit — the fix, any regression test, and the finding file
   together.

---

### User Story 2 - Multiple bugs from one scenario share a single restart/retest (Priority: P1)

A user's scenario surfaces more than one BUG finding at once. They need all of them
assessed and fixed before one shared restart and one shared retest — not a separate
stop/start/retest cycle per bug, which would multiply run time for no verification
benefit when the bugs come from the same scenario.

**Why this priority**: Directly shapes how long a run takes when multiple bugs
surface together, and is explicit, deliberate existing product behavior (not an
oversight) — worth being just as rigorously specified as the single-bug case.

**Independent Test**: Can be fully tested by seeding a scenario with two
simultaneously-broken behaviors (two `DEMO_BUG_*` flags on at once, if their effects
are both reachable in one scenario, or two scenarios sharing one broken code path),
confirming both are assessed and fixed before any restart happens, and that exactly
one restart/retest cycle covers both.

**Acceptance Scenarios**:

1. **Given** a scenario surfaces more than one BUG finding, **When** Phase 4 begins,
   **Then** every BUG from that scenario is assessed and fixed before the app is
   restarted — not one restart per bug.
2. **Given** all bugs from the scenario have been fixed, **When** the app restarts,
   **Then** exactly one browser retest is performed, covering every bug fixed in this
   cycle within that single pass through the scenario's steps.
3. **Given** the shared retest completes, **When** results are recorded, **Then**
   each bug is still committed separately (Story 1 Scenario 6) even though the
   restart and retest were shared, not bundled into one combined commit.

---

### User Story 3 - High-risk bugs always pause for human sign-off (Priority: P2)

A user's run finds a bug touching security, authentication, data deletion/migration,
or broad architectural impact. They need this to always stop and ask before any fix
is attempted — regardless of `--silent`, `--review-before-fix` settings, or any other
flag — because an unattended fix to this class of code carries a materially higher
risk than a routine bug.

**Why this priority**: This is the safety backstop for the entire automated fix
cycle — without it, a sufficiently permissive flag combination could let this skill
modify security-sensitive code with no human ever reviewing the change. Lower
priority than Stories 1-2 only because it's a carve-out on top of a cycle that must
already exist, not a standalone capability.

**Independent Test**: Can be fully tested by seeding a bug in a security/auth-adjacent
code path (e.g. `demo-app`'s permission-bypass seeded bug) and running with every
combination of `--silent` and `--no-review-before-fix`, confirming the pause happens
every time regardless.

**Acceptance Scenarios**:

1. **Given** a BUG finding touches security, authentication, data deletion/migration,
   or broad architectural impact, **When** Phase 4 reaches it, **Then** the run
   always stops and asks for sign-off before any fix is attempted.
2. **Given** `--silent` is passed, **When** a high-risk bug is reached, **Then** the
   pause still happens — `--silent` has no effect on this specific pause.
3. **Given** `--no-review-before-fix` is passed, **When** a high-risk bug is reached,
   **Then** the pause still happens — this flag only affects the *routine*
   review pause (Story 1's assessment step for non-high-risk bugs), not this one.
4. **Given** a non-high-risk bug with `REVIEW_BEFORE_FIX` on, **When** it is assessed,
   **Then** the routine pause presents the assessment and offers **proceed / adjust /
   skip this bug** — distinct from the high-risk pause, which is not skippable by any
   flag at all.

---

### User Story 4 - Retry budgets and failure thresholds keep the cycle from looping forever (Priority: P2)

A user's fix attempt doesn't resolve a bug on the first retest, or the app itself
fails to restart cleanly. They need the skill to retry a reasonable, bounded number
of times for a genuinely hard-to-fix bug, but to recognize — faster, and
separately — when the *environment itself* is breaking rather than one bug being
difficult, so a flaky restart doesn't get treated the same as 100 failed fix attempts.

**Why this priority**: Without bounded retries, a genuinely stubborn bug could stall
a run indefinitely; without a tighter, separate threshold for restart failures, an
environment problem gets misdiagnosed as a hard bug and burns through the same retry
budget for the wrong reason. Priority P2: refines Stories 1-2's cycle rather than
being independently valuable before they exist.

**Independent Test**: Can be fully tested by seeding a bug whose "fix" deliberately
doesn't resolve it, confirming exactly 2 additional diagnose/fix cycles are attempted
before it's marked unresolved; separately, by forcing two consecutive restart
failures and confirming the whole run stops rather than continuing to retry that one
bug.

**Acceptance Scenarios**:

1. **Given** a bug's browser retest still fails after the first fix attempt, **When**
   this happens, **Then** up to 2 more diagnose/fix cycles are attempted for that
   specific bug before it is marked unresolved. Each retry cycle re-applies the same
   pause gates (the unconditional high-risk pause, and the routine
   `REVIEW_BEFORE_FIX` pause if applicable) as the first attempt — approval for one
   fix attempt is not carried forward as approval for a subsequent retry.
2. **Given** a bug is marked unresolved after exhausting its retry budget, **When**
   the run continues, **Then** it proceeds with independent scenarios rather than
   blocking the entire run on that one bug.
3. **Given** two consecutive restart failures occur (a `wait-ready` timeout following
   both a stop and a fresh start), **When** this happens, **Then** the entire run
   stops and the app is flagged as unstable — this is a tighter, separate threshold
   from the per-bug retry budget, triggered by environment instability rather than a
   specific bug being hard to fix.
4. **Given** the two-consecutive-restart-failure threshold is reached, **When** the
   run stops, **Then** this is reported distinctly from a per-bug unresolved
   marking — the two failure modes (environment breaking vs. one hard bug) must not
   be conflated in the report.

---

### Edge Cases

- What happens when a bug's fix requires touching a high-risk area only discovered
  partway through the in-session assessment (not obvious from the finding alone)?
  The high-risk pause (Story 3) applies based on what the assessment actually
  determines, not just what the original finding's category suggested — assessed
  scope, not surface-level classification, is what triggers it.
- What happens when a scenario's multiple bugs (Story 2) include one high-risk and
  one routine bug? Each bug's pause behavior (Story 3) is evaluated independently —
  the high-risk one pauses regardless of flags, the routine one follows
  `REVIEW_BEFORE_FIX`/`--silent` — before the shared restart/retest (Story 2) happens
  for both.
- What happens when the project's test suite doesn't exist at all (vs. exists but
  doesn't cover the affected area)? Both cases are treated identically per Story 1
  Scenario 5 — the browser retest is the only verification either way.
- What happens when a bug is marked unresolved (Story 4) but was one of several bugs
  from the same scenario, some of which *were* resolved? The resolved ones are still
  committed individually (Story 2 Scenario 3); the unresolved one is documented as
  such and the run continues, rather than the whole batch being discarded because one
  member failed.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST stop the app under test before attempting any fix for a
  BUG finding.
- **FR-002**: When `bug-fix-mechanism: direct` is configured, system MUST assess a
  BUG finding in-session — producing a root-cause summary, proposed fix, and
  affected-files list — without invoking any external bug-workflow tool.
- **FR-003**: System MUST always stop and ask for explicit sign-off, before any fix
  is attempted, when the assessed scope of a bug touches security, authentication,
  data deletion/migration, or broad architectural impact — regardless of `--silent`,
  `--review-before-fix`/`--no-review-before-fix`, or any other flag.
- **FR-004**: For a non-high-risk bug, when `REVIEW_BEFORE_FIX` is on for the run,
  system MUST pause after assessment and present the assessment, offering **proceed /
  adjust / skip this bug**, before writing any fix.
- **FR-005**: The routine review pause (FR-004) MAY be skipped under `--silent`; the
  high-risk pause (FR-003) MUST NOT be skipped under any condition.
- **FR-006**: System MUST run the project's existing test suite scoped to the
  affected area, when one exists, as part of verifying a fix.
- **FR-007**: When no relevant automated test suite exists for the affected area,
  system MUST note in the finding that the browser retest is this fix's only
  verification.
- **FR-008**: System MUST restart the app after every bug from a given scenario has
  been fixed, and MUST perform exactly one browser retest per restart — not one
  restart/retest per individual bug when multiple bugs came from the same scenario.
- **FR-009**: The browser retest MUST re-drive the exact original scenario steps in a
  real Chrome browser; a passing automated test suite result alone MUST NOT be
  treated as sufficient to consider a bug resolved.
- **FR-010**: System MUST commit each bug separately (its fix, any regression test,
  and its finding file) even when its restart/retest was shared with other bugs from
  the same scenario.
- **FR-011**: When a bug's browser retest still fails after a fix attempt, system
  MUST attempt up to 2 further diagnose/fix cycles for that specific bug before
  marking it unresolved and continuing with independent scenarios.
- **FR-011a**: Each retry cycle under FR-011 MUST re-apply the same pause gates
  (FR-003's unconditional high-risk pause, and FR-004's routine `REVIEW_BEFORE_FIX`
  pause where applicable) as the original attempt — approval given for one fix
  attempt MUST NOT be treated as standing approval for a subsequent retry of the
  same bug.
- **FR-012**: System MUST treat two consecutive restart failures (a `wait-ready`
  timeout following both a stop and a fresh start) as a distinct, tighter threshold
  than the per-bug retry budget (FR-011) — reaching it MUST stop the entire run and
  flag the app as unstable, rather than continuing to retry.
- **FR-013**: The final report MUST distinguish a run stopped by the
  two-consecutive-restart-failure threshold (FR-012) from a bug marked unresolved
  after exhausting its own retry budget (FR-011) — the two are not the same failure
  mode and must not be reported as if they were.

### Key Entities

- **Bug-Fix Cycle**: The stop → assess → (optional pause) → fix → test → restart →
  browser-retest → per-bug-commit sequence this feature defines, scoped to
  `bug-fix-mechanism: direct`.
- **High-Risk Bug**: A BUG finding whose assessed scope (not just its surface
  category) touches security, authentication, data deletion/migration, or broad
  architectural impact — triggers the unconditional pause (FR-003) distinct from the
  routine review pause (FR-004).
- **Restart-Failure Threshold**: The two-consecutive-failure counter (FR-012),
  independent of and tighter than any individual bug's retry budget (FR-011) —
  distinguishes "the environment is breaking" from "this one bug is hard to fix."

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A deliberately seeded, single bug is fixed and only marked resolved
  after a real, post-restart browser retest — never on the strength of an automated
  test result alone.
- **SC-002**: A scenario with N bugs (N > 1) produces exactly one restart and one
  browser retest covering all N, and N separate commits.
- **SC-003**: A high-risk bug pauses for sign-off in 100% of runs, across every
  combination of `--silent` and `--no-review-before-fix`.
- **SC-004**: A bug that never resolves is retried exactly 2 additional times (3
  total fix attempts) before being marked unresolved, and the run continues with
  other scenarios rather than stalling.
- **SC-005**: Two consecutive restart failures stop the run within that same cycle,
  distinctly reported from a per-bug unresolved marking.

## Assumptions

- **Spec-Kit delegation is out of scope**: this feature covers only
  `bug-fix-mechanism: direct`; the `spec-kit` branch (external bug-assess/fix/test
  commands) is `UAT-09`, a separate slice reusing this cycle's shared structure
  (restart batching, retry budgets, high-risk carve-outs) but delegating the
  fix-mechanism step itself.
- **"Broad architectural impact" stays a judgment call**: like the existing
  high-risk category definitions this feature extends, no further quantification is
  introduced here — consistent with how this product already handles similarly
  qualitative categories elsewhere (e.g. UX_FRICTION's classification).
- **Single run at a time**: this feature, like the rest of the product, assumes one
  run active against a given project at a time.
