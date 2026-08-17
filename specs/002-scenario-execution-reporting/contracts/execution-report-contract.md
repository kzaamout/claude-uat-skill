# Contract: Scenario execution, classification & report interaction

Same nature as `UAT-01`'s contract — not a network API, the interactive contract
between the run and the person watching it.

## 1. Plan approval (Phase 1)

**MUST** happen before any app start or browser action (`FR-001`, `FR-002`).

Decision offered: exactly one of **approve and begin** / **adjust scenarios** /
**cancel**. Nothing runs on anything but explicit approval.

## 2. Per-scenario progress line (Phase 2, `FR-011`)

Printed once per scenario, after it completes, before moving to the next:

```
Scenario N/M done — <summary>
```

`<summary>` is a short human-readable outcome (e.g. "1 bug found", "clean").

## 3. Classification (Phase 3)

**MUST**: every finding gets exactly one category. `BUG` **MUST** also get exactly
one severity, and no other category may. `UNEXPECTED_BEHAVIOUR`/`UX_FRICTION`/
`SPEC_GAP` **MUST** get exactly one recommendation (`no action` / `update the
existing feature spec` / `new feature spec` / `needs more research`).
`TEST_ENVIRONMENT` gets neither a severity nor a recommendation — it pauses the run
rather than becoming a documentable spec/product follow-up item.

**Category boundary this contract enforces explicitly** (the one clarified this
session): a Chrome/browser-automation/fixture problem is `TEST_ENVIRONMENT`; the app
under test crashing or hanging is `BUG` (typically `P0`) — never the reverse, and
never ambiguous between the two.

## 4. Final report & disposition (Phase 5)

**MUST** include: scenario status breakdown; every finding, `BUG`s sorted by
severity within status group; any deviation from full manual approval, stated
plainly, never omitted (`FR-016`).

Disposition decision offered after the report: exactly one of **review only** /
**draft a spec update** / **draft a new feature spec** / **defer selected items**.

**MUST NOT**: touch any spec file automatically, regardless of which disposition is
chosen — a spec update or new feature spec being *drafted* is not the same as it
being *applied*, and this feature's scope stops at the offer/report, not the draft
content itself (drafting is a separate, later action outside this contract).
