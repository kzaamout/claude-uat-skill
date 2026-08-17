# Quickstart: Validating Boundary-Derived Generation + Fixture Synthesis

Manual validation runbook. `demo-app` deliberately ships without
`sample-oversized.pdf`, and has real zod validation (`lib/validation.ts`) on the
document-creation flow (title 3-120 chars, body 10-5000, ≤5 tags) — enough to
validate both this feature's real completion evidence targets directly.

Each scenario maps to acceptance scenarios in [spec.md](./spec.md).

## Prerequisites

- `demo-app` running, `webapp-uat` configured against it.
- A Critical or High-priority flow marked as such in `uat/scenarios/` or the
  project's priority convention — `demo-app`'s document-creation flow is a
  reasonable Critical/High candidate given it's the app's core write path.

## Scenario 1 — Boundary-derived drafts trace to real validation code

→ validates User Story 1, all 4 acceptance scenarios

Run `/webapp-uat generate` scoped to `demo-app`'s document-creation flow. Expect:
drafts naming the actual constraint values read from `lib/validation.ts` (title
3-120 chars, body 10-5000, ≤5 tags) — not generic "test invalid input" language;
at least one draft per distinct constraint category present (max-length on title
and body, the tag-count enum-like limit); each draft tagged `Source:
boundary-derived` with its specific validation rule identifiable. Re-run against a
flow below Critical/High priority (if one exists in the project's convention) —
confirm no boundary-derived draft is produced for it.

## Scenario 2 — Fixture/data needs are consolidated into one deduplicated list

→ validates User Story 2, all 3 acceptance scenarios

Run `generate` across a set of flows with overlapping fixture needs (e.g. two
different upload-related drafts both needing `sample-small.pdf`). Expect: one
consolidated, structured list naming every filename/extension/constraint; the
shared fixture appears exactly once, not duplicated per draft; any seed-data
requirement (e.g. a second team account) is named in the same list, distinguishable
from static fixture files.

## Scenario 3 — Missing fixtures are synthesized as real, valid files

→ validates User Story 3, all 4 acceptance scenarios

Run a scenario (hand-written or generated) whose Preconditions reference
`sample-oversized.pdf`, which `demo-app` deliberately does not ship. Expect: Phase
0's fixture-check offers synthesis as part of the same batched approval as other
data/fixture decisions — not a separate blocking prompt; once approved, the
resulting file is a real, structurally valid, oversized PDF, confirmed parseable
and genuinely over the app's stated size limit, not a placeholder. Re-run with
`--silent` — confirm the fixture is auto-synthesized with no pause, and the action
is noted explicitly in the final report. Inspect `uat/fixtures/` after the run —
confirm the synthesized file has a plain, non-run-id-suffixed filename and is
still present (not purged) after end-of-run cleanup runs.

## Done when

All 3 scenarios (11 acceptance criteria total) produce the expected outcome above.
Scenario 3 is fully live-verifiable against `demo-app` as-is (its missing
`sample-oversized.pdf` is deliberate, exactly for this purpose). Scenario 1 and
Scenario 2 are live-verifiable against `demo-app`'s document-creation flow, though
confirming the below-Critical/High-priority exclusion in Scenario 1 needs a project
whose priority convention actually marks some flow below that tier.
