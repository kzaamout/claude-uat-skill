# Feature Specification: Run Isolation & Data Hygiene

**Feature Branch**: `003-run-isolation-data-hygiene`

**Created**: 2026-08-16

**Status**: Draft

**Input**: User description: "UAT-06 — Run Isolation & Data Hygiene. User outcome: every record the skill creates is safely, automatically cleaned up at both ends of a run, with collisions across runs structurally near-impossible rather than merely policy-discouraged. Scope included: run-id-suffixed naming (uat-{run-id}-<descriptor>) for every created record; start-of-run purge (self-heals from an interrupted prior run); end-of-run purge (only after the report is actually written); explicit confirmation on both purges, every run, --silent or not; the same explicit-confirmation treatment for seed-data creation during generation, not just cleanup. Scope explicitly deferred: none within this slice's own boundary. Dependencies: UAT-01. Relevant specification sources: SKILL.md 'Naming convention for UAT-created data (R7)'; Phase 0 start-of-run cleanup; Phase 5 end-of-run cleanup; Generation mode's data/fixture DB-write confirmation; docs/design-history.md R7 in full."

## Clarifications

### Session 2026-08-16

- Q: Does declining a cleanup confirmation block/cancel the run, or does the run simply proceed with that step skipped? → A: Differentiated — declining start-of-run cleanup blocks the run (stale data present during execution risks corrupting this run's own results); declining end-of-run cleanup lets the run complete anyway (self-healing recovers the stale data at the start of the next run).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Every created record is collision-resistant by construction (Priority: P1)

A user runs this skill repeatedly against the same project over time, and needs
every test account, seeded row, or synthesized fixture the skill creates to never
collide with data from a previous run or with the project's real data — without
relying on a policy someone has to remember to follow.

**Why this priority**: This is the structural foundation everything else in this
feature depends on — the cleanup guarantees in Stories 2-3 are only actually safe
because records are unambiguously identifiable as belonging to one specific run.
Without it, "purge this run's data" would require guessing rather than knowing.

**Independent Test**: Can be fully tested by triggering data creation (seeding a
test account, synthesizing a fixture tracked in the DB) during a run and confirming
the resulting identifier follows the `uat-{run-id}-<descriptor>` pattern, never a
fixed or reused identifier.

**Acceptance Scenarios**:

1. **Given** a run creates a seeded test account, **When** it's written, **Then**
   its identifier is `uat-{run-id}-<descriptor>` (e.g.
   `uat-2026-08-13-1430-admin@test.local`), not a fixed identifier reused across
   runs.
2. **Given** two separate runs both create data of the same kind (e.g. both seed an
   "admin" test account), **When** both complete, **Then** their two identifiers are
   distinct by construction (different run-ids), never colliding.
3. **Given** a synthesized fixture is tracked in the database (not just written to
   `uat/fixtures/`), **When** its record is created, **Then** it carries the same
   run-id-suffixed naming as seeded accounts and rows.

---

### User Story 2 - An interrupted prior run's leftover data is found and purged automatically (Priority: P1)

A user's previous run crashed, was killed, or was otherwise interrupted before its
own cleanup ran, leaving UAT-marked data behind. They start a new run and expect
that leftover data to be found and removed automatically — without them having to
notice it or clean it up by hand — while still being told explicitly that a
database write is about to happen.

**Why this priority**: This is what makes the skill safely re-runnable against a
project over time — without self-healing, every interrupted run would leave
permanent clutter that silently accumulates. Independently testable by deliberately
interrupting one run and observing the next.

**Independent Test**: Can be fully tested by interrupting a run after it has created
UAT-marked data but before its own end-of-run cleanup, then starting a fresh run and
confirming the leftover data is purged at the start, with an explicit confirmation
prompt shown before it happens.

**Acceptance Scenarios**:

1. **Given** a previous run was interrupted after creating UAT-marked data,
   **When** a new run starts, **Then** that leftover data is found and purged as
   part of this new run's start-of-run cleanup, before any scenario executes.
2. **Given** this purge is about to happen, **When** it is proposed, **Then** the
   user is asked to explicitly confirm it — every run, regardless of any flag that
   would otherwise skip routine approvals.
3. **Given** the user declines this confirmation, **When** they do, **Then** the
   run is blocked rather than proceeding with stale UAT-marked data still present
   during execution.
4. **Given** no leftover UAT-marked data exists at all, **When** a new run starts,
   **Then** the start-of-run cleanup step completes as a no-op — no confirmation
   prompt is shown for a purge that has nothing to do, and the run proceeds
   normally.

---

### User Story 3 - End-of-run cleanup never removes data a run might still need (Priority: P1)

A user's run is paused mid-way (waiting on a review decision, for example) or is
still legitimately in progress. They need the skill to never purge this run's data
out from under it before the run has genuinely finished and its report has been
written — cleanup timing is not just "whenever the DB write happens to run," it's
tied to actual completion.

**Why this priority**: Purging live data from underneath a run that hasn't actually
finished would directly undermine the confidence this tool is supposed to provide.
Independently testable by confirming cleanup timing relative to report-writing,
distinct from Story 2's start-of-run timing.

**Independent Test**: Can be fully tested by running a scenario to completion,
confirming the final report is written first, and confirming the end-of-run purge
happens only after that report exists — with the same explicit confirmation Story 2
requires.

**Acceptance Scenarios**:

1. **Given** a run has completed and its final report has just been written,
   **When** cleanup runs, **Then** this run's UAT-marked data is purged only at that
   point, never before the report exists.
2. **Given** the end-of-run purge is about to happen, **When** it is proposed,
   **Then** the user is asked to explicitly confirm it, every run, regardless of any
   flag that would otherwise skip routine approvals.
3. **Given** the user declines this confirmation, **When** they do, **Then** the
   run still completes — the report already exists, and the leftover data is
   recovered automatically by the next run's start-of-run cleanup (Story 2) rather
   than blocking this run's completion.
4. **Given** a run completes with unresolved bugs, **When** end-of-run cleanup
   runs, **Then** it still runs regardless — the finding files, not live data, are
   the source of truth for reproducing an unresolved bug, so unresolved work does
   not block cleanup.

---

### User Story 4 - Every database write gets the same explicit-confirmation treatment, with no silent exceptions (Priority: P2)

A user wants confidence that "every DB write is confirmed" actually holds
everywhere this skill writes to a database — not just at cleanup, and not just
until some flag or mode quietly starts treating one particular write as routine.

**Why this priority**: This is the guarantee that makes Stories 2-3's individual
confirmations trustworthy as a *pattern*, not just two isolated prompts — closes the
gap where generation-time seed-data creation could otherwise be folded silently
into a general batch approval instead of getting its own explicit confirmation like
cleanup does.

**Independent Test**: Can be fully tested by triggering a run that both creates new
seed data during generation and performs both cleanup purges, and confirming all
three DB writes get an identical, explicit, individually-named confirmation — none
bundled silently into a broader approval, and none skipped under any flag.

**Acceptance Scenarios**:

1. **Given** a generation run's approved plan includes new seed data (test
   accounts, seeded rows) beyond static fixture files, **When** that data is about
   to be created, **Then** the user is asked to explicitly confirm that specific
   database write, distinct from and in addition to the general plan
   approve/adjust/cancel decision.
