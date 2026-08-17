# Contract: Generation source selection & degradation

The process contract for how `generate` decides which sources run and how every
draft gets tagged — not a network API.

## 1. Prerequisite check

**Trigger**: `/webapp-uat generate` invoked (with or without `scope`/`--priority`).

**MUST**: check `config.md`'s `spec-dir` for configured-and-readable state
(`FR-001`). **MUST**: check whether Phase 0.5 discovery identified a routing source
(`FR-004`).

## 2. Spec-derived generation

**Trigger**: `spec-dir` configured and readable.

**MUST**: walk `spec.md` (and `tasks.md` alongside it) per feature under `spec-dir`,
scoped to `scope` if provided, and draft one candidate scenario per acceptance
criterion (`FR-001`). **MUST**: tag every such draft `Source: spec-derived` and keep
it traceable back to its originating acceptance criterion (`FR-002`). **MUST**:
where a flow's spec references multiple roles with plausibly different behavior,
generate one persona-specific variant per referenced role, without a separately
maintained persona catalog (`FR-003`).

**Trigger**: `spec-dir` NOT configured or not readable.

**MUST**: skip spec-derived generation and note this explicitly in the output
(`FR-007`).

## 3. Route-gap-derived generation

**Trigger**: Phase 0.5 discovery identified a routing source.

**MUST**: cross-reference discovered screens against `uat/scenarios/` and draft one
stub for every screen with zero existing scenario coverage (`FR-004`). **MUST**:
tag every such draft `Source: route-gap-derived` (`FR-005`). **MUST NOT**: draft a
stub for a screen that already has at least one existing scenario, regardless of how
complete that coverage is (`FR-006`).

**Trigger**: Phase 0.5 discovery found no routing source.

**MUST**: skip route-gap-derived generation and note this explicitly in the output
(`FR-008`).

## 4. Neither prerequisite met

**Trigger**: `spec-dir` unconfigured/unreadable AND no routing source discovered.

**MUST**: complete the `generate` run with an explicit note that no drafts were
produced from either source, rather than erroring (`FR-009`).

## 5. Priority scoping

**Trigger**: `--priority <tiers>` passed.

**MUST**: scope generation to only the specified priority tiers, across whichever
sources are active per §2-§4 (`FR-010`). **MUST**: apply this scoping across the
full `spec-dir`/routing source, without requiring a narrow `scope` path to combine
with it.

**Trigger**: `--priority` scoping results in zero eligible flows.

**MUST**: complete with zero drafts and an explicit note, not an error — same
treatment as §4 (`FR-012`).

## 6. Source tagging (cross-cutting)

**Trigger**: any draft is produced by any active source.

**MUST**: carry a `Source:` tag identifying its origin (`spec-derived` or
`route-gap-derived`) — MUST NOT be left untagged, on 100% of drafts across every
`generate` run (`FR-011`).

## 7. No cross-source deduplication

**Trigger**: the same screen is both a route-gap (no coverage) and the subject of a
spec-derived draft in the same run.

**MUST**: produce both drafts independently, each tagged with its own true source —
MUST NOT merge or deduplicate them, even where they cover overlapping UI (Edge
Cases).
