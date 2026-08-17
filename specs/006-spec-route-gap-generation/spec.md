# Feature Specification: Scenario Generation — Spec-Derived + Route-Gap-Derived

**Feature Branch**: `006-spec-route-gap-generation`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "UAT-07 -- Scenario Generation: Spec-Derived + Route-Gap-Derived. User outcome: run /webapp-uat generate and get draft scenarios traced back to real acceptance criteria, plus stub coverage for screens nothing tests at all yet -- reviewed through the same approval flow as hand-written scenarios. Scope included: spec-derived generation (one candidate scenario per acceptance criterion, persona variants derived from the spec's own use cases, no separate persona catalog needed); route-gap-derived generation (using Phase 0.5's discovered routing source, find screens with no existing scenario, draft stubs); --priority scoping; Source: tagging on every draft. Scope explicitly deferred: boundary-derived generation and fixture synthesis (UAT-08). Dependencies: UAT-01. Relevant existing specification sources: SKILL.md Generation mode steps 1-2; Phase 0.5 routing discovery; docs/design-history.md R6."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Spec-derived scenarios trace back to real acceptance criteria (Priority: P1)

A user with a `spec-dir` configured runs `/webapp-uat generate` and needs draft
scenarios produced from the actual acceptance criteria in their specs — one
candidate per criterion — with persona variants generated automatically wherever the
spec's own use cases suggest a flow behaves differently per role, rather than hand-
writing every scenario or maintaining a separate persona catalog.

**Why this priority**: This is the core value of generation — turning already-written
acceptance criteria into testable scenarios without manual transcription. Independently
testable and valuable before Stories 2-4 exist.

**Independent Test**: Can be fully tested by running `generate` against a `spec-dir`
with known acceptance criteria and confirming each produces a traceable draft
scenario, with persona variants where the spec references multiple roles for a flow.

**Acceptance Scenarios**:

1. **Given** `config.md`'s `spec-dir` is configured and readable, **When** `generate`
   runs, **Then** it walks `spec.md` (and `tasks.md` alongside it) per feature under
   `spec-dir` and drafts one candidate scenario per acceptance criterion.
2. **Given** a generated scenario, **When** it's inspected, **Then** its `Source:`
   field is tagged `spec-derived` and it's traceable back to the specific acceptance
   criterion it came from.
3. **Given** a flow's spec references multiple roles (e.g. admin, standard user,
   guest) with plausibly different behavior, **When** scenarios are drafted for it,
   **Then** one persona-specific variant is generated per role referenced — without
   a separate, hand-maintained persona definition file.
4. **Given** a `scope` path is provided to `generate`, **When** spec-derived
   generation runs, **Then** it's scoped to that path rather than walking the entire
   `spec-dir`.

---

### User Story 2 - Route-gap-derived stubs cover screens nothing tests yet (Priority: P1)

