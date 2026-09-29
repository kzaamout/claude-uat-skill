# Research: Bug-Fix Cycle (Direct Mechanism)

No `NEEDS CLARIFICATION` markers remained in the Technical Context, and
`/speckit-clarify` found zero critical ambiguities — this feature formalizes
already-deliberate, already-written `SKILL.md` behavior rather than inventing new
scope.

## Decision: Two targeted additions — Phase 5 (FR-013) and Phase 4 step 5 (FR-011a)

**Rationale**: Re-reading the current Phase 4 text against every FR in `spec.md`
found FR-001 through FR-012 already present, most nearly verbatim (the multi-bug
batching language, the high-risk carve-out, the two-consecutive-restart-failure
threshold, the per-bug retry budget). Two gaps: FR-013 requires the final report
to distinguish a whole-run stop (restart-failure threshold) from a per-bug unresolved
marking (retry budget exhausted) — Phase 5's current report language has a single
undivided "unresolved" bucket with no such distinction; and FR-011a — Phase 4 step
5's retry cycles did not say each retry re-applies the high-risk/routine pause gates
(surfaced by `/speckit-implement`'s diff-first step, T002, after this document was
first drafted; added by T010).

**Alternatives considered**: A new standalone "Bug-Fix Reporting" section separate
from Phase 5 — rejected per Constitution Principle V (Reuse Before Reinvention); this
is a small addition to an existing bullet, not a new section's worth of scope.

## Decision: No automated test/type-check/lint runner applies, same as prior features

**Rationale**: No compiled source. Manual structural check (no Markdown linter is installed) + `quickstart.md`'s scenarios stand
in for the constitution's Principle VIII gate.

## Decision: "Assessed scope, not surface category" for the high-risk trigger (Edge Case 1)

**Rationale**: A bug's original finding classification (BUG, with whatever severity)
doesn't always reveal that its actual fix touches security/auth/data-deletion/
architecture until the in-session assessment happens. Tying the high-risk pause to
the *assessment's* determination, not the finding's surface label, is the only
version of this rule that can't be bypassed by a finding that under-describes its own
blast radius. Restated from the spec's own Edge Cases rather than left implicit.

**Alternatives considered**: Tying the high-risk trigger to the finding's original
classification only — rejected, since it would let a bug whose fix turns out to touch
auth code slip through if the original finding didn't flag that risk itself.
