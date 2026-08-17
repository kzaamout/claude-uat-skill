# Contract: Boundary-derived drafting & fixture synthesis

The process contract for how a Critical/High-priority flow's real validation rules
become boundary-derived drafts, and how the resulting fixture needs get satisfied —
not a network API.

## 1. Boundary-derived source eligibility

**Trigger**: a flow is being considered for generation.

**MUST**: only draft boundary-derived scenarios for a Critical or High-priority
flow (`FR-003`) — independent of any `--priority` filtering applied elsewhere.

## 2. Per-flow, per-generation-time introspection

**Trigger**: an eligible flow is reached during a `generate` run.

**MUST**: read that flow's actual form validation / API schema / ORM model
constraints directly from the codebase, at generation time — MUST NOT rely on a
pre-built, global catalog of generic boundary cases (`FR-001`).

**Trigger**: the flow's validation code cannot be confidently read or parsed.

**MUST**: skip boundary-derived generation for that flow, and note this explicitly
in the output — MUST NOT fall back to a generic, ungrounded case (`FR-011`).

## 3. Drafting cardinality

**Trigger**: introspection completes for an eligible, readable flow.

**MUST**: draft at least one scenario per distinct constraint category present
(max-length, required-field, enum, type-mismatch) — not merely one generic case
per flow (`FR-002`). **MUST**: tag every such draft `Source: boundary-derived` and
keep it identifiably traceable to its specific originating validation rule
(`FR-004`).

**Trigger**: introspection finds zero discoverable constraints for an otherwise
eligible flow.

**MUST**: complete without drafting a boundary-derived scenario for that flow —
MUST NOT treat this as an error (`FR-012`).

## 4. Fixture/data list consolidation

**Trigger**: a generation pass produces one or more drafts, from any active
source, with fixture or seed-data needs.

**MUST**: consolidate every requirement into one structured list naming filename,
extension, and constraint per item — MUST NOT summarize as vague prose (`FR-005`).
**MUST**: list a fixture required by multiple drafts exactly once, not once per
requiring draft (`FR-006`).

## 5. Fixture synthesis (Phase 0's existing mechanism — unchanged by this feature)

**Trigger**: a fixture the consolidated list names does not exist, or an existing
same-named file doesn't satisfy the current constraint.

**MUST**: offer synthesis as part of the same batched approval decision as the
rest of the fixture/data list (`FR-007`). **MUST**: produce a genuinely valid,
parseable file of its claimed type that actually satisfies the constraint it was
synthesized for (`FR-008`). **MUST**, under `--silent`: auto-synthesize without
pausing, and note this explicitly in the run's output (`FR-009`).

## 6. Synthesized fixture persistence

**Trigger**: a fixture is synthesized.

**MUST**: persist the resulting file as a reusable static asset under the
project's fixtures directory — MUST NOT run-id-suffix it or purge it at
end-of-run (`FR-010`). **MUST**, for any DB row a scenario separately creates that
*references* the fixture: follow `UAT-06`'s run-id-suffixed naming/cleanup
discipline as normal — this distinction applies to the file only, not to any
database record pointing at it.
