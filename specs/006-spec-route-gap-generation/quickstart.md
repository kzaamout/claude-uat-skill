# Quickstart: Validating Scenario Generation (Spec-Derived + Route-Gap-Derived)

Manual validation runbook. `demo-app` currently has a discoverable routing source
but deliberately no `specs/` yet (per its own README) — it validates the
route-gap-derived path and the spec-dir-unconfigured degradation case directly, but
not spec-derived generation's happy path, which needs a separate project with a real
`spec-dir`.

Each scenario maps to acceptance scenarios in [spec.md](./spec.md).

## Prerequisites

- A project with `config.md`'s `spec-dir` configured and readable, containing at
  least one feature with `spec.md` acceptance scenarios — for Scenario 1.
- `demo-app` running, `webapp-uat` configured against it, Phase 0.5 discovery able
  to find its routing source (Next.js App Router) — for Scenario 2 and 3.

## Scenario 1 — Spec-derived drafts trace back to real acceptance criteria

→ validates User Story 1, all 4 acceptance scenarios

Run `/webapp-uat generate` against a project with a configured `spec-dir`. Expect:
one candidate draft per acceptance criterion found under `spec-dir`; each draft
tagged `Source: spec-derived` and traceable to its specific criterion; where a
flow's spec references multiple roles (e.g. admin/standard/guest), one
persona-specific variant per role, with no separate persona catalog file involved.
Re-run with a `scope` path passed — confirm generation is scoped to that path rather
than walking the entire `spec-dir`.

## Scenario 2 — Route-gap-derived stubs cover `demo-app`'s uncovered screens

→ validates User Story 2, all 3 acceptance scenarios

Run `/webapp-uat generate` against `demo-app` (which deliberately has no `spec-dir`
yet, so this exercises route-gap-derived generation alone). Expect: a stub drafted
for `/profile` and the `/settings` landing page (deliberately left uncovered by the
bundled root `uat/scenarios/`), each tagged `Source: route-gap-derived`; no stub
drafted for any screen the bundled scenarios already cover (e.g.
`/teams/[teamId]/documents`), even though that coverage isn't exhaustive.

## Scenario 3 — Generation degrades gracefully when a prerequisite is missing

→ validates User Story 3, all 3 acceptance scenarios

**Part A** (spec-dir missing, existing case): run `generate` against `demo-app` as-is
(no `spec-dir` configured). Expect: spec-derived generation skipped, noted
explicitly in output; route-gap-derived generation still runs normally (Scenario 2's
result).

**Part B** (routing source undiscoverable, the newly-specified symmetric case):
temporarily point `webapp-uat` at a project with a configured `spec-dir` but no
discoverable routing source (e.g. an empty/non-standard directory structure Phase
0.5 can't identify). Expect: route-gap-derived generation skipped, noted explicitly
in output; spec-derived generation still runs normally.

**Part C** (neither met): run `generate` against a project with neither a
`spec-dir` nor a discoverable routing source. Expect: the run completes with an
explicit note that no drafts were produced from either source — not an error.

## Scenario 4 — Priority scoping and consistent source tagging

→ validates User Story 4, all 3 acceptance scenarios

Run `generate --priority critical,high` against a project with flows at mixed
priority tiers and both sources active. Expect: only flows at those tiers are
drafted, across both spec-derived and route-gap-derived sources. Inspect the full
batch of drafts from a mixed-source run — confirm every single one carries a
`Source:` tag, none left untagged. Re-run `--priority` scoped to a tier with zero
matching flows — expect zero drafts and an explicit note, not an error. Re-run
`--priority` with no `scope` path — confirm it still applies across the full
`spec-dir`/routing source rather than requiring a narrow path to combine with it.

## Done when

All 4 scenarios (13 acceptance criteria total) produce the expected outcome above.
Scenario 2 and Scenario 3 Part A run cleanly against `demo-app` as-is. Scenario 1,
Scenario 3 Part B/C, and Scenario 4 need a project with a real `spec-dir` (or a
deliberately routing-undiscoverable/prerequisite-free setup) constructed for the
purpose — `demo-app` alone can't exercise every case since it deliberately has no
`specs/` yet.