2. **Given** any of the three DB-write confirmations (start-of-run purge,
   end-of-run purge, seed-data creation) is pending, **When** `--silent` is passed,
   **Then** it is still shown and still requires an explicit response — `--silent`
   has no effect on any of these three.
3. **Given** a user later wants to stop confirming one of these specific writes
   because they've come to trust it, **When** they look for a way to do that,
   **Then** there is none available at runtime — quietly reducing confirmation over
   time is not something this skill decides for itself; it would require a
   deliberate, manual edit to the skill's own instructions.

---

### Edge Cases

- What happens when a user declines a start-of-run or end-of-run cleanup
  confirmation? The purge does not happen — declining is not silently treated as
  approval, and the run does not proceed as though cleanup occurred when it didn't.
  The two differ in consequence: declining start-of-run cleanup blocks the run
  (stale data during execution is a real risk); declining end-of-run cleanup does
  not block completion (self-healing recovers it next time).
- What happens when a purge fails partway through (some UAT-marked records removed,
  others not)? Not resolved by this feature — a known gap, not silently assumed
  away (see Assumptions).
- What happens when a synthesized fixture file exists under `uat/fixtures/` but was
  never tracked as a database record? Only DB-tracked records are in scope for the
  purge/naming guarantees here — a bare file on disk is cleaned up (or not) by
  whatever mechanism manages `uat/fixtures/` generally, not by this feature.
- What happens when two runs are somehow active against the same project at the
  same time? Out of scope — this feature assumes single-run-at-a-time use, the same
  assumption the rest of this product makes elsewhere.
- What happens when a run-id-suffixed identifier theoretically collides with a real,
  non-UAT record that happens to match the naming pattern by coincidence? Treated as
  a structurally near-impossible edge case given the run-id's timestamp precision,
  not a zero-probability one — not specifically guarded against beyond the naming
  scheme itself.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST suffix every record it creates (seeded users, seeded
  rows, database-tracked synthesized fixtures) with the current run's id, in the
  form `uat-{run-id}-<descriptor>`, and MUST NOT reuse a fixed identifier across
  runs for this purpose.
