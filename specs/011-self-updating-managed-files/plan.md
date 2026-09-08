# Implementation Plan: Self-Updating Managed Files

**Branch**: `011-self-updating-managed-files` | **Date**: 2026-09-07 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/011-self-updating-managed-files/spec.md`

## Summary

Make the two skill-owned files that live in a project's tree (`scripts/dev.sh`,
`uat/scenarios/_template.md`) replaceable without loss, then replace them
automatically. Three moves: (1) split the start/stop wrapper into a placeholder-free
engine plus a project-owned `scripts/dev.env`, so the engine carries no project data;
(2) mark every skill-owned project-tree file with a first-lines marker that is the
sole authority to overwrite it; (3) add a small deterministic bash script, bundled in
the skill, that compares each bundled file with its project copy and — on request —
copies the ones that differ. The skill shows the comparison at load time (dynamic
context injection), applies it in Phase 0 (committing the result, `--silent`
included), and applies it in Setup mode. All self-references to bundled files switch
to `${CLAUDE_SKILL_DIR}`, which also fixes the axe-core path that a plugin install
cannot find today. Existing installs migrate once, keeping their values.

## Technical Context

**Language/Version**: Bash 3.2-compatible shell scripts (macOS ships 3.2.57 — no
associative arrays, no `mapfile`); Markdown agent-instruction files (`SKILL.md`,
`USAGE.md`, `SETUP.md`); repo docs.

**Primary Dependencies**: `bash`, `git`, `cmp`, `grep`, `sed`, `cp`, `curl` — all
already assumed by the existing wrapper. No new dependency. Two Claude Code
features, both verified against the official docs on 2026-09-06 and present in the
local 2.1.263: `${CLAUDE_SKILL_DIR}` substitution in skill markdown and
`allowed-tools`; dynamic context injection (`` !`cmd` ``) at skill load.

**Storage**: Files in the project tree (`scripts/dev.sh`, `scripts/dev.env`,
`uat/scenarios/_template.md`) and the skill's bundled `templates/`. No database.

**Testing**: Three automated gates, all runnable locally and in CI:
`scripts/check-sync.sh` (existing drift guard, pair list extended); `bash -n` on
every script; a new `scripts/test-sync-managed.sh` that exercises the sync script
and the engine end to end in a scratch directory (in-sync / update-available /
missing / unmanaged / legacy / dev.env-missing / start-wait-stop with a throwaway
HTTP server). `shellcheck` is not installed locally and is not added as a gate
(a gate that can't be run before pushing is a gate nobody trusts). Live
verification against a real plugin install is documented in `quickstart.md` and
performed during implementation where the non-interactive `claude` CLI allows it,
as UAT-11 did.

**Target Platform**: A Claude Code CLI session on macOS or Linux, with the skill
installed either from the plugin marketplace (skill folder in `~/.claude/plugins/`
cache, outside the project) or by copying (skill folder inside the project).

**Project Type**: Claude Code skill (agent instruction set) plus bundled bash
scripts and repo documentation.

**Performance Goals**: The load-time check must be effectively free — two `cmp`
calls and a few `head`/`grep`s; well under a second.

**Constraints**: The load-time check MUST exit 0 in every situation (a non-zero
exit aborts the skill invocation) and MUST NOT contain command substitution or
compound operators in the injected line (the permission matcher must prefix-match
the `allowed-tools` rule exactly, or the invocation aborts). Project-owned files
are never written by any automatic step. Everything must work whether the skill
folder is inside or outside the project tree.

**Scale/Scope**: Two managed files, one values file, one sync script, one test
script; edits to the three instruction files and six docs; one submodule re-sync.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Written Requirements Are the Source of Truth | PASS | Every change traces to `spec.md` FR-001–FR-014. The two design decisions taken in conversation on 2026-09-07 are recorded in `spec.md`'s Background, not left verbal. |
| II. Reconcile Conflicts Before Implementation | PASS — four conflicts found and reconciled below | (a) UAT-11 FR-005 ("MUST NOT overwrite an existing `scripts/dev.sh`'s placeholders from the bundled template") vs. this feature's overwrite: reconciled — FR-005 protected project values baked into the wrapper; under the new contract a marker-less wrapper (every pre-existing install) is still never overwritten automatically, and marker-bearing wrappers carry no project values by construction. FR-005's intent is preserved; its letter is superseded and `docs/requirements.md` records that. (b) NR-026's project-relative axe-core path vs. plugin installs: amended to the bundled-copy reference. (c) README / `config.md.example` "upgrading is just replacing `SKILL.md`/`USAGE.md`": superseded by the Updating section. (d) Setup step 6's "fill in its placeholders in place" for a pre-existing wrapper: replaced by legacy migration (FR-010). |
| III. Vertical-Slice Delivery | PASS | Four prioritized, independently testable stories; US1+US2 (both P1) together are the viable increment; US3/US4 can be cut without unwinding them. |
| IV. Testable Acceptance Criteria | PASS | Every FR maps to Given/When/Then scenarios; `test-sync-managed.sh` encodes the mechanical ones. |
| V. Reuse Before Reinvention | PASS | Comparison reuses `check-sync.sh`'s `cmp`/`diff -q` approach; Setup reuses its propose→confirm→write, per-item outcome pattern; Phase 0's commit reuses Phase 4's per-change commit convention; project-root-from-script-location reuses demo-app's D6 precedent. |
| VI. Usability Is Not Optional | PASS | Per-file status lines in a fixed, readable format; wrapper errors name the missing file/key and say what to run; README Updating section is written to be sufficient on its own (SC-009). |
| VII. Deliberate Dependencies | PASS | No new dependency. The two Claude Code features relied on are recorded with their doc references in `research.md`. |
| VIII. Automated Quality Gates | PASS — strengthened | Adds a real automated end-to-end test and `bash -n` to the CI workflow alongside the existing drift guard. |
| IX. Human Approval Before Consequential Change | PASS | The design (engine/values split, marker contract, sync mechanism, automatic commit under `--silent`) was presented and approved by the product owner on 2026-09-07 before this plan; the unattended auto-commit is the one consequential behavior and was called out explicitly as the decision. |

No violations requiring Complexity Tracking justification.

**Post-design re-check (after Phase 1)**: unchanged — the contracts introduce no
new dependency and no new approval-bypassing write; the only automatic writes are
to marker-bearing files and the path-scoped commit of exactly those files.

## Project Structure

### Documentation (this feature)

```text
specs/011-self-updating-managed-files/
├── plan.md                    # This file
├── research.md                # Phase 0: decisions with alternatives
├── data-model.md              # Phase 1: entities, statuses, transitions
├── quickstart.md              # Phase 1: validation guide (automated + live)
├── contracts/
│   ├── sync-managed-cli.md    # sync script: args, statuses, output, exit codes
│   ├── dev-sh-interface.md    # engine commands + dev.env schema
│   └── managed-marker.md      # marker text, placement, detection rule
├── checklists/requirements.md
└── tasks.md                   # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
.claude/skills/webapp-uat/
├── SKILL.md                   # EDIT: frontmatter allowed-tools; "Managed files" block
│                              #   with load-time --check; Setup step 6 rewrite (dev.env
│                              #   proposal, --apply, legacy migration, re-adoption);
│                              #   Phase 0 first bullet (--apply + commit + reporting);
│                              #   Phase 5 "Managed files" line; ${CLAUDE_SKILL_DIR}
│                              #   for templates/, vendor/axe.min.js, scripts/
├── USAGE.md                   # EDIT: Phase 0 text, file reference (dev.env), setup text
├── SETUP.md                   # EDIT: step 2/2b/3 cover dev.env; "Updating" pointer
├── config.md.example          # EDIT: "upgrading" sentence corrected
├── scripts/
│   └── sync-managed.sh        # NEW: --check | --apply | --legacy-values
├── templates/
│   ├── dev.sh                 # RENAMED from dev.sh.template; now the engine + marker
│   ├── dev.env.example        # NEW: documented keys
│   └── _template.md           # EDIT: first-line marker
└── vendor/axe.min.js          # unchanged

