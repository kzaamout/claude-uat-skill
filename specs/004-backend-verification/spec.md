# Feature Specification: Backend Verification

**Feature Branch**: `004-backend-verification`

**Created**: 2026-08-16

**Status**: Draft

**Input**: User description: "UAT-05 — Backend Verification. User outcome: a scenario's claimed data change is confirmed directly against the app's own API or a discovered data store, not just inferred from what the UI showed. Scope: API-first verification when Phase 0.5 discovery found API coverage for the relevant data, direct-data-store fallback (relational DB, document store, vector store, cache -- whatever discovery identified) when the API doesn't cover it, graceful UI-only degradation with an explicit note in the finding when no store is discoverable at all. This check is a read against already-written data, not gated by the DB-write confirmation that seeding/cleanup writes require. Explicitly deferred from this slice: verifying across more than one data store when a single outcome plausibly spans several. Dependencies: UAT-01, UAT-02. Relevant existing specification sources: SKILL.md Phase 0.5 'Backend verification path' and Phase 2 step 7; docs/design-history.md R10."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A false UI success is caught by checking the actual backend (Priority: P1)

A user runs a scenario whose expected outcome names data that should be created or
changed (e.g. "a new document appears," "a comment is saved"). The UI shows a success
message, but they need to know whether that data was *actually* persisted correctly —
not just that the UI claimed it was — because a UI-only check would miss a backend
failure the UI silently swallows.

**Why this priority**: This is the entire value of the feature — without it,
`webapp-uat` is trusting the same layer of the app (the UI) that a bug could be
lying through. Independently testable and independently valuable on its own, even
before Stories 2-3 exist.

**Independent Test**: Can be fully tested by running a scenario against a backend
that's deliberately seeded to silently fail a write while still showing UI success,
and confirming the discrepancy is caught and surfaced rather than the run trusting
the UI's claim.

**Acceptance Scenarios**:

1. **Given** a scenario's Expected Outcome names data that should be created or
   changed, **When** the scenario completes, **Then** that data's actual state is
   confirmed directly against the backend, not solely inferred from what the UI
   displayed.
2. **Given** Phase 0.5 discovery recorded that the app's own API covers reads for
   the relevant data, **When** backend verification runs, **Then** it uses that API
   rather than bypassing it for direct data-store access.
3. **Given** the API doesn't cover the relevant data (or Phase 0.5 found no API
   coverage at all), **When** backend verification runs, **Then** it falls back to a
   direct read against whichever data store discovery identified as relevant.
4. **Given** the UI reported success but the backend shows the data was not actually
   created or changed as claimed, **When** this discrepancy is detected, **Then** it
   is surfaced explicitly in the finding as a mismatch between what the UI showed and
   what the backend confirms — not silently resolved in favor of either signal.
5. **Given** backend verification is a read against already-written data, **When** it
   runs, **Then** it does not trigger the DB-write confirmation gate that seeding or
   cleanup writes require — that gate applies to writes this skill performs, not to
   reads confirming what the app under test already wrote.
6. **Given** a scenario's outcome plausibly spans more than one data store Phase 0.5
   discovery identified, **When** verification runs, **Then** it checks the single
   primary store/API discovery identified as relevant and the finding does not
   represent this as full coverage across every plausibly relevant store.

---

### User Story 2 - A project with no discoverable backend degrades cleanly (Priority: P2)

A user runs this skill against a project where Phase 0.5 discovery couldn't identify
any API coverage or any data store at all (a project with an opaque or undiscoverable
backend). They need scenarios to still complete and report normally — verified via UI
only, with that limitation stated plainly — rather than the run erroring, blocking, or
silently pretending backend verification happened when it didn't.

**Why this priority**: Without graceful degradation, this feature would make the
skill unusable against any project it can't fully introspect, which is a real and
common case, not an edge case. Independently testable by running against a project
with a deliberately opaque backend.

**Independent Test**: Can be fully tested by running a scenario against a project
where Phase 0.5 discovery recorded no backend store or API coverage, and confirming
the finding notes "verified via UI only" rather than erroring or omitting the check
entirely.

**Acceptance Scenarios**:

1. **Given** Phase 0.5 discovery found no API coverage and no discoverable data
   store for a scenario's relevant data, **When** that scenario's expected outcome
   names data that should be created or changed, **Then** the finding explicitly
   notes the outcome was verified via UI only, rather than the run erroring or
   silently skipping the check.
2. **Given** a scenario's Expected Outcome does not name any data that should be
   created or changed, **When** that scenario runs, **Then** backend verification is
   not attempted for it at all — this check is scoped to claims about persisted data,
   not applied indiscriminately to every scenario.

---

### User Story 3 - Backend-verification failures are distinguished from app failures (Priority: P3)

A user's backend-verification step itself fails partway through — a database
connection drops, an API call times out — separate from the app under test actually
being broken. They need this distinguished from a genuine app bug, so a flaky
verification connection doesn't get misreported as a product defect.

**Why this priority**: Lower priority than Stories 1-2 because it's a failure-mode
refinement, not core value — but still needed for classification (Phase 3) to stay
accurate, consistent with the existing app-crash-vs-TEST_ENVIRONMENT distinction this
product already makes elsewhere.

