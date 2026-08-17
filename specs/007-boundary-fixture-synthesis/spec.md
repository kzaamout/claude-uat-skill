# Feature Specification: Scenario Generation — Boundary-Derived + Fixture Synthesis

**Feature Branch**: `007-boundary-fixture-synthesis`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "UAT-08 -- Scenario Generation: Boundary-Derived + Fixture Synthesis. User outcome: Critical/High-priority flows get real negative-path and boundary-case scenarios derived from actual validation code (form validation, API schema, ORM model), read per-flow at generation time rather than from a global upfront catalog; and when a draft needs a fixture that doesn't exist yet, the user gets a real, valid synthesized file offered through the same approval flow rather than the run blocking on a missing file. Scope included: boundary-derived generation (Critical/High priority flows only, per-flow introspection of validation/schema/ORM code to derive max-length/required-field/enum/type-mismatch cases); consolidated structured fixture/data list across every draft (filename, extension, constraint -- not a vague summary); Phase 0 fixture-synthesis offer through the same batched-approval mechanism as other data/fixture decisions, auto-synthesized and noted (not silently skipped) under --silent. Scope explicitly deferred: spec-derived and route-gap-derived generation (UAT-07, done). Dependencies: UAT-01 (done), UAT-06 (done, run isolation/data hygiene applies to synthesized fixtures same as any other UAT-created record), UAT-07 (done, this slice extends the same Generation mode section). Relevant existing specification sources: SKILL.md Generation mode step 2 (boundary-derived bullet, already exists in some form) and step 3 (fixture/data list, already exists); Phase 0's fixture-check step; docs/design-history.md R6 (boundary-derived portion). Completion evidence target: a Critical/High-priority flow's boundary-derived drafts trace to real validation rules read from actual code (not a generic template); a synthesized fixture (e.g. an oversized PDF) is confirmed to be a real, parseable file of its claimed type, not a placeholder. demo-app deliberately ships without sample-oversized.pdf so this can be demonstrated live rather than pre-staged."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Boundary-derived scenarios trace to real validation code (Priority: P1)

A user running `/webapp-uat generate` needs Critical/High-priority flows to get
negative-path and boundary-case scenarios derived from the flow's actual validation
rules — form validation, API schema, or ORM model constraints read directly from the
codebase — rather than a generic "test invalid input" template that doesn't reflect
what the app actually enforces.

**Why this priority**: Boundary-derived generation is this slice's core value —
turning real, already-written validation rules into concrete negative-path test
coverage without hand-transcription. Independently testable and valuable before
Story 2 exists.

**Independent Test**: Can be fully tested by running `generate` against a Critical or
High-priority flow with known validation constraints (e.g. a field with a max length
and a required enum) and confirming the resulting drafts name the actual constraint
values, not placeholder text.

**Acceptance Scenarios**:

1. **Given** a Critical or High-priority flow with form/API/ORM validation rules,
   **When** `generate` runs, **Then** it reads those rules directly from the
   flow's own code (not a global upfront catalog) at generation time and drafts
   boundary/negative-path scenarios reflecting the real constraint values.
2. **Given** a flow's validation includes a max-length field, a required field, an
   enum, and a type constraint, **When** boundary-derived generation runs for that
   flow, **Then** it drafts at least one scenario per distinct constraint category
   present (max-length, required-field, enum, type-mismatch) — not just one generic
   case.
3. **Given** a flow below Critical/High priority, **When** `generate` runs,
   **Then** no boundary-derived scenario is drafted for it — this source is scoped
   to Critical/High priority only, regardless of `--priority` filtering elsewhere.
4. **Given** a boundary-derived draft, **When** it's inspected, **Then** its
   `Source:` field is tagged `boundary-derived` and the specific validation rule it
   traces to is identifiable from the draft's content.

---

### User Story 2 - Every draft's fixture/data needs are consolidated into one structured list (Priority: P2)

A user running `generate` needs to see, in one place, exactly what fixtures and
seed data every drafted scenario (from any source) will require — filenames,
extensions, and constraints — rather than a vague summary or having to infer
requirements from reading each draft individually.

