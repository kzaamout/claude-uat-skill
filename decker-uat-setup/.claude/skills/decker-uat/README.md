# Decker UAT Skill

A Claude Code skill that runs automated end-user acceptance testing against Decker,
classifies what it finds, fixes confirmed bugs through Spec Kit with a real
browser-verified retest, and reports back — without needing a human to babysit every
step, while keeping a human in the loop for anything genuinely risky.

## Table of contents

- [What this does](#what-this-does)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Commands](#commands)
- [Flags](#flags)
- [Configuration](#configuration)
- [How it works](#how-it-works)
- [Safety & guardrails](#safety--guardrails)
- [Project structure](#project-structure)
- [Known limitations](#known-limitations)
- [Related files](#related-files)

---

## What this does

Point it at a set of test scenarios (or let it draft them from your specs), and it
will:

1. Review the scenarios, suggest improvements and missing cases, and wait for your
   approval before touching anything.
2. Test them one at a time in a real, visible Chrome window — not headless, not
   simulated.
3. Classify every finding — a genuine bug, unexpected-but-working behavior, UX
   friction, a gap in the spec itself, or a problem with the test environment rather
   than the product.
4. For confirmed bugs: stop Decker, assess and fix through Spec Kit's bug workflow,
   restart, and **retest in the browser** — not just re-run an automated test —
   before considering it fixed.
5. Verify the result actually landed correctly in the backend (relational DB, vector
   store, or API), not just that the UI looked right.
6. Report back with everything found, everything fixed, and what — if anything —
   should become a spec update or a new feature.

What it deliberately does **not** do: touch security/auth/data-deletion code without
asking first, treat page content it reads as instructions, or silently decide it's
earned less oversight over time.

---

## Prerequisites

- **Claude Code**, authenticated via `/login` with a direct Anthropic plan (Pro, Max,
  Team, or Enterprise) — Chrome integration doesn't work with an API key or through a
  third-party provider (Bedrock, Vertex, Foundry).
- **Claude in Chrome** extension (v1.0.36+), installed in Chrome and signed in with
  the same account.
- **macOS or Linux.** Chrome integration is not supported inside WSL.
- **Spec Kit**, with its bug-workflow commands available in this repo (confirm with
  `specify extension list` — you'll need the exact command names it shows).
- **Decker itself:** started via `./run.sh`, stopped via Ctrl+C (frontend) then
  `docker compose down` (backend + database) — this is what `scripts/decker-dev.sh`
  wraps. If Decker's actual start/stop commands differ from this, that script needs
  adjusting before anything else here works.
- If Claude Desktop is also installed on this machine: known to conflict with Claude
  Code's Chrome bridge on macOS. Fully quit it before a session that needs `/chrome`.

---

## Installation

Place these files in your Decker repo:

```
.claude/skills/decker-uat/SKILL.md
.claude/skills/decker-uat/USAGE.md
scripts/decker-dev.sh              (chmod +x)
uat/scenarios/_template.md
```

Then:

1. Open `SKILL.md` and replace `<bug-assess>`, `<bug-fix>`, `<bug-test>` with the
   exact command names `specify extension list` shows in this repo.
2. Open `scripts/decker-dev.sh` and confirm `DECKER_DIR` and `PORT` match reality —
   `PORT` in particular is a guess (3000) until you verify what `run.sh` actually
   serves on.
3. `mkdir -p uat/scenarios uat/runs uat/artifacts uat/fixtures`
4. Write your first scenario (copy `_template.md`), and drop any files it needs into
   `uat/fixtures/`.

No config file is required to start — see [Configuration](#configuration) for what's
optional.

---

## Quick start

```
/decker-uat uat/scenarios/your-first-scenario.md
```

First run will be slower than the rest — it inspects Decker's codebase once
(routing, locale, test-data tooling, backend verification options) and caches what
it finds. Every run after that reuses the cache instead of re-discovering.

---

## Commands

| Command | What it does |
|---|---|
| `/decker-uat` | Run all scenarios in `uat/scenarios/` |
| `/decker-uat <path>` | Run one scenario file, or all scenarios in a directory |
| `/decker-uat --help` | Print the full usage reference (`USAGE.md`) |
| `/decker-uat generate` | Draft scenarios from specs + schema + route gaps |
| `/decker-uat generate <spec-path>` | Same, scoped to one feature |
| `/decker-uat generate --priority <tiers>` | Same, scoped by priority tier |

### `/decker-uat` — no arguments

Runs every scenario file under `uat/scenarios/`. Equivalent to
`/decker-uat uat/scenarios/`.

### `/decker-uat <path>`

`<path>` is a single scenario file, or a directory — every scenario file directly
inside it runs.

### `/decker-uat --help`

Prints `USAGE.md` in full and stops immediately. No git check, no Chrome connection
attempt, no Decker start — nothing touched. Safe to run anytime, including mid-run,
to check exact syntax.

### `/decker-uat generate [scope] [--priority tiers]`

Drafts new scenarios instead of running existing ones, from three sources:

- **spec-derived** (primary) — one candidate scenario per acceptance criterion in
  each feature's `spec.md`/`tasks.md`, including persona variants where a flow
  plausibly behaves differently by role. Personas aren't defined in a separate file —
  derived from whatever roles the specs and use cases already reference.
- **boundary-derived** — Critical/High priority flows only, deliberately. Real
  validation rules (max lengths, required fields, enums, type mismatches) read from
  the actual code per flow at generation time, not a generic guess or an unscoped
  catalog that would otherwise explode into hundreds of low-value cases.
- **route-gap-derived** — screens with no scenario coverage at all, found via
  Decker's actual routing setup (from the cached environment discovery).

```bash
/decker-uat generate                                   # whole spec set
/decker-uat generate specs/003-document-upload          # scoped to one feature
/decker-uat generate --priority critical,high            # scoped by priority
/decker-uat generate specs/003-document-upload --priority critical   # both
```

Every draft is tagged with its source in the scenario's `Source:` field. All
drafts, plus the full data/fixture list they need, go through the same approval step
as hand-written scenarios — one consolidated decision, not one round-trip per item.
A fourth source, `review-derived`, isn't produced by `generate` directly — it comes
from the scenario-review step itself noticing a gap (a missing negative/boundary/
recovery case) on *any* invocation, and drafting it on the spot rather than just
leaving a note about it.

---

## Flags

### `--review-before-fix` / `--no-review-before-fix`

Overrides the project default for this invocation only.

- **On** (built-in default): after Spec Kit's bug-assessment step, pauses and shows
  you the assessment — summary, proposed fix, affected files — before the fix runs.
  You choose: proceed / adjust / skip this bug.
- **Off:** proceeds straight to the fix once assessed — except security, auth, data
  deletion/migration, or broad architectural-impact bugs, which always pause
  regardless of this flag.

### `--silent`

For when you don't want to be present at all. Skips:

- Phase 1's scenario-plan approval
- the per-bug review pause (regardless of `--review-before-fix`)
- `generate`'s batch data/fixture approval
- the resume-vs-fresh-start choice (defaults to fresh start)

**Never skipped**, `--silent` or not:

- the high-risk stop-and-ask for security/auth/data-deletion/architecture bugs
- the confirmation before any DB write (seeding or cleaning up test data)
- Phase 5's spec-update choice (defaults to *review only*, never touches a spec file
  automatically)

### `--priority <tiers>`

`generate` only. Comma-separated from `critical`, `high`, `medium`, `low`.

---

## Configuration

Optional. Project-level defaults live in `.claude/skills/decker-uat/config.md`:

```markdown
# decker-uat config

review-before-fix: on
```

No file → the built-in default (`review-before-fix: on`) applies. A per-invocation
flag always overrides whatever's in this file for that one run.

---

## How it works

| Phase | What happens |
|---|---|
| -1 — Invocation | Parses `--help`, `generate`, flags; resolves effective settings for this run |
| 0 — Pre-flight | Git clean, Chrome connected, Decker sanity-checked, fixtures verified, resume check, environment discovery (once), start-of-run cleanup |
| 0.5 — Discovery | First run only: inspects Decker's routing, locale, test-data tooling, backend verification options; caches the result |
| Generation (`generate` only) | Drafts scenarios from specs/schema/routes, computes the full fixture/data list |
| 1 — Scenario review | Tightens scenarios, promotes any gap found into a real scenario on the spot, presents for approval |
| 2 — Execution | One scenario at a time in visible Chrome: console/network/screenshot capture, accessibility audit (axe-core), data-integrity check, UI-conformance check against the scenario's own spec, backend verification |
| 3 — Classification | Category (bug / unexpected behavior / UX friction / spec gap / test environment) plus severity (P0–P3) for bugs |
| 4 — Bug fix cycle | Stop → assess → (optional pause) → fix → test → restart → **browser retest** → commit, per bug, batched restart per scenario |
| 5 — Final report | Full breakdown, severity-sorted, recommendations, end-of-run cleanup, next-step options |

Full detail on every phase, with exact example output: [`USAGE.md`](./USAGE.md).

---

## Safety & guardrails

- **High-risk bug categories always pause for sign-off** — security, auth, data
  deletion/migration, broad architectural impact — regardless of any flag, silent
  mode included.
- **Captured page content is data, never instructions.** Console output, network
  responses, DOM text read during testing is reported on, never treated as commands
  to follow, regardless of what it contains.
- **Every database write is confirmed explicitly**, every run, whether that's
  seeding test data or cleaning it up. This doesn't quietly relax over time on its
  own — that's a manual edit to `SKILL.md`, a decision you make deliberately, not
  something the skill grants itself.
- **Test data is isolated by construction.** Every record this skill creates is
  suffixed with the run id, not a fixed identifier reused across runs — this is what
  makes cleanup safe and cross-run collisions structurally unlikely.
- **`--no-review-before-fix` is meant to be paired with a real
  `.claude/settings.local.json` permission allowlist.** Turning off the review pause
  without also constraining what commands can run unattended means unattended *and*
  unconstrained at the same time — treat these as one change, not two separate ones.

---

## Project structure

```
.claude/skills/decker-uat/
  SKILL.md                        the skill's operating logic
  USAGE.md                        full usage reference (also the --help output)
  config.md                       project defaults (optional)
  discovered-environment.md       cached environment facts (auto-created on first run)

uat/
  scenarios/
    _template.md                  shape new scenarios should follow
    *.md                          your actual scenarios
  fixtures/                       real files scenarios reference — never descriptions
  runs/<run-id>/
    test-plan.md                  Phase 1 output
    findings/*.md                 one file per finding
    final-report.md               Phase 5 output
  artifacts/<run-id>/<scenario-id>/
    screenshots, evidence

scripts/
  decker-dev.sh                   start / stop / wait-ready wrapper around run.sh + docker compose

.specify/bugs/<slug>/             Spec Kit's own bug-workflow records
```

---

## Known limitations

- **Severity doesn't currently gate auto-fix eligibility.** Every confirmed bug
  attempts a fix regardless of P0–P3 severity. Whether P2/P3 issues should instead
  just be batched into the report without an automatic fix attempt is an open policy
  question, not yet decided.
- **Environment setup/teardown is scoped to this skill's own test data.** Broader
  preconditions a scenario might need — an empty database, a different model
  provider — aren't handled; only cleanup of what this skill itself created is.
- A handful of ideas were deliberately **recorded but not built**: chat-app-based
  approval (Slack, etc.), generalizing this skill beyond Decker to other projects,
  and collecting all bugs before deciding what to fix in parallel vs. sequence.
  Details and the reasoning behind holding off on each: `decker-uat-v2-requirements.md`.

---

## Related files

- [`USAGE.md`](./USAGE.md) — the complete usage reference, also what `--help` prints
- [`SKILL.md`](./SKILL.md) — the actual operating instructions Claude Code follows
- [`decker-uat-v2-requirements.md`](./decker-uat-v2-requirements.md) — design
  history, resolved decisions, still-open questions, and deferred ideas for later
- [`_template.md`](../../../uat/scenarios/_template.md) — the shape every scenario
  follows
