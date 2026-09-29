# webapp-uat — Claude Code UAT Skill

A Claude Code skill that runs automated end-user acceptance testing against your web
app, classifies what it finds, fixes confirmed bugs with a real browser-verified
retest, and reports back — without needing a human to babysit every step, while
keeping a human in the loop for anything genuinely risky.

Project-agnostic: point it at any web app by filling in a short `config.md` plus a
`scripts/dev.env` holding your start/stop values (the setup wizard drafts both). No
specific project, tech stack, or bug-tracking tool is assumed — see
[Configuration](#configuration).

## Table of contents

- [What this does](#what-this-does)
- [Prerequisites](#prerequisites)
- [Installation & setup](#installation--setup)
- [Updating](#updating)
- [Quick start](#quick-start)
- [Try it with the bundled demo app](#try-it-with-the-bundled-demo-app)
- [Commands](#commands)
- [Flags](#flags)
- [Configuration](#configuration)
- [How it works](#how-it-works)
- [Safety & guardrails](#safety--guardrails)
- [Test scenarios](#test-scenarios)
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
- **Claude Code 2.1.263 or later** (the version this was verified on) — the skill
  relies on skill-folder path substitution and a load-time status check that older
  versions don't have; on those, the skill aborts at load instead of running.
- **Claude in Chrome** extension (v1.0.36+), installed in Chrome and signed in with
  the same account.
- **macOS or Linux.** Chrome integration is not supported inside WSL.
- **Your app's start/stop/health-check commands**, known ahead of time — whatever they
  are, they end up in `scripts/dev.env` (the setup wizard proposes them from your repo).
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

### 1. Get the skill into your app's repo

**Plugin install** (recommended — two commands, nothing copied by hand), from inside
your app's repo:

```
/plugin marketplace add kzaamout/claude-uat-skill
/plugin install webapp-uat@webapp-uat-marketplace
```

This makes `/webapp-uat` available in that project (the skill's own files live in
Claude Code's plugin cache, not in your tree). `scripts/dev.sh` and
`uat/scenarios/_template.md` still need to exist in your repo's own tree — a plugin
install can only place files under `.claude/`, not elsewhere in your project — so step
2 below (`/webapp-uat setup`) places them for you from the copies bundled inside the
installed skill, and writes `scripts/dev.env` with your app's start/stop values next
to them. Those two placed files stay *managed*: later skill updates replace them on
their own (see [Updating](#updating)); `scripts/dev.env` is yours.

**Manual alternative**, if you'd rather not use the plugin system: copy from this
skill's source repo into your app's repo root —

```
.claude/skills/webapp-uat/     (the whole folder — SKILL.md, USAGE.md, SETUP.md, config.md.example, scripts/, templates/)
scripts/dev.sh
scripts/dev.env.example        (copy to scripts/dev.env and fill in — or let the wizard write it)
uat/scenarios/_template.md
```

Either way, nothing in the skill folder is hand-edited per project — everything
project-specific lives in `config.md` and `scripts/dev.env` — and pulling in a future
update is two commands plus a restart; see [Updating](#updating).

### 2. Run the setup wizard

```
/webapp-uat setup
```

This is a **discovery-assisted config wizard**, not a form to fill in blind. It reads
your repo — `package.json` scripts, `docker-compose.yml`/`Makefile`, a
`.specify/` directory, a `specs/` convention — and proposes `config.md` and
`scripts/dev.env` values instead of making you go find them by hand. Every proposed
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

Write config.md and scripts/dev.env with these values / Edit first / Cancel?
```

On approval, it writes `config.md` and `scripts/dev.env`, places the skill's managed
files (`scripts/dev.sh`, `uat/scenarios/_template.md`) from the copies bundled in the
installed skill, creates any missing `uat/` subdirectory, and makes sure four files are
gitignored — the two `scripts/dev.sh start` generates (`dev.log`, `.webapp-uat.pid`)
and the two the skill keeps under `.claude/skills/webapp-uat/` (`config.md`, which
holds an absolute path, and the `discovered-environment.md` cache) — appending them
to your `.gitignore` if an existing pattern doesn't already cover them, since a run's
leftovers or the config itself would otherwise trip the clean-working-tree check the
next run starts with. `scripts/dev.env` is meant to be committed. It deliberately does **not** start or stop your app itself as
part of this — that first real start/stop happens under your eyes in step 3, not
silently during setup.

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

Run these once by hand before trusting them to an unattended pass. (`wait-ready`
gives up after ~30 seconds by default — a slow-booting app can raise that with
`WAIT_TIMEOUT` in `scripts/dev.env`, or per-run via the `WAIT_TIMEOUT` environment
variable. `scripts/dev.sh` itself is managed by the skill — don't edit it; every value
it needs comes from `scripts/dev.env`.) Then copy
`uat/scenarios/_template.md` into a real scenario file and drop anything it needs
into `uat/fixtures/`. Full checklist: [`SETUP.md`](.claude/skills/webapp-uat/SETUP.md).

---

## Updating

Two steps: get the newer skill onto your machine, then let the next run bring the
files it manages in your repo up to date. Nothing you own is touched by either.

**Plugin install** — run both, in this order (the second doesn't refresh the
marketplace clone on its own), then restart Claude Code:

```
claude plugin marketplace update webapp-uat-marketplace
claude plugin update webapp-uat@webapp-uat-marketplace
```

The same two actions are available under `/plugin` inside a session. If you installed
with `--scope project`, pass the same scope to `plugin update`. Every commit on this
repo's `main` counts as a new version — there's no version number to wait for.

**Manual install** — copy `.claude/skills/webapp-uat/` from this repo over your
project's copy again. `config.md` and `discovered-environment.md` are yours and
aren't in this repo, so nothing overwrites them.

**What the next `/webapp-uat` run does.** The skill owns two files that have to live
in your repo's own tree — `scripts/dev.sh` and `uat/scenarios/_template.md` — and marks
each with a "webapp-uat managed file" line near the top. Every invocation (even
`--help`) compares your copies with the ones bundled in the installed skill at load
and tells you if either is out of date. Pre-flight on the next real run then
overwrites the out-of-date ones and commits exactly those paths as one
`chore(webapp-uat): update managed files (…)` commit — automatically, `--silent`
included, because those files carry nothing of yours. The final report lists what
was updated. (`/webapp-uat setup` refreshes them too, but leaves committing to you,
alongside the `config.md` and `scripts/dev.env` it writes.) Managed files are
compared byte for byte, so there's nothing to merge and no version to bump.

**What is never touched:** `scripts/dev.env` (your start/stop values — the reason
`scripts/dev.sh` can be replaced at all), `config.md`, `discovered-environment.md`,
your scenarios, fixtures, run history, and artifacts.

**Taking ownership of a managed file.** Need to change `scripts/dev.sh` beyond what
`scripts/dev.env` allows? Delete the marker line. From then on the skill leaves that
file alone, tells you once per run that it's unmanaged, and never reclaims it
silently — `/webapp-uat setup` offers to put the skill's version back, and only does
so if you say yes.

**Installs from before this mechanism existed** have a `scripts/dev.sh` with the four
values written into it. The skill recognizes that as legacy and keeps using it as is;
`/webapp-uat setup` (or any attended run) shows the values it keeps (start command,
stop command, port, and wait timeout if one was set) and offers to move them into
`scripts/dev.env` and replace the script with the managed one. Nothing changes until
you confirm; `--silent` runs never migrate. Such installs also have a
`uat/scenarios/_template.md` without the marker line; it is reported as unmanaged
(no marker) until `/webapp-uat setup` re-adopts it, which it offers to do.

---

## Quick start

```
/webapp-uat uat/scenarios/your-first-scenario.md
```

First run will be slower than the rest — it inspects your app's codebase once
(routing, locale, test-data tooling, backend verification options) and caches what
it finds. Every run after that reuses the cache instead of re-discovering.

---

## Try it with the bundled demo app

Don't have a project to point this at yet, or just want to see it run before wiring it
into your own app? This repo includes a real, working demo app —
[`demo-app`](demo-app) — a Next.js + Postgres "Team Documents" app with roles,
uploads, comments, and three seeded, off-by-default bugs (a permission bypass, a
missing-label accessibility violation, and a silent backend-write failure) purpose-built
to exercise every phase of this skill, including the parts a UI-only check would miss.

`demo-app` is a **git submodule** — its own independent repo
([`webapp-uat-demo`](https://github.com/kzaamout/webapp-uat-demo)), not plain files
in this one. It needs its own start/stop commands and its own `config.md`, and keeping
it separate means this skill's own root-detection (`git rev-parse --show-toplevel`)
resolves correctly against the demo app's actual repo root instead of this one's — see
[`docs/design-history.md`](docs/design-history.md) D6 for why a plain subdirectory
didn't work here.

### See it run

Three short recordings against the demo app's seeded silent-comment-failure bug, in
sequence:

![A scenario running in a real Chrome window: login as the scenario's account, then the documents list](docs/gifs/uat-scenario-execution.gif)

![The catch: the UI says "Comment added" but the count stays at 0, and a direct Postgres read finds no row](docs/gifs/uat-bug-found-ui-lies.gif)

![After the fix and an app restart, the same steps re-driven: the comment persists and renders](docs/gifs/uat-fix-retest-passing.gif)

### Get it

If you're cloning this repo fresh, pull the submodule in the same step:

```bash
git clone --recurse-submodules https://github.com/kzaamout/claude-uat-skill.git
```

Already have a local clone without it?

```bash
git submodule update --init
```

### Run it, then test it

Two terminals. In the first, bring the app up:

```bash
cd demo-app
./run.sh                   # brings up Postgres, migrates, seeds, starts the dev server
```

In the second, start a Claude Code session **rooted in `demo-app/`** — a session
rooted at this repo would load this repo's copy of the skill instead of the demo's
own installed copy (see [Known limitations](#known-limitations)) — and run setup
inside it:

```bash
cd demo-app
claude --chrome
```

```
/webapp-uat setup          # proposes config.md from what's actually in demo-app/
```

From there, `demo-app`'s own [`README.md`](https://github.com/kzaamout/webapp-uat-demo#readme)
has the full walkthrough: seeded accounts, what the app is built to exercise, and a
step-by-step testing guide — one section per command/scenario (setup, running one
scenario, running all of them, `generate`, each of the three seeded bugs, `--silent`
mode, fixture auto-synthesis) with the steps, the expected outcome, and why, for each.

---

## Commands

| Command | What it does |
|---|---|
| `/webapp-uat setup` | Discovery-assisted wizard — proposes `config.md`/`scripts/dev.env` values, places/updates the managed files, asks before writing |
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
- under `bug-fix-mechanism: spec-kit`: the pause when a configured bug-workflow
  command itself fails to run — a tool-invocation failure is the tooling breaking,
  not a routine decision

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

No `config.md` → the skill offers to run setup on the spot, or points here if you
decline, instead of guessing.

---

## How it works

| Step | What happens |
|---|---|
| 1. Invocation | Parses `setup`, `generate`, `--help` and the flags; resolves the effective settings for this run |
| 2. Pre-flight | Managed files brought up to date, `config.md` validated, git tree clean, Chrome connected, app sanity-checked, fixtures verified, resume check, start-of-run cleanup |
| 3. Discovery | First run only: inspects the app's routing, locale, test-data tooling and backend data stores; caches the result for every later run |
| 4. Generation (`generate` only) | Drafts scenarios from specs, validation code and route gaps; computes the full fixture/data list |
| 5. Scenario review | Tightens scenarios, promotes any gap found into a real scenario on the spot, presents the plan for approval |
| 6. Execution | One scenario at a time in visible Chrome: console/network/screenshot capture, accessibility audit (axe-core), data-integrity check, UI-conformance check against the scenario's own spec (if configured), backend verification |
| 7. Classification | Category (bug / unexpected behavior / UX friction / spec gap / test environment) plus severity (P0–P3) for bugs |
| 8. Bug fix cycle | Stop → assess → (optional pause) → fix → test → restart → **browser retest** → commit, per bug, with one restart per scenario |
| 9. Final report | Full breakdown, severity-sorted, recommendations, end-of-run cleanup, next-step options |

`SKILL.md` and `USAGE.md` label these internally as Phase -1 through Phase 5
(invocation is -1, pre-flight 0, discovery 0.5): that numbering predates the
pre-flight steps and is kept there so the spec folders' references stay valid. Full
detail on every step, with exact example output:
[`USAGE.md`](.claude/skills/webapp-uat/USAGE.md).

### Where this fits in your SDLC

A swimlane view of a typical software development life cycle — what stays yours
(top lane), what this skill takes over (middle lane), and what actually happens in
the browser and backend while it does (bottom lane). Left to right is SDLC order:
requirements → implementation → testing → bug fixing → verification → merge.

```mermaid
flowchart TB
    subgraph DEV["👤 Developer"]
        direction LR
        D1["Requirements<br/>& specs"] --> D2["Design &<br/>implement"] --> D3["Approve<br/>test plan"] --> D4["Sign off —<br/>high-risk fixes only"] --> D5["Review report,<br/>merge & ship"]
    end

    subgraph UAT["🤖 webapp-uat (Claude Code)"]
        direction LR
        U1["Generate scenarios from<br/>specs · validation code ·<br/>route gaps — or review yours"] --> U2["Tighten scenarios,<br/>promote missing cases"] --> U3["Classify findings:<br/>bug / UX / spec gap<br/>+ severity P0–P3"] --> U4["Assess & fix each<br/>confirmed bug,<br/>commit per bug"] --> U5["Final report: fixed ·<br/>unresolved · spec-update<br/>recommendations"]
    end

    subgraph APP["🌐 Chrome + app under test"]
        direction LR
        C1["Drive scenario in a<br/>real, visible Chrome<br/>window"] --> C2["axe-core accessibility<br/>audit · console/network/<br/>screenshot capture"] --> C3["Verify outcome directly<br/>in the backend<br/>(API or DB read)"] --> C4["Restart app,<br/>re-drive the same steps —<br/>browser retest"]
    end

    D2 -.->|"feature ready<br/>to test"| U1
    U2 -.->|"plan presented"| D3
    D3 -.->|"approved"| C1
    C3 -.->|"evidence"| U3
    U3 -.->|"security / auth /<br/>data-deletion bug"| D4
    D4 -.->|"approved"| U4
    U4 -.->|"fix applied"| C4
    C4 -.->|"retest passed"| U5
    U5 -.->|"report"| D5
```

Sits after implementation, before merge — a browser-verified QA gate with a human in
the loop for anything genuinely risky, not a replacement for writing specs or for
human code review. The developer's involvement collapses to three touch points:
approve the plan, sign off on high-risk fixes, review the final report. Spec Kit is
optional: `bug-fix-mechanism: direct` (the default) needs nothing beyond Claude
Code, and Claude fixes confirmed bugs in-session instead of delegating to Spec
Kit's bug workflow.

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

## Test scenarios

Concrete, runnable examples instead of abstract descriptions — the bundled demo app's
scenarios (`demo-app/uat/scenarios/`), each showcasing a different capability:

| Scenario | Showcases |
|---|---|
| `UAT-001-admin-views-team-documents` | Baseline authenticated flow, role: admin |
| `UAT-002-editor-creates-document-with-attachment` | Form validation + file upload, backend verification |
| `UAT-003-document-title-too-short-rejected` | Boundary/negative-path case, client + server validation |
| `UAT-004-search-with-no-matches-shows-empty-state` | Empty-state / data-integrity check |
| `UAT-005-guest-cannot-edit-document` | Role-based access control, correctly enforced |
| `UAT-006-editor-denied-direct-url-to-members` | Role-based direct-URL access control within a team (the control run for the seeded permission-bypass bug) |

Full step-by-step instructions for running these — plus toggling each of the three
seeded bugs and seeing this skill actually catch them — live in
[`webapp-uat-demo`'s own README](https://github.com/kzaamout/webapp-uat-demo#readme).

---

## Project structure

**In your app, after install and setup.** With a plugin install the skill folder
itself stays in Claude Code's plugin cache; only `config.md` and
`discovered-environment.md` land under `.claude/skills/webapp-uat/` in your tree.

```
.claude/skills/webapp-uat/
  SKILL.md                        the skill's operating logic — never hand-edited per project
  USAGE.md                        full usage reference (also the --help output)
  SETUP.md                        one-time setup checklist
  config.md.example               template — copy to config.md and fill in
  config.md                       your project's settings (setup writes it and gitignores it:
                                    it holds an absolute project path)
  discovered-environment.md       cached environment facts (auto-created on first run;
                                    gitignored by setup)
  scripts/sync-managed.sh         keeps the managed files below in sync (check / apply /
                                    legacy-values / print)
  templates/                      bundled dev.sh, dev.env.example, _template.md — what setup
                                    and pre-flight place into your tree (the managed files)

scripts/
  dev.sh                          start / stop / wait-ready engine — managed, never hand-edited
  dev.env                         your app's start/stop values (setup writes it; committed; yours)

uat/
  scenarios/
    _template.md                  shape new scenarios follow (managed — overwritten on update)
    *.md                          your actual scenarios
  fixtures/                       real files scenarios reference — never descriptions
  runs/<run-id>/                  test-plan.md, findings/*.md (one per scenario), final-report.md
  artifacts/<run-id>/<scenario-id>/   screenshots, evidence
```

**This repo only:**

```
scripts/dev.env.example            documents every dev.env key (root reference copy)
scripts/check-sync.sh              drift guard for this repo's deliberate copy-pairs (see below)
scripts/test-sync-managed.sh       end-to-end test of sync-managed.sh + dev.sh (CI runs it)
uat/scenarios/_template.md         root reference copy of the bundled template
.claude-plugin/marketplace.json    what makes `/plugin marketplace add` work against this repo; its
                                     plugin source is `.claude/skills/webapp-uat/` itself, so an
                                     install copies only that folder into the plugin cache
.github/workflows/sync-check.yml   CI on pushes to main and every PR: per-file bash -n, markdownlint,
                                     the mechanism test, check-sync.sh, demo-app's tests + type check
.markdownlint-cli2.jsonc           Markdown lint config (specs/ carries a hygiene-only override); the
                                     file's header gives the pinned local command
.specify/                          Spec Kit tooling (constitution, templates, scripts) used to
.claude/skills/speckit-*/            formalize this skill's own features, plus its ten skills
specs/                             one Spec Kit feature folder per roadmap slice
docs/                              design history, roadmap, requirements reference, demo-recording
                                     runbook, LinkedIn draft, the three demo GIFs, and the SDLC
                                     swimlane diagram's .drawio source
demo-app/                          git submodule — a separate repo (webapp-uat-demo), see
                                     "Try it with the bundled demo app" above
```

**A note on deliberate duplication:** this repo carries the same file in more than
one place on purpose — the bundled `templates/` vs. the root `scripts/dev.sh` /
`scripts/dev.env.example` / `uat/scenarios/_template.md` reference copies (a plugin
install can only write under `.claude/`), and the parent repo's skill folder vs.
`demo-app`'s own installed copy (a separate repo, so it needs its own copy).
`scripts/check-sync.sh` — run locally or by the `sync-check` CI workflow — fails
loudly if any pair drifts (it also checks `demo-app`'s `scripts/dev.sh` and
`uat/scenarios/_template.md` against the bundled copies), so the
duplication stays deliberate instead of becoming silent divergence. See
[`docs/design-history.md`](docs/design-history.md) D7/D8/D10/D13.

---

## Known limitations

- **Severity doesn't currently gate auto-fix eligibility.** Every confirmed bug
  attempts a fix regardless of P0–P3 severity. Whether P2/P3 issues should instead
  just be batched into the report without an automatic fix attempt is an open policy
  question, not yet decided.
- **Environment setup/teardown is scoped to this skill's own test data.** Broader
  preconditions a scenario might need — an empty database, a different model
  provider — aren't handled; only cleanup of what this skill itself created is.
- **Start/stop values live in `scripts/dev.env`, not in `config.md`.** Since UAT-13
  `scripts/dev.sh` is a managed engine with no project values in it, and the values
  sit in a second project-owned file so a plain shell script can read them. Folding
  `dev.env` into `config.md` (one file, but a Markdown parser in bash) is a
  still-open discussion; see [`docs/design-history.md`](docs/design-history.md) D13.
- **`bug-fix-mechanism: spec-kit` can be proposed by Setup mode from a false
  positive.** Detection treats either a project-local `.specify/` directory or
  `specify` on `PATH` as evidence — and the second is a globally installed CLI, not
  proof that *this* project uses Spec Kit, so a machine with `specify` installed but
  no `.specify/` here gets offered `spec-kit` anyway. Always review this specific
  proposal before accepting it; see
  [`docs/design-history.md`](docs/design-history.md) D6.
- **No concurrent-run protection.** Two `/webapp-uat` invocations against the same
  project at the same time aren't guarded against — run-id-suffixed data keeps their
  *records* from colliding, but nothing stops both from trying to start/stop the app
  or write `discovered-environment.md` at once. Treat this as single-run-at-a-time per
  project for now.
- **Multi-store backend verification checks one primary store, by design, not every
  plausibly relevant one.** When a scenario's outcome plausibly spans more than one
  discovered data store (e.g. a relational DB and a search index that should both
  reflect the same write), the skill verifies against the single primary store
  discovery identified and discloses that scope explicitly in the finding — it does
  not verify across all of them. Formalized as `UAT-05`'s FR-009; genuinely spanning
  multiple stores for one outcome remains an open architecture question.
- **Invoking `/webapp-uat` from a session rooted above a nested project (e.g. a
  submodule) always loads that outer repo's copy of the skill, not the nested
  project's own installed copy** — there's no way to point the `Skill` tool at a
  specific installed instance. Two copies with identical content (as with this repo
  and its `demo-app` submodule) behave identically regardless, but this is worth
  knowing before assuming which `config.md` is actually in effect. See
  [`docs/design-history.md`](docs/design-history.md) D8.
- A handful of other ideas were deliberately **recorded but not built**: chat-app-based
  approval (Slack, etc.), and collecting all bugs before deciding what to fix in
  parallel vs. sequence. Details and the reasoning behind holding off on each:
  [`docs/design-history.md`](docs/design-history.md).

See [`docs/roadmap.md`](docs/roadmap.md) for the full slice-by-slice breakdown of
what's done, in progress, and not yet formalized.

---

## Related files

- [`USAGE.md`](.claude/skills/webapp-uat/USAGE.md) — the complete usage reference,
  also what `--help` prints
- [`SKILL.md`](.claude/skills/webapp-uat/SKILL.md) — the actual operating
  instructions Claude Code follows
- [`SETUP.md`](.claude/skills/webapp-uat/SETUP.md) — one-time setup checklist
- [`docs/design-history.md`](docs/design-history.md) — design history, resolved
  decisions, still-open questions, and deferred ideas
- [`docs/roadmap.md`](docs/roadmap.md) — the slice-by-slice implementation roadmap
  and each slice's verification status
- [`docs/requirements.md`](docs/requirements.md) — every requirement governing the
  skill's behavior in one place, formalized (`FR-###`) and not (`NR-###`)
- [`uat/scenarios/_template.md`](uat/scenarios/_template.md) — the shape every
  scenario follows
- [`demo-app`](demo-app) / [`webapp-uat-demo`](https://github.com/kzaamout/webapp-uat-demo) —
  the bundled demo app (submodule) and its own setup/testing walkthrough
