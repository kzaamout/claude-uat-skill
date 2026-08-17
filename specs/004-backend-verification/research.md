# Research: Backend Verification

No `NEEDS CLARIFICATION` markers remained in the Technical Context, and
`/speckit-clarify` found zero critical ambiguities — the source roadmap description
already resolved API-first preference, graceful degradation, and the multi-store
deferral before this spec was written.

## Decision: Three targeted additions to existing SKILL.md sections, not new logic

**Rationale**: Same pattern as `UAT-01`/`UAT-02`/`UAT-06` — most of this spec
(FR-001 through FR-005) is already written into Phase 0.5's discovery step and Phase 2
step 7. Three genuine gaps identified by tracing every FR against the current text:
FR-006 (discrepancy surfacing when the UI and backend disagree), FR-008
(verification-failure classified as `TEST_ENVIRONMENT`, not an app defect), and FR-009
(single-primary-store verification explicitly not represented as full multi-store
coverage). All three are small, targeted text additions to Phase 2 step 7, not a new
mechanism or section.

**Alternatives considered**: A new standalone "Backend Verification" section separate
from Phase 2 — rejected per Constitution Principle V (Reuse Before Reinvention); the
check is already correctly scoped as one step within scenario execution, not a
separate phase.

## Decision: No automated test/type-check/lint runner applies, same as prior features

**Rationale**: No compiled source. Markdown lint + `quickstart.md`'s scenarios stand
in for the constitution's Principle VIII gate.

## Decision: FR-008's classification rule mirrors Phase 3's existing app-crash-vs-TEST_ENVIRONMENT precedent

**Rationale**: `SKILL.md`'s Phase 3 already draws a comparable line — an app crash is
`BUG`, never `TEST_ENVIRONMENT`, because the app itself failed, not the test
apparatus. FR-008 draws the same kind of line for backend verification specifically:
the *verification step's own connection* failing (DB unreachable, API timeout) is a
test-environment problem, distinct from the app under test having a real
data-persistence defect. Reusing this precedent rather than inventing a new
classification rule from scratch keeps Phase 3's classification logic internally
consistent.

**Alternatives considered**: Treating any verification failure as inconclusive and
silently skipping the finding — rejected, since it would mean a project with a flaky
DB connection quietly gets weaker coverage without anyone being told.

## Decision: FR-009 discloses the single-store limitation rather than silently picking one store

**Rationale**: Consistent with this product's established honesty pattern (`UAT-01`'s
partial-write reporting, `UAT-06`'s partial-purge-failure disclosure) — an unresolved
gap is recorded as a known limitation in the finding/report, not silently resolved by
picking one store and representing the outcome as fully verified.

**Alternatives considered**: Deferring multi-store verification entirely without any
disclosure in the finding itself — rejected, since a user reading a "verified"
finding for a scenario with a genuinely multi-store outcome would have no way to know
only one store was actually checked.
