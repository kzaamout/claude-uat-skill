# Data Model: Resumability & In-Run Gap Promotion

Process/state conventions, not a schema this feature owns.

## Interrupted Run

A `uat/runs/<run-id>/` directory containing `test-plan.md` but no
`final-report.md`.

| Field | Notes |
|---|---|
| detection | Phase 0, before app start or browser touch (`FR-001`) |
| tie-break | most recent by `run-id` (sortable `YYYY-MM-DD-HHmm`) when multiple exist; others left untouched, neither auto-resumed nor auto-purged (`FR-004`) |
| absence | no such directory found → no resume prompt, normal Phase 0 continues (`FR-003`) |

## Resume Decision

The three-way choice offered when an Interrupted Run is found.

| Value | Effect |
|---|---|
| **resume** | reuse existing `test-plan.md` without regenerating/re-reviewing it (`FR-005`); skip any scenario with a pre-interruption recorded result, carrying that result forward unchanged (`FR-006`); execute every scenario with no recorded result, in original plan order (`FR-007`); produce one final report covering the whole set (`FR-008`) |
| **abandon** | (implicit — start fresh is the only other listed choice; "abandon" without "start fresh" reads as: leave the interrupted run's directory as-is and stop, distinct from actively starting a new run) |
| **start fresh** | new `run-id`, new directory; interrupted run's directory left untouched — not deleted, not merged (`FR-009`, Edge Cases) |

| `--silent` behavior | Notes |
|---|---|
| interrupted run found | auto-resolves to abandon-and-start-fresh, no prompt (`FR-010`); final report states this explicitly every time (`FR-011`) |
| no interrupted run found | final report says nothing about resumability at all (`FR-012`) |

## Resume Execution Edge Case

| Condition | Handling |
|---|---|
| a resumed run's `test-plan.md` references a scenario file no longer on disk | reported as unable to resume/execute, explicitly, in the final report — not silently dropped from the count, not an abort of the whole resume (`FR-017`) |

## Gap-Promoted Scenario

A scenario file drafted in-line during Phase 1 review upon noticing a real
coverage gap.

| Field | Notes |
|---|---|
| trigger | a real gap noticed while reading through scenarios already under review — not a mandatory quota (`FR-013`, Edge Cases) |
| drafting | actual scenario file, standard template, immediately — not left as review-summary prose (`FR-013`) |
| tag | `Source: review-derived` (`FR-014`) |
| approval | included in the same approve/adjust/cancel decision as the rest of the batch (`FR-015`) |
| recursion bound | not itself re-reviewed for further gaps within the same pass; a deeper gap is available on a subsequent run's review (`FR-016`) |
