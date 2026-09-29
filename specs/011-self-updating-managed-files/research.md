# Research: Self-Updating Managed Files

All unknowns in the Technical Context were resolved before planning; this file
records each decision with its rationale and the alternatives weighed.

## R1 — How a skill-owned file in the project tree can be replaced safely

- **Decision**: Split `scripts/dev.sh` into an engine with zero project data and a
  project-owned `scripts/dev.env` the engine sources. Only files with no project
  data are ever overwritten.
- **Rationale**: A file that mixes logic and data can't be replaced without a
  merge. Once the data is elsewhere, replacement is a plain copy.
- **Alternatives considered**: (a) Keep placeholders and do a three-way merge
  against the previously installed version (Debian conffile style) — needs a stored
  baseline per install and still ends in a manual conflict when both sides change.
  (b) Run the engine directly from the skill folder and never copy it — the plugin
  cache path changes on every update, `scripts/dev.sh` is the documented
  human-runnable interface (SETUP.md step 3, Phase 0), and the manual-install path
  would behave differently. (c) Read the values out of `config.md` — `config.md` is
  gitignored/per-machine and Markdown; the wrapper's values are shared and
  machine-independent, and a bash-sourceable file is the simplest correct reader.

## R2 — Ownership signal: marker vs. version stamp vs. checksum

- **Decision**: A literal marker phrase (`webapp-uat managed file`) within the
  first three lines. Present → the skill may overwrite; absent → the skill never
  touches it. Removing the line is the documented way to take ownership.
- **Rationale**: Self-describing (the file says what will happen to it), zero
  bookkeeping, trivially checkable with `head -3 | grep`, and gives users an
  explicit off switch without any configuration.
- **Alternatives considered**: (a) Version stamps in the file — require bumping on
  every change and still can't tell an edited file from an unedited one. (b) A
  stored checksum of the originally installed copy — needs a side file per project
  and breaks the moment someone regenerates it. (c) A `config.md` key listing
  unmanaged files — indirection; the file itself is the natural place.

## R3 — Detecting "an update is available"

- **Decision**: Byte comparison (`cmp -s`) of the bundled copy vs. the project copy.
- **Rationale**: The bundled copy in the installed skill is by definition what the
  project copy should contain. No version numbers to bump, no release tags, no
  ordering questions; a content difference is the whole truth.
- **Alternatives considered**: Plugin `version` fields / `name--vX.Y.Z` tags —
  add release ceremony and don't help with the manual-install path. Verified
  (official docs, 2026-09-06): for this marketplace (`source: "./"`, no version
  field) the plugin version is the repo commit SHA, so every commit already is a
  new version; `claude plugin update` does not refresh the marketplace clone, so
  `claude plugin marketplace update` must run first — the README documents the
  order.

## R4 — Where the sync runs

- **Decision**: Three points. (1) Skill load — `--check` only, through dynamic
  context injection, so the status is in front of both the user and Claude before
  any mode runs. (2) Phase 0 — `--apply`, then a path-scoped commit of what
  changed, before the clean-working-tree check. (3) Setup mode's write step —
  `--apply` as one item, plus the interactive cases (legacy migration, re-adoption).
- **Rationale**: Load-time visibility costs nothing and makes the state
  self-evident; Phase 0 is the point every real run passes through and already
  owns the "is the tree clean" decision; Setup already owns every confirm-before-
  write interaction. No new command to learn.
- **Alternatives considered**: (a) A plugin `SessionStart` hook — verified
  feasible (`CLAUDE_PLUGIN_ROOT` / `CLAUDE_PROJECT_DIR` are available to hooks),
  rejected because it would write into every project that has the plugin enabled,
  on every session start, whether or not the project uses the skill. (b) A
  dedicated `/webapp-uat update` command — redundant with Phase 0 + setup; deferred.
  (c) Apply at load time — a load-time command that writes files and can abort the
  invocation on failure is the wrong place for a write.

## R5 — Load-time injection constraints (verified against docs.claude.com, 2026-09-06)

- `` !`cmd` `` runs before Claude sees the skill body; output replaces the
  placeholder; runs under the Bash tool's cwd/timeout.
- **Any non-zero exit aborts the invocation** → `--check` exits 0 unconditionally,
  including when it can't find the project root or the bundled files.