**Why this priority**: Makes the fixture/data footprint of a generation run
auditable in one glance before anything is approved or created. Priority P2: a
bookkeeping/aggregation step over whatever drafts already exist (from this slice's
Story 1 or from UAT-07's sources), not independently valuable on its own with zero
drafts to consolidate.

**Independent Test**: Can be fully tested by running `generate` against a set of
drafts with mixed fixture needs and confirming the consolidated list names every
required file with its extension and constraint, with none omitted.

**Acceptance Scenarios**:

1. **Given** a completed generation pass with drafts needing fixtures, **When**
   the fixture/data list is produced, **Then** it names every required file's
   filename, extension, and constraint (e.g. "valid, <1MB" or "intentionally
   malformed") as one consolidated, structured list — not prose summary.
2. **Given** multiple drafts (from any source, this slice's or UAT-07's) require
   the same fixture, **When** the list is produced, **Then** that fixture appears
   once, not duplicated per draft.
3. **Given** a draft requires new seed data (test accounts, seeded rows) rather
   than a static fixture file, **When** the list is produced, **Then** that seed
   data is named in the same consolidated list, distinguishable from static
   fixture files.

---

### User Story 3 - Missing fixtures are synthesized as real, valid files through the same approval flow (Priority: P1)

A user running `generate` whose drafts need a fixture that doesn't exist yet needs
the run to offer a genuinely valid synthesized file (e.g. an actual oversized but
parseable PDF) through the same approval decision as other data/fixture
requirements, rather than the run blocking, erroring, or fabricating a
placeholder that wouldn't actually exercise the intended boundary.

**Why this priority**: Without synthesis, boundary-derived generation's most
valuable cases (a file that's genuinely too large, genuinely malformed) can't be
exercised at all unless a user hand-crafts them first — defeating this slice's own
purpose. Independently valuable and testable without Story 1/2 existing (any
missing-fixture case triggers it).

**Independent Test**: Can be fully tested by running `generate` against a project
missing a fixture a draft needs, confirming a synthesis offer appears in the same
approval flow, and confirming the synthesized file is real and matches its claimed
type/constraint once created.

**Acceptance Scenarios**:

1. **Given** a draft requires a fixture file that does not exist under the
   project's fixtures directory, **When** the fixture/data list (Story 2) is
   presented for approval, **Then** synthesis of that missing fixture is offered
   as part of the same batched approval decision — not a separate blocking prompt.
2. **Given** synthesis is approved, **When** the fixture is created, **Then** it is
   a genuine, parseable file of its claimed type and constraint (e.g. an actually
   oversized, structurally valid PDF, not a renamed empty file or placeholder
   text).
3. **Given** `--silent` is set, **When** a missing fixture is encountered,
   **Then** it is auto-synthesized without a pause, and this is noted explicitly
   in the output — not silently skipped or silently created without record.
4. **Given** a fixture is synthesized during a run, **When** the file is written,
   **Then** it persists as a reusable static asset under the project's fixtures
   directory (not run-id-suffixed, not cleaned up at end-of-run) — distinct from
   any DB row a scenario separately creates that *references* the fixture (e.g. an
   uploaded-attachment record), which does follow `UAT-06`'s run-id-suffixed
   naming/cleanup discipline like any other UAT-created database record.

---

### Edge Cases

- What happens when a flow's validation code can't be read or parsed (e.g. an
  unfamiliar validation framework, or logic split across multiple files in a way
  that can't be confidently traced)? Boundary-derived generation for that flow is
  skipped and this is noted explicitly in the output — the same graceful,
  explicit-not-silent degradation pattern `UAT-07` established for its own missing
  prerequisites, rather than drafting a generic case that doesn't reflect real
  constraints.
- What happens when a fixture the fixture/data list names is already synthesizable
  in more than one plausible way (e.g. "oversized" could mean many different file
  sizes)? Synthesis uses the smallest value that unambiguously crosses the
  documented constraint (e.g. one byte over a stated size limit, or the
  conventional next round number above it if no exact limit is stated) — not
  resolved by asking the user, since this is a generation-time judgment call
  consistent with how this product already treats other qualitative
  classifications.
- What happens when a required fixture already exists but doesn't actually satisfy
  the constraint a new draft expects of it (e.g. an existing file is valid but too
  small to be the "oversized" case)? Treated the same as a missing fixture —
  synthesis is offered for a correctly-constrained file, existing name collisions
  aside; this feature does not silently reuse a same-named file that doesn't meet
  the current draft's actual requirement.
- What happens when a Critical/High-priority flow has zero validation constraints
  the introspection can find (e.g. a flow with no meaningful input validation at
  all)? No boundary-derived scenario is drafted for that flow, and this is not
  treated as an error — the same empty-but-explained outcome pattern `UAT-07`
  established for a prerequisite genuinely producing nothing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: For each Critical or High-priority flow, system MUST read that flow's
  actual form validation, API schema, and/or ORM model constraints directly from
  the codebase at generation time — not from a pre-built, global catalog of generic
  boundary cases.
- **FR-002**: System MUST draft at least one boundary/negative-path scenario per
  distinct constraint category found for a flow (max-length, required-field, enum,
  type-mismatch), when that category is present in the flow's validation.
- **FR-003**: System MUST NOT draft boundary-derived scenarios for a flow below
  Critical/High priority, independent of any `--priority` filtering applied to
  other sources.
- **FR-004**: Every boundary-derived draft MUST be tagged `Source: boundary-derived`
  and identifiably traceable to the specific validation rule it originated from.
- **FR-005**: System MUST consolidate the fixture/data requirements of every draft
  produced in a generation pass (from any active source) into one structured list
  naming filename, extension, and constraint for each required file or seed-data
  item — not a vague prose summary.
- **FR-006**: When multiple drafts require the same fixture, system MUST list that
  fixture once in the consolidated list, not once per requiring draft.
- **FR-007**: When a required fixture does not exist (or an existing same-named
  file does not satisfy the current draft's constraint), system MUST offer to
  synthesize it as part of the same batched approval decision as the rest of the
  fixture/data list — not as a separate blocking prompt and not silently skipped.
- **FR-008**: A synthesized fixture MUST be a genuine, parseable file of its
  claimed type that actually satisfies the constraint it was synthesized for (e.g.
  a structurally valid PDF that is genuinely over the stated size limit) — not a
  placeholder, empty file, or renamed unrelated file.
- **FR-009**: Under `--silent`, a missing fixture MUST be auto-synthesized without
  pausing for approval, and this action MUST be noted explicitly in the run's
  output.
- **FR-010**: A synthesized fixture file MUST persist as a reusable static asset
  under the project's fixtures directory — MUST NOT be run-id-suffixed or purged by
  end-of-run cleanup — distinct from any DB row a scenario separately creates that
  references the fixture (e.g. an uploaded-attachment record), which MUST follow
  `UAT-06`'s run-id-suffixed naming/cleanup discipline like any other UAT-created
  database record.
- **FR-011**: When a flow's validation code cannot be read or confidently parsed,
  system MUST skip boundary-derived generation for that flow and note this
  explicitly in the output, rather than drafting a generic case not grounded in
  real constraints.
- **FR-012**: When a Critical/High-priority flow has zero discoverable validation
  constraints, system MUST complete without drafting a boundary-derived scenario
  for that flow, and this MUST NOT be treated as an error.

### Key Entities

- **Boundary-Derived Draft**: A candidate negative-path/boundary scenario traced to
  one specific validation constraint (max-length, required-field, enum, or
  type-mismatch) on a Critical/High-priority flow, tagged `Source: boundary-derived`.
- **Consolidated Fixture/Data List**: The structured, deduplicated list of every
  fixture file and seed-data item any draft in the current generation pass
  requires, each entry naming filename/extension/constraint, feeding into the same
  approval decision as the drafts themselves.
- **Synthesized Fixture**: A genuinely valid, generation-time-created file
  satisfying a named constraint that no existing fixture already satisfies,
  produced through the same approval flow as other fixture/data decisions. The
  file itself persists as a reusable static asset, not subject to `UAT-06`'s
  run-isolation naming/cleanup — only a DB row that separately references it (if
  any) is.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of boundary-derived drafts produced by a `generate` run trace to
  a real, identifiable validation constraint read from the flow's own code, not a
  generic template.
- **SC-002**: Every distinct constraint category (max-length, required-field, enum,
  type-mismatch) present in a Critical/High-priority flow's validation produces at
  least one boundary-derived draft, in 100% of generation runs against that flow.
- **SC-003**: 100% of a generation run's fixture/data requirements, across every
  active source, appear in exactly one consolidated, structured list — no fixture
  named more than once, none omitted.
- **SC-004**: A missing fixture is never a run-blocking condition — 100% of
  missing-fixture cases either produce an approval-flow synthesis offer (default)
  or an auto-synthesis with an explicit note (`--silent`).
- **SC-005**: 100% of synthesized fixtures, when inspected, are genuine files of
  their claimed type that actually satisfy the constraint they were synthesized
  for.

## Assumptions

- **Spec-derived and route-gap-derived generation are out of scope**: fully
  specified and implemented by `UAT-07`; this feature only adds the third source
  (boundary-derived) and the fixture-synthesis mechanism.
- **Constraint-category coverage stays qualitative, not exhaustive**: "at least one
  scenario per distinct constraint category present" (FR-002) does not require
  enumerating every possible invalid value for a constraint — one representative
  boundary case per category is sufficient, consistent with how this product
  already treats other generation sources' scope (one candidate per acceptance
  criterion, not every possible acceptance-criterion phrasing).
- **Synthesis's "smallest unambiguous value" rule is a generation-time judgment
  call**: like this product's other qualitative classifications (persona
  derivation, high-risk assessment scope), the exact synthesized value is not
  further quantified here beyond the Edge Cases' stated rule.
- **Validation-code readability is assessed per flow, not globally**: a project
  using an unfamiliar validation framework for one flow but a readable one for
  another still gets boundary-derived coverage for the readable flow — FR-011's
  skip is per-flow, not all-or-nothing for the whole run.
