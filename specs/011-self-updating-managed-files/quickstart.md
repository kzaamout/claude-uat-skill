# Quickstart: validating Self-Updating Managed Files

## Prerequisites

- macOS or Linux, `bash` (3.2+), `git`, `cmp`, `curl`, `python3` (throwaway HTTP
  server for the engine test).
- For the live check: Claude Code ≥ 2.1.263 with the `claude plugin` CLI.

## 1. Automated gates (run locally before every push; CI runs the same)

```bash
bash -n scripts/*.sh .claude/skills/webapp-uat/scripts/*.sh .claude/skills/webapp-uat/templates/dev.sh
bash scripts/check-sync.sh
bash scripts/test-sync-managed.sh
```

Expected: every `bash -n` silent; `Sync check passed - all copy-pairs identical.`;
`test-sync-managed.sh` ends with `ALL PASSED` and exit 0.

What `test-sync-managed.sh` proves, in a scratch directory holding a copy of the
skill folder and a fake project:

| Case | Assertion |
|---|---|
| bundled copies carry the marker | both `templates/` files detected as managed |
| fresh project, `--check` | `missing` ×2, `values-file … missing`, exit 0 |
| `--apply` on fresh project | `created` ×2, `changed: 2`, files byte-identical to bundled, `dev.sh` executable |
| second `--apply` | `in-sync` ×2, `changed: 0` |
| bundled copy modified (simulated skill update) | `--check` → `update-available`; `--apply` → `updated`, project copy now matches |
| marker removed from project copy | `--check` → `unmanaged`; `--apply` → `skipped-unmanaged`, file untouched |
| legacy wrapper (old template with values filled) | `--check` → `legacy`; `--apply` → `skipped-legacy`; `--legacy-values` prints exactly the three/four keys, `PROJECT_DIR` absent |
| `dev.env` missing | engine `start` prints the "not found -- run /webapp-uat setup" message, exit 1 |
| `dev.env` without `START_COMMAND` | engine exits 1 naming `START_COMMAND` |
| `dev.env` with a `python3 -m http.server` start command | `start` → `Started`, second `start` → `Already running`, `wait-ready` → `Ready` (exit 0), `stop` → `Stopped`, pidfile removed, server really gone |
| `READY_COMMAND='true'` and no `PORT` | `wait-ready` → `Ready` |
| `--check` with a nonexistent root argument | single `managed-files: cannot check (…)` line, exit 0 (a bare non-git directory is a valid root: the script falls back to `pwd`) |
| `--check` with no project root argument inside a git repo | resolves the repo root itself |
| `--print USAGE.md` | byte-identical to the bundled file, exit 0; `..`/absolute/missing paths exit 2 |

## 2. Live verification (plugin install, scratch target)

Mirrors UAT-11's evidence path. Uses the non-interactive `claude` CLI.

```bash
# 2a. Scratch target
T=$(mktemp -d)/target && mkdir -p "$T" && cd "$T" && git init -q && git commit -q --allow-empty -m init

# 2b. Install the plugin from a COPY of the working tree whose marketplace.json name is
#     changed (e.g. webapp-uat-local) so it doesn't collide with the real registration;
#     commit the copy — the installed version is its commit SHA
claude plugin marketplace add <path-to-copy>
claude plugin install webapp-uat@webapp-uat-local --scope project

# 2c. Setup (headless) — expect scripts/dev.sh (marker, no values), scripts/dev.env,
#     uat/scenarios/_template.md, plus config.md under .claude/skills/webapp-uat/
claude -p "Run /webapp-uat setup; approve every proposal; project-name …; start command …" \
  --allowedTools "Bash,Read,Write,Edit,Glob,Grep,Skill" --permission-mode acceptEdits < /dev/null
head -3 scripts/dev.sh; cat scripts/dev.env; head -1 uat/scenarios/_template.md
git add -A && git commit -q -m "setup"

# 2d. Simulate a newer skill: change a bundled file in the source repo, commit,
#     then refresh + update the plugin and restart Claude
#     (in the source repo) echo "<!-- v2 -->" >> .claude/skills/webapp-uat/templates/_template.md && git commit -qam "v2"
claude plugin marketplace update webapp-uat-local
claude plugin update webapp-uat@webapp-uat-local --scope project

# 2e. Next invocation: load-time status shows update-available; Phase 0 applies and commits
claude -p "/webapp-uat --help"           # status block visible, nothing written
claude -p "/webapp-uat --silent" --allowedTools "Bash,Read,Write,Edit,Glob,Grep,Skill" < /dev/null   # Phase 0 applies + commits
git log --oneline -1                     # chore(webapp-uat): update managed files (uat/scenarios/_template.md)
git show --stat HEAD                     # exactly that path
cmp scripts/dev.env <(git show HEAD~1:scripts/dev.env) && echo "dev.env untouched"

# 2f. Ownership opt-out
sed -i '' '1d' uat/scenarios/_template.md   # remove marker
claude -p "/webapp-uat --help"              # shows unmanaged; no write

# 2g. Legacy migration: drop an old-style wrapper in, run setup, confirm, check dev.env
```

