# Contract: Cleanup & seed-data confirmation interaction

Same nature as the prior two features' contracts — the interactive contract between
a DB-write moment and the person watching it, not a network API.

## 1. Start-of-run purge

**Trigger**: found ≥1 UAT-marked record left over from a prior run.

**MUST**: present a confirmation naming this as a database write, before performing
it. **MUST NOT**: skip this under `--silent` or any other flag.

**No leftover data found**: **MUST NOT** show this confirmation at all — the step
completes silently as a no-op.

**On decline**: the run **MUST** be blocked from proceeding — this is the one
confirmation in this contract where declining doesn't just skip a step, it stops
the run.

## 2. End-of-run purge

**Trigger**: this run's final report has just been written.

**MUST**: present a confirmation naming this as a database write, before performing
it, regardless of unresolved bugs in the report. **MUST NOT**: skip this under
`--silent` or any other flag.

**On decline**: the run **MUST** still be considered complete — the report already
exists; the leftover data becomes the *next* run's start-of-run purge concern
automatically (§1).

## 3. Seed-data creation (generation mode)

**Trigger**: an approved generation plan includes new seed data beyond static
fixture files.

**MUST**: present a confirmation distinct from the general plan
approve/adjust/cancel decision — not folded into it as a line item. **MUST NOT**:
skip this under `--silent` or any other flag.

## Invariant across all three

**MUST NOT**: any mechanism — a flag, a `config.md` setting, an internal
"trust" heuristic — ever cause one of these three confirmations to stop appearing.
Loosening this is only ever a deliberate, manual edit to `SKILL.md` itself.
