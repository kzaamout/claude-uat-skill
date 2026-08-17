# Contract: `/webapp-uat setup` interaction

This isn't a network API — it's the interactive contract between the wizard and the
person running it: what shape it presents, what choices it offers, and what it
guarantees about write outcomes. Downstream tasks/tests should treat this as the
thing being verified, the same way a REST contract would be for a service.

## 1. Draft presentation

Triggered on every `/webapp-uat setup` invocation, before any write.

**MUST include**, one row per field from `data-model.md`'s Configuration Draft:
- the field name
- the proposed value (or "—" if none could be determined)
- exactly one confidence label: `detected` (with the specific evidence named inline),
  `guessed`, or `needs your input`

**MUST NOT**: present two fields with different confidence levels in a way that
makes them look equally reliable (e.g., no visual/textual treatment that hides which
label applies to which field).

## 2. Decision

Presented immediately after the draft, exactly one choice among:

| Choice | Effect |
|---|---|
| Write this | proceeds to §3 |
| Edit values first | returns to draft presentation with the user's edits applied, re-offers this same decision |
| Cancel | ends the invocation; nothing is written (spec `FR-008`, Edge Case: cancel-before-write) |

## 3. Write outcome report

Emitted once the write step completes or fails, listing every item from
`data-model.md`'s Write Outcome table:

```
config.md ............... written
scripts/dev.sh ........... written
uat/scenarios/ ........... already existed, left as-is
uat/runs/ ................ created
uat/artifacts/ ........... created
uat/fixtures/ ............ FAILED — permission denied creating directory
```

**MUST**: report every item individually, even ones that succeeded — not just the
failures (so a partial-failure report is distinguishable from "nothing happened").

**MUST NOT**: undo an already-succeeded item because a later item failed (spec
`FR-013`).

**MUST**: state plainly that re-running setup will retry only the outstanding
(failed or not-yet-attempted) items, since already-written ones are left as-is.

## 4. Re-run comparison (User Story 2)

When `config.md` already exists, §1's draft presentation is replaced by a two-column
comparison — current value vs. newly-proposed value — per field, before §2's decision
is offered. A field where the current and newly-proposed values are identical MAY be
shown collapsed to one line rather than a redundant two-column row, but this is a
presentation choice, not a contract requirement.