**Independent Test**: Can be fully tested by deliberately breaking the verification
connection (not the app itself) mid-run and confirming the resulting finding is
classified as a test-environment problem, not attributed to the app under test.

**Acceptance Scenarios**:

1. **Given** the app under test itself is functioning normally, **When** the
   backend-verification step's own connection to a data store or API fails or times
   out, **Then** this is treated as a test-environment problem, not evidence the app
   itself has a data-persistence bug.
2. **Given** backend verification cannot complete for this reason, **When** the
   finding is recorded, **Then** it notes the verification attempt failed and why,
   distinctly from a case where verification completed and found a real discrepancy
   (Story 1, Scenario 4).

---

### Edge Cases

- What happens when a scenario's outcome plausibly spans more than one discovered
  data store (e.g. a write that should appear in both a relational DB and a search
  index)? **Explicitly deferred** — this feature verifies against the single primary
  store or API discovery identified as relevant, and does not define a strategy for
  verifying across multiple stores for one outcome. Not silently resolved by picking
  one arbitrarily and calling it complete; recorded as an open limitation (see
  Assumptions).
- What happens when the backend-verification step's own connection fails (DB
  unreachable, API times out) while the app itself is working normally? Treated as a
  test-environment problem (Story 3), not an app defect.
- What happens when backend verification contradicts the UI (UI says success, backend
  shows failure, or vice versa)? Both signals are reported; the discrepancy itself is
  the finding, not silently resolved in favor of one over the other (Story 1,
  Scenario 4).
- What happens when a scenario doesn't claim any backend data change at all? Backend
  verification is not attempted for it — this is scoped to scenarios whose Expected
  Outcome actually names persisted data (Story 2, Scenario 2).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST verify a scenario's claimed data change directly against
  the app's backend whenever that scenario's Expected Outcome names data that should
  be created or changed — not rely solely on what the UI displayed.
- **FR-002**: When Phase 0.5 discovery recorded that the app's own API covers reads
  for the relevant data, system MUST use that API for verification rather than
  bypassing it via direct data-store access.
- **FR-003**: When the API does not cover the relevant data, or no API coverage was
  discovered, system MUST fall back to a direct read against whichever data store
  Phase 0.5 discovery identified as relevant.
- **FR-004**: When neither API coverage nor any data store is discoverable for the
  relevant data, system MUST record in the finding that the outcome was verified via
  UI only, and MUST NOT error, block the run, or silently omit the check.
- **FR-005**: Backend verification MUST be treated as a read operation and MUST NOT
  trigger the DB-write confirmation gate that governs seeding or cleanup writes.
- **FR-006**: When the backend's actual state contradicts what the UI displayed
  (success shown but not persisted, or the reverse), system MUST surface this
  discrepancy explicitly in the finding rather than silently preferring either signal.
- **FR-007**: System MUST NOT attempt backend verification for a scenario whose
  Expected Outcome does not name any data that should be created or changed.
- **FR-008**: A failure of the backend-verification step itself (connection failure,
  timeout against the data store or API) MUST be classified as a test-environment
  problem, distinct from a finding that the app under test has a data-persistence
  defect.
- **FR-009**: When a scenario's outcome plausibly spans more than one discovered data
  store, system MUST verify against the single primary store or API Phase 0.5
  discovery identified as relevant, and MUST NOT represent that verification as
  covering every plausibly relevant store — this is a known, undeferred-to-later
  limitation, not silently resolved.

### Key Entities

- **Backend Verification Result**: The outcome of checking a scenario's claimed data
  change against the app's actual backend state — one of: confirmed matching the UI,
  contradicts the UI (discrepancy), UI-only (no store/API discoverable), or
  verification-failed (test-environment problem).
- **Discovered Verification Path**: The API-or-direct-store route Phase 0.5 recorded
  as relevant for a given kind of data, established once per project and reused by
  every scenario's backend verification rather than re-discovered per run.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A scenario whose UI falsely reports success against a real backend is
  caught by this check in 100% of cases where a store or API is discoverable for the
  relevant data.
- **SC-002**: A project with no discoverable backend store or API completes every
  scenario's finding with an explicit UI-only note, in 100% of cases, never erroring
  or blocking the run.
- **SC-003**: When both an API and a direct-store path are available for the same
  data, the API path is used rather than bypassed, in 100% of cases.
- **SC-004**: A backend-verification connection failure is never misclassified as an
  app defect — it is always distinguishable in the finding as a test-environment
  problem.

## Assumptions

- **Single-store verification, by design, for now**: this feature verifies against
  one primary store or API per scenario outcome, even when discovery found more than
  one plausibly relevant store. Multi-store verification for a single outcome is an
  open architecture question, deliberately not resolved here — carried forward as a
  known limitation rather than silently picking one store and calling the outcome
  fully verified.
- **Discovery, not per-scenario re-detection**: which store or API is "relevant" for
  a given kind of data is established once by Phase 0.5 discovery and reused, not
  re-derived per scenario — consistent with how discovery already works for routing,
  locale, and test-data tooling elsewhere in this product.
- **Read, not write**: this feature only reads already-persisted data to confirm it;
  it never creates, modifies, or deletes backend state itself, which is why it does
  not require the DB-write confirmation gate that seeding/cleanup writes need.
