# webapp-uat — Claude Code UAT Skill

A Claude Code skill that runs automated end-user acceptance testing against your web
app, classifies what it finds, fixes confirmed bugs with a real browser-verified
retest, and reports back — without needing a human to babysit every step, while
keeping a human in the loop for anything genuinely risky.

Project-agnostic: point it at any web app by filling in one `config.md`. No specific
project, tech stack, or bug-tracking tool is assumed — see [Configuration](#configuration).

## Table of contents

- [What this does](#what-this-does)
- [Prerequisites](#prerequisites)
- [Installation & setup](#installation--setup)
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
4. For confirmed bugs: stop the app, assess and fix it (in-session by default, or via
   Spec Kit's bug workflow if configured), restart, and **retest in the browser** —
   not just re-run an automated test — before considering it fixed.
5. Verify the result actually landed correctly in the backend, wherever discovery
   finds one (relational DB, document store, vector store, API — whatever the app
   actually uses), not just that the UI looked right.
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
- **Your app's start/stop/health-check commands**, known ahead of time — whatever they
  are, filled into `scripts/dev.sh`.
- **Optional:** [Spec Kit](https://github.com/github/spec-kit) with its bug-workflow
  extension, if you want Phase 4's fix cycle to go through it instead of Claude
  fixing bugs directly in-session (confirm with `specify extension list` for the
  exact command names). Not required — the default (`bug-fix-mechanism: direct`)
  needs nothing beyond Claude Code itself.
- If Claude Desktop is also installed on this machine: known to conflict with Claude
  Code's Chrome bridge on macOS. Fully quit it before a session that needs `/chrome`.

---

## Installation & setup

Setup is two separate steps: getting the files into your repo (has to be done before
Claude Code can do anything here — `/webapp-uat` doesn't exist as a command until
these files exist), and configuring it (which the skill can mostly do for itself,
once it exists).

### 1. Copy the skill into your app's repo

```
.claude/skills/webapp-uat/     (the whole folder — SKILL.md, USAGE.md, SETUP.md, config.md.example)
scripts/dev.sh
uat/scenarios/_template.md
```

`SKILL.md` and `USAGE.md` are never hand-edited per project; everything
project-specific lives in `config.md`, so pulling in a future update to the skill is
just replacing those two files wholesale.

### 2. Run the setup wizard

```
/webapp-uat setup
```

This is a **discovery-assisted config wizard**, not a form to fill in blind. It reads
your repo — `package.json` scripts, `docker-compose.yml`/`Makefile`, a
`.specify/` directory, a `specs/` convention — and proposes `config.md` and
`scripts/dev.sh` values instead of making you go find them by hand. Every proposed
value is labeled with how confident that proposal actually is, and **nothing is
written until you confirm**:

- **detected** — concrete evidence found in the repo (a file, a script, a config
  entry) and named as the reason.
- **guessed** — a heuristic fallback with no real evidence behind it (e.g. port
  `3000` when nothing declares a port). Flagged so it doesn't get mistaken for
  something it actually found.
- **needs your input** — nothing found, or genuinely ambiguous (an unrecognized start
  mechanism, this skill sitting in a nested package of a monorepo). The wizard won't
  guess at this category — it asks.

What a typical run looks like:

```
No config.md found. Run setup now?

Detected:
  - Start: ./run.sh (docker-compose.yml present alongside it)
  - Stop: docker compose down
  - Bug-fix mechanism: direct (no .specify/ directory found)
  - Spec dir: specs/ (12 spec.md files found)

Guessed:
  - Port: 3000 (no PORT env var or dev-server config found — confirm this)

Needs your input:
  - project-name

Write config.md and scripts/dev.sh with these values / Edit first / Cancel?
```

On approval, it writes `config.md`, fills in `scripts/dev.sh`'s placeholders, and
creates any missing `uat/` subdirectory. It deliberately does **not** start or stop
your app itself as part of this — that first real start/stop happens under your eyes
in step 3, not silently during setup.

A couple of things it can't do for you, even when it detects Spec Kit is present:
exact `bug-assess-command`/`bug-fix-command`/`bug-test-command` names aren't guessed —
it surfaces `specify extension list`'s actual output and asks which entries are the
right three, since guessing wrong here means Phase 4 silently calls the wrong tooling.

Already have a `config.md`? Setup is safe to run again — it never overwrites
silently, it shows current vs. newly proposed values and asks first.

**Rather not use the wizard at all?** `config.md.example` documents every key for
filling in by hand — see [`SETUP.md`](.claude/skills/webapp-uat/SETUP.md) for the
fully manual path.

### 3. Confirm it actually works, then write a scenario

```bash
scripts/dev.sh start
scripts/dev.sh wait-ready
scripts/dev.sh stop
```

Run these once by hand before trusting them to an unattended pass. Then copy
`uat/scenarios/_template.md` into a real scenario file and drop anything it needs
into `uat/fixtures/`. Full checklist: [`SETUP.md`](.claude/skills/webapp-uat/SETUP.md).

---

## Quick start

```
/webapp-uat uat/scenarios/your-first-scenario.md
```

First run will be slower than the rest — it inspects your app's codebase once
(routing, locale, test-data tooling, backend verification options) and caches what
it finds. Every run after that reuses the cache instead of re-discovering.

---

## Commands

| Command | What it does |
|---|---|
| `/webapp-uat setup` | Discovery-assisted wizard — proposes `config.md`/`scripts/dev.sh` values, asks before writing |
| `/webapp-uat` | Run all scenarios in `uat/scenarios/` |
| `/webapp-uat <path>` | Run one scenario file, or all scenarios in a directory |
| `/webapp-uat --help` | Print the full usage reference (`USAGE.md`) |
| `/webapp-uat generate` | Draft scenarios from specs + schema + route gaps |
| `/webapp-uat generate <spec-path>` | Same, scoped to one feature |
| `/webapp-uat generate --priority <tiers>` | Same, scoped by priority tier |

Full syntax and examples: [`USAGE.md`](.claude/skills/webapp-uat/USAGE.md).

---

## Flags

### `--review-before-fix` / `--no-review-before-fix`

Overrides the project default for this invocation only.

- **On** (built-in default): after Phase 4's bug-assessment step, pauses and shows
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

Required. Project-level settings live in `.claude/skills/webapp-uat/config.md` —
created by `/webapp-uat setup` (recommended, see
[Installation & setup](#installation--setup)) or by copying `config.md.example` by
hand:

```markdown
# webapp-uat config

project-name: My App
project-dir: /path/to/my-app

bug-fix-mechanism: direct   # or: spec-kit (needs bug-assess/fix/test-command too)

spec-dir: specs/            # optional — omit if this repo has no spec convention

review-before-fix: on
```

No `config.md` → the skill stops at invocation and points here instead of guessing.

---

## How it works

| Phase | What happens |
|---|---|
| -1 — Invocation | Parses `--help`, `generate`, flags; resolves effective settings for this run |
| 0 — Pre-flight | Git clean, Chrome connected, app sanity-checked, fixtures verified, resume check, environment discovery (once), start-of-run cleanup |
| 0.5 — Discovery | First run only: inspects the app's routing, locale, test-data tooling, backend data stores; caches the result |
| Generation (`generate` only) | Drafts scenarios from specs/schema/routes, computes the full fixture/data list |
| 1 — Scenario review | Tightens scenarios, promotes any gap found into a real scenario on the spot, presents for approval |
| 2 — Execution | One scenario at a time in visible Chrome: console/network/screenshot capture, accessibility audit (axe-core), data-integrity check, UI-conformance check against the scenario's own spec (if configured), backend verification |
| 3 — Classification | Category (bug / unexpected behavior / UX friction / spec gap / test environment) plus severity (P0–P3) for bugs |
| 4 — Bug fix cycle | Stop → assess → (optional pause) → fix → test → restart → **browser retest** → commit, per bug, batched restart per scenario |
| 5 — Final report | Full breakdown, severity-sorted, recommendations, end-of-run cleanup, next-step options |

Full detail on every phase, with exact example output:
[`USAGE.md`](.claude/skills/webapp-uat/USAGE.md).

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
.claude/skills/webapp-uat/
  SKILL.md                        the skill's operating logic — never hand-edited per project
  USAGE.md                        full usage reference (also the --help output)
  config.md.example               template — copy to config.md and fill in
  config.md                       your project's settings (you create this)
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
  dev.sh                           start / stop / wait-ready wrapper for your app
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
- **`scripts/dev.sh` is a script file with placeholders, not pure config.** Setup
  mode now fills those placeholders in for you (see
  [Installation & setup](#installation--setup)), but the underlying mechanism is
  still "edit a script," not "declare commands in `config.md` and skip the script
  entirely." Whether to collapse it further into config-only is a separate,
  still-open discussion.
- A handful of other ideas were deliberately **recorded but not built**: chat-app-based
  approval (Slack, etc.), and collecting all bugs before deciding what to fix in
  parallel vs. sequence. Details and the reasoning behind holding off on each:
  [`docs/design-history.md`](docs/design-history.md).

---

## Related files

- [`USAGE.md`](.claude/skills/webapp-uat/USAGE.md) — the complete usage reference,
  also what `--help` prints
- [`SKILL.md`](.claude/skills/webapp-uat/SKILL.md) — the actual operating
  instructions Claude Code follows
- [`SETUP.md`](.claude/skills/webapp-uat/SETUP.md) — one-time setup checklist
- [`docs/design-history.md`](docs/design-history.md) — design history, resolved
  decisions, still-open questions, and deferred ideas
- [`uat/scenarios/_template.md`](uat/scenarios/_template.md) — the shape every
  scenario follows
