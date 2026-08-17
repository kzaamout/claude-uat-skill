# Data Model: Scenario Generation — Boundary-Derived + Fixture Synthesis

Process/state conventions, not a schema this feature owns.

## Boundary-Derived Draft

A candidate negative-path/boundary scenario traced to one specific validation
constraint on a Critical/High-priority flow.

| Field | Notes |
|---|---|
| trigger | flow is Critical or High priority (`FR-003`) |
| source | reads form validation / API schema / ORM model directly from the flow's own code, at generation time, not a global catalog (`FR-001`) |
| cardinality | at least one draft per distinct constraint category present (max-length, required-field, enum, type-mismatch) — not one generic case (`FR-002`) |
| tag | `Source: boundary-derived` (`FR-004`) |
| traceability | identifiable back to the specific validation rule it originated from (`FR-004`) |
| unreadable validation | skipped for that flow, noted explicitly, not replaced with a generic ungrounded case (`FR-011`) |
| zero constraints found | flow produces no boundary-derived draft; not an error (`FR-012`) |

## Consolidated Fixture/Data List

The structured, deduplicated list of every fixture file and seed-data item any
draft in the current generation pass requires — this feature's extension of
Generation mode step 3, which `UAT-07`'s spec-derived/route-gap-derived drafts
already feed into.

| Field | Notes |
|---|---|
| entries | filename, extension, constraint per required file or seed-data item (`FR-005`) |
| dedup | a fixture required by multiple drafts appears once, not once per draft (`FR-006`) |
| seed data | distinguishable from static fixture files within the same list (`FR-005`, US2 AC3) |

## Synthesized Fixture

A genuinely valid, generation-time-created file satisfying a named constraint that
no existing fixture already satisfies. **Not owned by this feature's Generation
mode edits** — the synthesis mechanism itself lives in Phase 0's existing
fixture-check step, which this feature's fixture list (above) feeds.

| Field | Notes |
|---|---|
| trigger | a required fixture is missing, or an existing same-named file doesn't satisfy the current constraint (`FR-007`) |
| offer | part of the same batched approval decision as the rest of the fixture/data list — not a separate blocking prompt (`FR-007`) |
| genuineness | a real, parseable file of its claimed type that actually satisfies the constraint (`FR-008`) |
| `--silent` behavior | auto-synthesized, explicitly noted in output, never silently skipped (`FR-009`) |
| persistence | persists as a reusable static asset under the project's fixtures directory — NOT run-id-suffixed, NOT purged at end-of-run (`FR-010`, corrected during drafting — see `research.md`) |
| DB-row distinction | a separate DB row a scenario creates that *references* the fixture (e.g. an attachment record) follows `UAT-06`'s run-isolation discipline; the fixture file itself does not (`FR-010`) |
| ambiguous target value | smallest value that unambiguously crosses the documented constraint — a generation-time judgment call, not a clarification round (Edge Cases) |
