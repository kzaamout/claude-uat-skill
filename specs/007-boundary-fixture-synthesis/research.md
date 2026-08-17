# Research: Scenario Generation — Boundary-Derived + Fixture Synthesis

No `NEEDS CLARIFICATION` markers remained in the Technical Context, and
`/speckit-clarify` found zero critical ambiguities — this feature formalizes
already-deliberate, already-written `SKILL.md` text (Generation mode step 2's
boundary-derived bullet, step 3's fixture list, and Phase 0's fixture-check step)
rather than inventing new scope.

## Decision: Four targeted additions, most FRs already present, one wrong
assumption caught and corrected before implementation

**Rationale**: Re-reading the current text against every FR in `spec.md` found
FR-001, FR-003, FR-004 already present near-verbatim in step 2's boundary-derived
bullet (per-flow introspection at generation time, Critical/High-only scoping, the
generic `Source:` tagging mechanism covering it). More significantly, FR-007,
FR-008, and FR-009 — the synthesis offer, its genuineness requirement, and
`--silent` auto-synthesis — are *already fully specified*, not in Generation mode
but in Phase 0's fixture-check step (lines 143-147 as of this writing): "Missing →
offer to synthesize it (must be a genuinely valid instance of its type... not a
placeholder file), through the same batched-approval mechanism generation uses.
Under `--silent`, synthesize automatically and note it in the final report." This
is the correct architecture — one synthesis mechanism serving both hand-written and
generated scenarios, not duplicated per-caller (Constitution Principle V).

Four real gaps: (1) FR-002 — boundary-derived's bullet names the four constraint
categories but never states the one-draft-per-category-present cardinality; (2)
FR-006 — the fixture list's current text says "consolidated" but never states a
dedup rule for a fixture multiple drafts share; (3) FR-011 — no stated behavior for
validation code that can't be confidently read/parsed; (4) FR-012 — no stated
behavior for a Critical/High flow with zero discoverable constraints.

**Alternatives considered**: Duplicating a synthesis-offer step inside Generation
mode itself, so it's colocated with the other boundary-derived text — rejected per
Constitution Principle V; Phase 0's existing step already runs on every approved
scenario regardless of source (hand-written or generated), so a second copy inside
Generation mode would create exactly the drift-prone duplication Principle V warns
against.

## Decision: FR-010 corrected — synthesized fixture files persist, they are not
run-isolated like DB rows

**Rationale**: The initial spec draft assumed a synthesized fixture follows
`UAT-06`'s run-id-suffixed naming and end-of-run cleanup, the same as any other
UAT-created record. Re-reading R7's exact wording ("Every record this skill
creates — seeded users, seeded rows, **synthesized fixtures tracked in the DB** —
is suffixed with the current run's id") shows R7 already scopes the naming rule to
the *DB-tracked reference* to a fixture, not the fixture file itself. Generation
mode step 3's own worked example reinforces this: `uat/fixtures/sample-oversized.pdf`
is a plain, unsuffixed filename, consistent with fixtures being reusable static
assets meant to persist across runs (the same way `demo-app`'s bundled fixtures are
checked-in, reusable files, not per-run artifacts). Caught and corrected in `spec.md`
directly during this drafting pass — per Constitution Principle II, a conflict
between an initial assumption and existing written behavior is reconciled before
implementation, not built around.

**Alternatives considered**: Leaving the original run-isolated-cleanup assumption
in place and updating `SKILL.md`'s R7/Generation-mode text to match it instead —
rejected, since that would mean re-synthesizing an oversized/malformed fixture on
every single run (wasteful, and inconsistent with `demo-app`'s deliberate choice
to treat its own fixtures as reusable checked-in assets).

## Decision: No automated test/type-check/lint runner applies, same as prior
features

**Rationale**: No compiled source. Markdown lint + `quickstart.md`'s scenarios
stand in for the constitution's Principle VIII gate.

## Decision: "Smallest unambiguous value" for ambiguous synthesis targets stays a
generation-time judgment call

**Rationale**: Where a constraint like "oversized" doesn't pin down an exact target
size, resolving it by asking the user on every occurrence would turn a one-line
approval decision into a per-fixture negotiation. Consistent with how this product
already treats other qualitative classifications (persona derivation in `UAT-07`,
high-risk assessment scope in `UAT-04`), the Edge Cases section states the rule
directly (smallest value that unambiguously crosses the documented constraint)
rather than deferring it to a clarification round.

**Alternatives considered**: Requiring an exact target value to be specified in
every draft that needs a synthesized fixture — rejected, since boundary-derived
generation reads the constraint from real code (e.g. "max 10MB") which already
gives synthesis everything it needs to pick an unambiguous over-limit value without
further input.
