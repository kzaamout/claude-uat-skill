# Research: Run Isolation & Data Hygiene

No `NEEDS CLARIFICATION` markers remained in the Technical Context — well-precedented
by `SKILL.md`'s existing R7/Phase 0/Phase 5 text, and the one real ambiguity (decline
consequence) was resolved via `/speckit-clarify` before planning began.

## Decision: Verification-and-likely-two-small-fixes pass, not new logic

**Rationale**: Same pattern as `UAT-01`/`UAT-02` — most of this spec is already
written into `SKILL.md`. Two gaps are anticipated (not assumed confirmed) going into
implementation: the no-op case when nothing needs purging, and the newly-clarified
differentiated decline behavior. Both are small, targeted text additions to existing
sections, not new mechanisms.

**Alternatives considered**: Building a separate "data hygiene" section instead of
extending Phase 0/Phase 5 in place — rejected per Constitution Principle V (Reuse
Before Reinvention); the purges are already correctly scoped to their respective
phases.

## Decision: No automated test/type-check/lint runner applies, same as prior features

**Rationale**: No compiled source. Markdown lint + `quickstart.md`'s scenarios stand
in for the constitution's Principle VIII gate.

## Decision: Differentiated decline consequence (FR-011)

**Rationale**: Already resolved via `/speckit-clarify` (Session 2026-08-16).
Restated here because it's likely the more substantial of the two anticipated
`SKILL.md` edits: declining start-of-run cleanup blocks the run (stale data present
during execution is a real correctness risk to the run itself), while declining
end-of-run cleanup does not block completion (the report already exists, and
self-healing recovers the leftover data at the start of the next run regardless).

**Alternatives considered**: Uniform blocking or uniform non-blocking treatment for
both purges — both considered and rejected during the clarification session, since
neither reflects the genuinely different risk profile between "stale data during
this run's own execution" and "stale data sitting idle after the report already
exists."