scripts/
├── dev.sh                     # root reference copy (byte-identical to templates/dev.sh)
├── dev.env.example            # NEW root reference copy
├── check-sync.sh              # EDIT: new pair list (+ demo-app copy list)
└── test-sync-managed.sh       # NEW: automated end-to-end test

uat/scenarios/_template.md     # root reference copy (byte-identical)

.github/workflows/sync-check.yml  # EDIT: add bash -n + test-sync-managed.sh steps

README.md                      # EDIT: install text, NEW "Updating" section, structure, TOC
docs/requirements.md           # EDIT: NR-026 amended; UAT-11 FR-005 note; NR-028+ added
docs/design-history.md         # EDIT: D13
docs/roadmap.md                # EDIT: UAT-13 entry, build-order footnote

demo-app/.claude/skills/webapp-uat/   # RE-SYNC (submodule commit + pointer bump)
```

**Structure Decision**: The skill folder stays the single source (D7); the new
script lives under the skill's own `scripts/` so it ships with every install and is
addressable as `${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh`. Root copies remain
reference-only and are guarded by `check-sync.sh`.

## Implementation Notes (carried into tasks)

- **Injected line shape**: `` !`bash "${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh" --check` `` —
  no positional root (the script derives it from `git rev-parse --show-toplevel`,
  falling back to `pwd`), no `$(...)`, no `||`, so the `allowed-tools` rule
  `Bash(bash ${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh *)` prefix-matches it.
- **Commit**: `git -C <root> add <changed paths> && git -C <root> commit -m "chore(webapp-uat): update managed files (<paths>)"`
  — path-scoped; never `git add -A`.
- **Legacy extraction** is deterministic: `sync-managed.sh --legacy-values`
  evals only the `START_COMMAND=`/`STOP_COMMAND=`/`PORT=`/`WAIT_TIMEOUT=` assignment
  lines of the legacy wrapper in a subshell and prints them as single-quoted
  `KEY='value'` lines ready for `dev.env`; `PROJECT_DIR` is dropped.
- **demo-app**: its `scripts/dev.sh` is legacy-shaped and stays so (out of scope);
  after re-sync the new skill reports it as `legacy` and keeps using it, which is
  exactly FR-010's `--silent` path. Its skill-folder copy must be re-synced for
  `check-sync.sh` to pass; pushing the submodule before the parent is the owner's
  step and is called out in `quickstart.md`.

## Complexity Tracking

No constitution violations to justify.