Revert the simulated "v2" commit in the source repo afterwards.

## 3. Doc check (SC-009)

Hand the README "Updating" section to someone who has never seen the repo and ask
them to update an install. They should not need any other document.

## 4. Submodule step (owner)

After `demo-app/.claude/skills/webapp-uat/` is re-synced: push the `demo-app`
submodule commit **first**, then push the parent (whose pointer bump references it).
`check-sync.sh` fails until the copy is re-synced; CI checks out submodules
recursively.

## Done when

- [x] Section 1 gates pass locally (`bash -n` silent; `ALL PASSED (79 checks)`;
  `Sync check passed - all copy-pairs identical.`, demo-app pair included) — CI runs
  the same three steps.
- [x] Section 2 performed 2026-09-07 against a real plugin install. Evidence below.
- [x] `docs/roadmap.md` UAT-13 marked Done.

### Live verification record (2026-09-07, Claude Code 2.1.263, headless `claude -p`)

Setup: a copy of this working tree (marketplace renamed `webapp-uat-local` so it
couldn't collide with the real GitHub registration) served as a path-based
marketplace; a scratch git repo was the target. `claude plugin marketplace add
<copy>` + `claude plugin install webapp-uat@webapp-uat-local --scope project`. The
installed version was the copy's commit SHA, and each later `claude plugin
marketplace update` + `claude plugin update … --scope project` pair moved it to the
next commit (a12daec → e888283 → c78ffb1 → b34e44c → 517a3d4) — the README's
two-command sequence, confirmed five times. Headless runs need
`--allowedTools "Bash,Read,Write,Edit,Glob,Grep,Skill"`; without `Skill` in that
list the Skill tool is denied in `-p` mode (that is a headless-flags artifact, not a
skill defect — slash-command invocations bypass the tool).

| Story | What ran | Observed |
|---|---|---|
| FR-006 / SC-007 | `/webapp-uat --help` on a fresh target | Load-time injection ran from the skill folder outside the project (`${CLAUDE_SKILL_DIR}` resolved), no abort; status block `missing ×2 / values-file missing` was the first text emitted; nothing written |
| US2 | headless `setup` with approvals pre-answered | `scripts/dev.sh` created with marker (managed engine), `scripts/dev.env` written with the supplied values, `_template.md` created with marker, `config.md` in the project tree, `.gitignore` entries; report listed every item |
| US1 | bundled `_template.md` changed in the copy; update pair; `/webapp-uat --silent` | `--help` first showed `update-available uat/scenarios/_template.md`; Phase 0 applied it and committed **exactly one path**: `34db6b2 chore(webapp-uat): update managed files (uat/scenarios/_template.md)` (`1 file changed`); `scripts/dev.env` byte-identical before/after; the run went on to sanity-check start/wait-ready/stop against the real server (HTTP 200, port closed after stop) |
| US4 | marker line removed from the project's template; `/webapp-uat --silent` | Reported "`uat/scenarios/_template.md` is unmanaged (marker removed) — `/webapp-uat setup` can re-adopt it"; file untouched; no commit |
| US3 | pre-UAT-13 four-value `scripts/dev.sh` planted, `dev.env` removed; headless `setup` accepting the migration | `--check` showed `legacy`; setup wrote `dev.env` with `START_COMMAND`/`STOP_COMMAND`/`PORT`/`WAIT_TIMEOUT` **exactly as extracted**, dropped `PROJECT_DIR`, replaced `dev.sh` with the managed engine; the unmanaged template was *not* re-adopted on a blanket approval (explicit yes required) |

Two defects found and fixed during this pass (see D13): (1) for a plugin install
the skill folder is outside the session's working directories and Claude Code
blocks `Read`/`cat` there regardless of `allowed-tools` — `--help` and the
axe-core injection had only ever worked for manual installs; fixed with
`sync-managed.sh --print <bundled path>` (executing the pre-authorized script is
allowed). (2) Headless text output prints only the final message, which made the
status block look skipped on `--help`; the trace showed it was emitted first, and
the `--help` rule now says explicitly to print status lines before `USAGE.md`.

Scratch marketplace and project-scope install were removed afterwards; the real
`webapp-uat-marketplace` registration was untouched.