- **Injected commands never prompt; a permission result other than "allow" aborts
  the invocation** → the skill declares
  `allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh *)` and the
  injected line is the bare `bash ${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh --check`
  with no command substitution or `||` that could defeat the prefix match. The
  script derives the project root itself.
- `${CLAUDE_SKILL_DIR}` is substituted in skill markdown and `allowed-tools` for
  personal, project, and plugin skills; for a plugin skill it is the skill's own
  subdirectory, which is what the bundled paths need. (`${CLAUDE_PROJECT_DIR}`
  requires 2.1.196+; not relied on.)
- `disableSkillShellExecution` (managed settings) replaces the line with a
  placeholder rather than running it → the skill body tells Claude that a
  placeholder there means "run the check yourself in Phase 0", which it does anyway.
- Skills synced from a claude.ai account never run `!` commands — out of scope
  (this skill is distributed by plugin/manual copy).

## R6 — Automatic commit of the applied update

- **Decision**: If `--apply` changed anything, commit exactly those paths as one
  commit, `chore(webapp-uat): update managed files (<paths>)`, `--silent` included.
- **Rationale**: Phase 0 requires a clean tree; an applied update would otherwise
  block every unattended run right after every skill update. The files contain no
  project data, so there is nothing for a human to review in the diff beyond "the
  skill updated its own files". Path-scoped `git add` guarantees unrelated dirty
  changes are never swept in; they hit the existing clean-tree prompt as before.
- **Alternatives considered**: Leave it to the existing commit/stash/cancel prompt
  — breaks `--silent`. Stash-apply-commit-pop — more moving parts for no gain.
- **Approval**: Presented as the one open decision on 2026-09-07 and accepted.

## R7 — Legacy detection and migration

- **Decision**: A marker-less `scripts/dev.sh` containing both a `START_COMMAND=`
  and a `PORT=` assignment line is *legacy*. `sync-managed.sh --legacy-values`
  extracts `START_COMMAND`, `STOP_COMMAND`, `PORT`, `WAIT_TIMEOUT` by `eval`-ing
  only those assignment lines in a subshell (bash parses the trailing comments
  correctly, which ad-hoc `sed` would not) and prints single-quoted `KEY='value'`
  lines. `PROJECT_DIR` is dropped — the engine derives it. Migration is always
  confirm-before-write; never under `--silent`.
- **Rationale**: Deterministic, correct for every value the old template could
  hold, and reversible (the user sees the values before anything is written). The
  old wrapper's interface is unchanged, so leaving it in place is always safe.
- **Alternatives considered**: Regex extraction — fragile on quotes/comments.
  Automatic silent migration — writes a new project file without review; rejected.

## R8 — Engine details preserved from the old wrapper

- Same `start | stop | wait-ready` commands, same pidfile (`.webapp-uat.pid`),
  same `dev.log`, same SIGINT-then-children stop sequence, same one-check-per-second
  wait loop, same exit codes (0 ready/started/stopped, 1 timeout/usage/cd failure).
  One addition found by the end-to-end test: a process backgrounded from a script
  ignores SIGINT (POSIX: no job control ⇒ SIGINT/SIGQUIT ignored), so the old
  wrapper's SIGINT-only stop never stopped a plain server. The engine escalates to
  SIGTERM, then SIGKILL, only when the pid survives SIGINT.
- `WAIT_TIMEOUT` precedence: per-run environment override > `dev.env` value > 30.
- Project root: `$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)` — demo-app's D6
  precedent; independent of cwd and of git.
- `STOP_COMMAND` optional (nothing extra runs when empty); `READY_COMMAND` optional
  (replaces the `curl` port check when set).

## R9 — Bash 3.2 compatibility

- macOS ships bash 3.2.57. The sync script uses a plain positional table
  (parallel `case`/`set --` lists), no associative arrays, no `mapfile`, no
  `${var,,}`. Verified locally on 3.2.57 by the test script.

## R10 — Quality gates

- Existing: `scripts/check-sync.sh` (CI). Added: `bash -n` on every script and
  `scripts/test-sync-managed.sh` (scratch-dir end-to-end), both in the same CI
  workflow. `shellcheck` not adopted: not installed locally, so it couldn't be run
  before pushing; a gate that only runs in CI is a gate people learn to ignore.
