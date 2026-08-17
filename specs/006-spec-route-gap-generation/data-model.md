# Data Model: Scenario Generation — Spec-Derived + Route-Gap-Derived

Process/state conventions, not a schema this feature owns.

## Spec-Derived Draft

A candidate scenario traced to one specific acceptance criterion under `spec-dir`.

| Field | Notes |
|---|---|
| trigger | `config.md`'s `spec-dir` configured and readable (`FR-001`) |
| source | walks `spec.md` (and `tasks.md` alongside it) per feature under `spec-dir`, scoped to `scope` if provided (`FR-001`) |
| cardinality | one draft per acceptance criterion; multiple persona-specific variants where a flow's spec references multiple roles with plausibly different behavior (`FR-003`) |
| tag | `Source: spec-derived` (`FR-002`) |
| traceability | MUST be traceable back to the specific acceptance criterion it originated from (`FR-002`) |
| persona derivation | no separately maintained persona definition file — roles come from what the spec's own use cases reference (`FR-003`) |

## Route-Gap-Derived Draft

A stub scenario for a discovered screen with zero existing coverage.

| Field | Notes |
|---|---|
| trigger | Phase 0.5 discovery identified a routing source (`FR-004`) |
| source | cross-references discovered screens against `uat/scenarios/` (`FR-004`) |
| cardinality | one stub per screen with zero existing scenario coverage — not drafted for a screen with any coverage, however incomplete (`FR-004`, `FR-006`) |
| tag | `Source: route-gap-derived` (`FR-005`) |
| screen-vs-route filtering | Phase 0.5's concern, not re-validated by generation (Assumptions) |

## Generation Prerequisite State

Per-source readiness that determines which sources run a given `generate`
invocation, each degrading independently and explicitly when unmet — the entity
this feature's two real gaps (FR-008/009) center on.

| State | spec-derived | route-gap-derived | Outcome |
|---|---|---|---|
| `spec-dir` configured; routing source discovered | runs | runs | both sources produce drafts (`FR-001`, `FR-004`) |
| `spec-dir` unconfigured; routing source discovered | skipped, noted in output | runs | existing degradation case (`FR-007`) |
| `spec-dir` configured; routing source undiscoverable | runs | skipped, noted in output | symmetric case, the first identified gap (`FR-008`) |
| neither met | skipped | skipped | explicit "no drafts produced" note, not an error — the second identified gap (`FR-009`) |

## Priority Scope

A cross-cutting filter over both draft sources, not an entity of its own.

| Field | Notes |
|---|---|
| trigger | `--priority <tiers>` passed to `generate` (`FR-010`) |
| effect | scopes generation to only the specified priority tiers, across whichever sources are active — not tied to one source alone (`FR-010`, the second identified gap alongside FR-012) |
| zero-eligible-flows | completes with zero drafts and an explicit note, same treatment as the neither-prerequisite-met case, not an error (`FR-012`) |
| independent of `scope` | applies across the full `spec-dir`/routing source without requiring a narrow `scope` path to combine with it (US4 AC3) |

## Source Tag

| Field | Notes |
|---|---|
| values | `spec-derived`, `route-gap-derived` |
| coverage | MUST be present on 100% of drafts produced by any `generate` run, regardless of source (`FR-011`) |