- **FR-002**: System MUST purge any UAT-marked data left over from a previous run
  as part of every run's start-of-run cleanup, before any scenario executes.
- **FR-003**: System MUST explicitly confirm the start-of-run purge with the user
  before performing it, every run, regardless of any flag that would otherwise skip
  routine approval prompts.
- **FR-004**: When no leftover UAT-marked data exists, system MUST complete the
  start-of-run cleanup step as a no-op without prompting for confirmation of a
  purge that has nothing to remove.
- **FR-005**: System MUST purge the current run's UAT-marked data only after that
  run's final report has been written — never before, regardless of how the run
  otherwise concludes.
- **FR-006**: System MUST explicitly confirm the end-of-run purge with the user
  before performing it, every run, regardless of any flag that would otherwise skip
  routine approval prompts.
- **FR-007**: System MUST perform the end-of-run purge regardless of whether the
  run's findings include unresolved bugs — incomplete resolution MUST NOT block
  cleanup.
- **FR-008**: When a generation run's approved plan includes new seed data beyond
  static fixture files, system MUST explicitly confirm that data's creation as its
  own distinct database-write confirmation, separate from the general plan
  approve/adjust/cancel decision.
- **FR-009**: None of the three explicit confirmations this feature defines
  (start-of-run purge, end-of-run purge, seed-data creation) MAY be skipped by
  `--silent` or any other flag.
- **FR-010**: System MUST NOT provide any runtime setting, flag, or mode that
  reduces or removes any of these three confirmations — loosening this MUST require
  a deliberate, manual edit to the skill's own instructions, not a decision the
  skill makes for itself based on run history or apparent trust.
- **FR-011**: A declined cleanup confirmation MUST result in the purge not
  happening — system MUST NOT treat a decline as approval or proceed as though the
  purge occurred. The consequence differs by which purge: declining the
  **start-of-run** purge MUST block the run from proceeding (stale UAT-marked data
  present during execution risks corrupting the run's own results); declining the
  **end-of-run** purge MUST NOT block the run from completing (the report already
  exists, and the leftover data is recovered automatically by the next run's
  start-of-run cleanup).

### Key Entities

- **UAT-Marked Record**: Any seeded user, seeded row, or database-tracked
  synthesized fixture this skill creates, identified by its `uat-{run-id}-`
  prefix — the unit both the naming guarantee (Story 1) and both purges (Stories
  2-3) operate on.
- **Start-of-Run Purge**: The confirmed database write that removes UAT-marked
  records left over from an interrupted prior run, performed before Phase 0
  completes.
- **End-of-Run Purge**: The confirmed database write that removes the current run's
  own UAT-marked records, performed only after the final report is written.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A run interrupted after creating UAT-marked data never leaves that
  data behind permanently — the next run's start-of-run cleanup finds and removes
  it automatically, in 100% of cases.
- **SC-002**: No database write this feature defines ever happens without an
  explicit, individually-shown confirmation — verified across every combination of
  flags, including `--silent`.
- **SC-003**: A run's own data is never removed before its final report exists,
  in 100% of cases, regardless of how the run concludes (clean, partial, or with
  unresolved bugs).
- **SC-004**: Two records created by two different runs, of the same descriptor
  (e.g. both an "admin" test account), are never assigned the same identifier.

## Assumptions

- **Scope is DB-tracked test data, not code artifacts**: the naming and cleanup
  guarantees in this feature apply to seeded users, seeded rows, and
  database-tracked synthesized fixtures — not to commits, regression tests, or
  other code-level artifacts a bug-fix cycle might produce, which are governed
  elsewhere (`UAT-04`/`UAT-09`) and are not database records to purge.
- **Partial-purge failure is a known, unresolved gap**: this feature does not
  define recovery behavior for a purge that fails partway through (some records
  removed, others not) — carried forward as an open item rather than silently
  assumed away, consistent with how `UAT-01`'s equivalent partial-write case (a
  different operation, the same honesty principle) was handled.
- **Single run at a time**: this feature, like the rest of the product, assumes
  one run active against a given project at a time — concurrent-run collision
  handling is out of scope here.
- **Fixture files on disk vs. DB records**: a `uat/fixtures/` file that isn't also
  tracked as a database record is not "UAT-marked data" for this feature's
  purposes — only DB-tracked records are purged/named under this feature's
  guarantees.
