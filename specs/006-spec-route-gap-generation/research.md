# Research: Scenario Generation — Spec-Derived + Route-Gap-Derived

No `NEEDS CLARIFICATION` markers remained in the Technical Context, and
`/speckit-clarify` found zero critical ambiguities — this feature formalizes
already-deliberate, already-written `SKILL.md` Generation mode text rather than
inventing new scope.

## Decision: Two targeted additions to Generation mode, most FRs already present

**Rationale**: Re-reading the current Generation mode text (steps 1-2) against every
FR in `spec.md` found FR-001 through FR-007 and FR-011 already present, several
near-verbatim (the one-candidate-per-acceptance-criterion drafting rule, the
`Source:` tagging convention, the persona-variant-without-a-catalog approach, the
route-gap cross-reference against `uat/scenarios/`). Two real gaps:

1. **FR-008/FR-009** — the current text only states the degradation case for a
   missing `spec-dir` (spec-derived skips, route-gap-derived still runs); it never
   states the symmetric case (routing source undiscoverable → route-gap-derived
   skips, spec-derived still runs) or the neither-prerequisite-met case (both skip,
   explicit empty-result note, not an error).
2. **FR-010/FR-012** — the `--priority` bullet's current wording ties priority
   scoping only to "which flows get boundary-derived treatment," not to
   spec-derived/route-gap-derived scoping broadly, and never addresses a
   zero-eligible-flows outcome.

**Alternatives considered**: A new standalone "Generation Prerequisites" subsection
separate from steps 1-2 — rejected per Constitution Principle V (Reuse Before
Reinvention); both gaps are targeted additions to existing bullets, not new
sections' worth of scope.

## Decision: No automated test/type-check/lint runner applies, same as prior features

**Rationale**: No compiled source. Markdown lint + `quickstart.md`'s scenarios stand
in for the constitution's Principle VIII gate.

## Decision: Screen-vs-route filtering stays Phase 0.5's concern, not re-validated here

**Rationale**: Whether a discovered "route" is a genuine user-facing screen worth a
route-gap stub, versus a redirect or a non-content technical route (e.g. an API
route), is a property of what Phase 0.5 discovery itself records. Re-filtering it
inside generation would duplicate a judgment call this product already makes once,
earlier in the pipeline — restated from the spec's own Edge Cases rather than left
implicit.

**Alternatives considered**: Having route-gap-derived generation apply its own
screen-vs-route heuristic independently of Phase 0.5 — rejected, since it would let
discovery and generation disagree about what counts as a screen, with no single
source of truth.

## Decision: Spec-derived and route-gap-derived drafts are never merged or deduplicated

**Rationale**: A screen that is simultaneously a route-gap (no scenario exists) and
the subject of a spec-derived draft in the same run answers two different questions
— a criterion needs a test vs. a screen needs any coverage at all — so both drafts
are produced independently, each carrying its own true `Source:` tag, even where
they end up covering overlapping UI.

**Alternatives considered**: Deduplicating by target screen/route — rejected, since
it would silently drop the traceability one of the two drafts carries (the specific
acceptance criterion it originated from), which is exactly what Story 1 exists to
preserve.