A user runs `/webapp-uat generate` and needs draft stub scenarios for any screen the
app actually has (per Phase 0.5's discovered routing source) that has zero existing
scenario coverage at all — a different, complementary failure mode from Story 1's
"acceptance criteria exist but aren't yet scenarios."

**Why this priority**: Coverage gaps that exist because nobody wrote *any* scenario
for a screen are invisible until something goes looking for them — this is the
mechanism that surfaces them. Independently valuable and testable without Story 1
existing (works even with no `spec-dir` configured at all).

**Independent Test**: Can be fully tested by running `generate` against a project
where the discovered routing source lists a screen with zero matching scenario files,
and confirming a stub draft is produced for it.

**Acceptance Scenarios**:

1. **Given** Phase 0.5 discovery identified a routing source, **When** `generate`
   runs, **Then** it cross-references discovered screens against `uat/scenarios/`
   and drafts a stub for every screen with no existing scenario at all.
2. **Given** a route-gap-derived stub, **When** it's inspected, **Then** its
   `Source:` field is tagged `route-gap-derived`.
3. **Given** a screen already has at least one existing scenario covering it,
   **When** route-gap-derived generation runs, **Then** no stub is drafted for that
   screen — this source targets screens with zero coverage, not screens with
   incomplete coverage (incomplete-but-covered is a different, non-route-gap
   concern).

---

### User Story 3 - Generation degrades gracefully when a source's prerequisite is missing (Priority: P2)

A user runs `generate` against a project with no `spec-dir` configured, or where
Phase 0.5 discovery couldn't identify a routing source. They need generation to still
run and produce whatever it validly can from the sources that *do* have what they
need — not error out entirely because one source's prerequisite is unmet.

**Why this priority**: Without graceful degradation, `generate` would be unusable for
any project missing either prerequisite, which is a realistic, common starting state
(a project without a spec convention yet, or with an undiscoverable routing setup) —
not a rare edge case. Priority P2: refines Stories 1-2 rather than standing alone.

**Independent Test**: Can be fully tested by running `generate` against a project
with no `spec-dir` set, confirming spec-derived generation is skipped (noted in
output) while route-gap-derived still runs; separately, against a project with an
undiscoverable routing source, confirming the reverse.

**Acceptance Scenarios**:

1. **Given** no `spec-dir` is configured, **When** `generate` runs, **Then**
   spec-derived generation is skipped, this is noted in the output, and
   route-gap-derived generation still runs normally.
2. **Given** Phase 0.5 discovery found no routing source, **When** `generate` runs,
   **Then** route-gap-derived generation is skipped, this is noted in the output,
   and spec-derived generation still runs normally (if `spec-dir` is configured).
3. **Given** neither prerequisite is met, **When** `generate` runs, **Then** it
   completes with an explicit note that neither source produced drafts, rather than
   erroring — an empty, explained result, not a crash.

---

### User Story 4 - Priority scoping and consistent source tagging (Priority: P2)

A user runs `generate --priority <tiers>` and needs generation scoped to the
requested priority tiers, with every draft — regardless of which source produced it —
carrying a `Source:` tag identifying where it came from, so the eventual report can
show coverage provenance.

**Why this priority**: Makes `generate` usable at a deliberately narrower scope
(e.g. "just Critical flows today") and keeps every draft's origin auditable.
Priority P2: a scoping/bookkeeping refinement over Stories 1-2's core drafting
behavior, not independently valuable before they exist.

**Independent Test**: Can be fully tested by running `generate --priority critical,high`
and confirming only flows at those tiers are drafted; separately, by inspecting a
batch of mixed-source drafts and confirming every single one has a `Source:` tag.

**Acceptance Scenarios**:

1. **Given** `--priority <tiers>` is passed, **When** generation runs, **Then** only
   flows at the specified priority tiers are drafted, across whichever sources are
   active.
2. **Given** a batch of drafts from a mix of spec-derived and route-gap-derived
   sources, **When** the batch is presented for approval, **Then** every single
   draft carries a `Source:` tag — none is left untagged.
3. **Given** `--priority` is passed with no explicit `scope` path, **When**
   generation runs, **Then** priority scoping applies across the full `spec-dir`/
   routing source rather than requiring a narrow path to combine with it.

---

### Edge Cases

- What happens when a screen the routing source lists is actually a redirect or a
  non-content technical route (e.g. an API route, not a user-facing screen)? Not
  resolved by this feature — route-gap-derived generation drafts a stub for
  whatever the discovered routing source presents as a screen; distinguishing
  genuine user-facing screens from technical routes is a property of what Phase 0.5
  discovery itself records, not something this feature re-filters.
- What happens when an acceptance criterion is too vague to turn into a concrete
  scenario (e.g. missing a clear Given/When/Then shape)? The resulting draft is
  still produced and tagged `spec-derived`, carrying whatever ambiguity the source
  criterion had — Phase 1's existing scenario-review step is where this gets
  tightened, not generation itself.
- What happens when the same screen is both a route-gap (no scenario exists) and
  the subject of a spec-derived draft in the same generation run? Both drafts are
  produced independently, tagged with their own true source — not merged or
  deduplicated, since they answer different questions (a criterion needs a test vs.
  a screen needs any coverage at all) even if they end up covering overlapping UI.
- What happens when `--priority` excludes every flow a project has? Generation
  completes with zero drafts and an explicit note, same treatment as User Story 3's
  no-prerequisites-met case — not an error.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When `config.md`'s `spec-dir` is configured and readable, system MUST
  draft one candidate scenario per acceptance criterion found by walking `spec.md`
  (and `tasks.md`) per feature under `spec-dir`, scoped to `scope` if provided.
- **FR-002**: Every spec-derived draft MUST be tagged `Source: spec-derived` and
  traceable back to the specific acceptance criterion it originated from.
- **FR-003**: Where a flow's spec references multiple roles with plausibly different
  behavior, system MUST generate one persona-specific variant per referenced role,
  without requiring a separately maintained persona definition file.
- **FR-004**: System MUST cross-reference Phase 0.5's discovered routing source
  against `uat/scenarios/` and draft one stub scenario for every screen with zero
  existing scenario coverage.
- **FR-005**: Every route-gap-derived draft MUST be tagged `Source: route-gap-derived`.
- **FR-006**: System MUST NOT draft a route-gap-derived stub for a screen that
  already has at least one existing scenario, regardless of how complete that
  coverage is.
- **FR-007**: When no `spec-dir` is configured, system MUST skip spec-derived
  generation, note this explicitly in the output, and still run route-gap-derived
  generation.
- **FR-008**: When Phase 0.5 discovery found no routing source, system MUST skip
  route-gap-derived generation, note this explicitly in the output, and still run
  spec-derived generation (if `spec-dir` is configured).
- **FR-009**: When neither prerequisite is met, system MUST complete with an
  explicit note that no drafts were produced, rather than erroring.
- **FR-010**: When `--priority <tiers>` is passed, system MUST scope generation to
  only the specified priority tiers, across whichever sources are active.
- **FR-011**: Every draft produced by `generate`, regardless of source, MUST carry a
  `Source:` tag identifying its origin.
- **FR-012**: When `--priority` scoping results in zero eligible flows, system MUST
  complete with zero drafts and an explicit note, not an error.

### Key Entities

- **Spec-Derived Draft**: A candidate scenario traced to one specific acceptance
  criterion under `spec-dir`, tagged `Source: spec-derived`; may exist as multiple
  persona-specific variants for one criterion.
- **Route-Gap-Derived Draft**: A stub scenario for a discovered screen with zero
  existing coverage, tagged `Source: route-gap-derived`.
- **Generation Prerequisite State**: Per-source readiness (spec-dir configured and
  readable; routing source discovered) that determines which sources run this
  invocation, each degrading independently and explicitly when unmet.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every acceptance criterion in a configured `spec-dir` produces exactly
  one traceable spec-derived draft (or one per referenced persona where roles
  differ), in 100% of generation runs.
- **SC-002**: Every screen with zero scenario coverage in a project with a
  discoverable routing source receives exactly one route-gap-derived stub.
- **SC-003**: A project missing either prerequisite (`spec-dir` or a discoverable
  routing source) still completes a `generate` run successfully, with the
  unavailable source's absence noted explicitly rather than causing an error.
- **SC-004**: 100% of drafts produced by any `generate` run carry a `Source:` tag —
  none is ever left untagged regardless of which source(s) were active.

## Assumptions

- **Boundary-derived generation and fixture synthesis are out of scope**: this
  feature covers only the spec-derived and route-gap-derived sources; boundary-
  derived generation (schema/validation introspection for negative-path cases) and
  the fixture-synthesis flow it triggers are `UAT-08`, a separate slice.
- **Persona derivation stays qualitative**: like this product's other
  judgment-based classifications, "roles the spec plausibly treats differently" is
  not further quantified here — consistent with how existing generation text
  already frames this ("admin/standard/guest/whatever the specs actually
  reference").
- **Screen-vs-route filtering is Phase 0.5's concern, not this feature's**: whether
  a discovered "route" is genuinely a user-facing screen worth a stub is a property
  of what discovery records, not re-validated by generation itself (Edge Cases).
