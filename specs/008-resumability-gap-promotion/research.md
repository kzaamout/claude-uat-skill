# Research: Resumability & In-Run Gap Promotion

No `NEEDS CLARIFICATION` markers remained in the Technical Context, and
`/speckit-clarify` found zero critical ambiguities — the one substantive open
question this feature resolves (what "resume" mechanically does) was answered
with a documented default in `spec.md` itself, grounded in what
`docs/design-history.md` R8 already confirms was never specified.

## Decision: Resume operates on written run-directory artifacts, not live process
state

**Rationale**: R8's existing text only ever specified *detection* ("Phase 0
checks for an incomplete run... ask whether to resume, abandon, or start fresh")
— it never specified what choosing "resume" actually does. The only durable state
a resumed invocation can act on is whatever the interrupted run already wrote to
`uat/runs/<run-id>/` — `test-plan.md`, and whatever per-scenario result records
existed before the interruption. A live browser session or app process from the
moment of interruption cannot be resurrected across separate Claude Code
invocations, so "resume" is defined here as: reuse the existing plan, skip
scenarios with an already-recorded result, execute the rest normally, and produce
one final report covering the whole set.

**Alternatives considered**: Treating "resume" as equivalent to "start fresh but
skip Phase 1 review" (i.e. only the review step is skipped, every scenario
re-executes) — rejected, since this wouldn't actually save the user anything
Story 2's own premise promises (not re-doing already-completed work), and would
make "resume" a misleading label for what's really just "skip review this time."

## Decision: Most-recent-by-run-id tie-break for multiple interrupted runs

**Rationale**: `run-id` is already a sortable `YYYY-MM-DD-HHmm` timestamp (per
`SKILL.md`'s existing Phase 1 text). Acting on the most recent one is the least
surprising default — it's the run the user most plausibly just tried to complete
— without requiring a new prompt just to choose among several stale interruptions,
which is itself a degenerate, rare case not worth its own UI.

**Alternatives considered**: Prompting the user to pick among all interrupted
runs found — rejected as unnecessary ceremony for what Edge Cases already frames
as a symptom worth surfacing on its own (a project accumulating several
interrupted runs), not something this feature needs to build a picker for.

## Decision: No recursive gap-promotion within one review pass

**Rationale**: Without a bound, a newly-promoted scenario could in principle
itself be read as having a further gap, triggering another promotion, without a
natural stopping point. Scoping gap promotion to "the scenarios that existed when
the pass began" gives review a clean, single-pass semantics — a genuinely deeper
gap is still available to be caught on a subsequent run's review, consistent with
how this product already treats iterative discovery elsewhere (e.g. `UAT-07`'s
loop-until-dry pattern is explicitly a multi-run concept, not demanded to
converge in one pass).

**Alternatives considered**: Allowing bounded recursion (e.g. up to one
additional promotion pass) — rejected as unnecessary complexity for a case the
Edge Cases section already treats as acceptable to defer to the next run.

## Decision: No automated test/type-check/lint runner applies, same as prior
features

**Rationale**: No compiled source. Markdown lint + `quickstart.md`'s scenarios
stand in for the constitution's Principle VIII gate.
