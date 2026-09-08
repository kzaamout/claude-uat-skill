# Tasks: Self-Updating Managed Files

**Input**: Design documents from `/specs/011-self-updating-managed-files/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Mandatory (constitution Principle VIII). The automated gate for this
feature is `scripts/test-sync-managed.sh`, written *before* the code it exercises so
it fails first, plus `bash -n` and the existing `scripts/check-sync.sh`, all wired
into `.github/workflows/sync-check.yml`.

**Organization**: Foundational phase builds the mechanical pieces every story needs
(engine, values example, markers, sync script, test harness, root copies, drift
guard). Each user-story phase then adds the skill behavior (`SKILL.md`) and the
user-facing docs for that story, plus that story's test cases.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1 propagation · US2 values-outside-script · US3 legacy migration · US4 take-ownership

## Path Conventions

Skill folder: `.claude/skills/webapp-uat/` (abbreviated `SKILL/` below). Root
reference copies: `scripts/`, `uat/scenarios/`. Docs: `README.md`, `docs/`.
Bash 3.2 compatible throughout (no associative arrays, no `mapfile`).

---

## Phase 1: Setup

**Purpose**: Layout changes with no behavior yet.

- [X] T001 `git mv SKILL/templates/dev.sh.template SKILL/templates/dev.sh` and create `SKILL/scripts/` (empty dir placeholder not needed — T005 creates the first file there)
- [X] T002 [P] Update `scripts/check-sync.sh` pair list to: `SKILL/templates/dev.sh`↔`scripts/dev.sh`, `SKILL/templates/dev.env.example`↔`scripts/dev.env.example`, `SKILL/templates/_template.md`↔`uat/scenarios/_template.md`; add `scripts/sync-managed.sh` and `templates/dev.env.example` to the demo-app skill-copy file list; update the header comment (D7/D8/D13)

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: The mechanical contract — engine, values file, markers, sync script — and the automated test that proves it. Nothing in Phases 3–6 works without this.

### Test first (must fail before T005–T009 exist)

- [X] T003 Write `scripts/test-sync-managed.sh` per `quickstart.md` §1 table (cases: bundled markers present; fresh `--check` → `missing`×2 + values-file missing, exit 0; `--apply` → `created`×2, `changed: 2`, byte-identical, `dev.sh` executable; second `--apply` → `in-sync`×2, `changed: 0`; simulated skill update → `update-available` then `updated`; marker removed → `unmanaged` / `skipped-unmanaged`, untouched; engine with no `dev.env` → exit 1 naming it; `dev.env` without `START_COMMAND` → exit 1 naming the key; `python3 -m http.server` start → `Started`/`Ready`/`Stopped`, pidfile gone; `READY_COMMAND='true'` no `PORT` → `Ready`; `--check` in a root-less non-git dir → single `managed-files: cannot check (` line, exit 0; `--check` with no root arg inside a git repo resolves root). Scratch dir via `mktemp -d`, skill copied from `SKILL/`, helpers `expect_contains`/`expect_exit`, summary line `ALL PASSED` or `N FAILED`, exit accordingly. Legacy cases are added in T020 (US3).
- [X] T004 Run `bash scripts/test-sync-managed.sh` and confirm it FAILS (sync script absent) before continuing

### Implementation

- [X] T005 [P] Write the engine `SKILL/templates/dev.sh` per `contracts/dev-sh-interface.md`: shebang, marker line 2, header comment explaining `scripts/dev.env`, `set -u`, `PROJECT_DIR` from script location, env `WAIT_TIMEOUT` capture, `dev.env` existence + `START_COMMAND` + `PORT`/`READY_COMMAND` validation with the exact messages, `WAIT_TIMEOUT` precedence, unchanged `start|stop|wait-ready` bodies (optional `STOP_COMMAND`, `READY_COMMAND` branch in `wait-ready`), same exit codes; `chmod +x`
- [X] T006 [P] Write `SKILL/templates/dev.env.example` documenting `START_COMMAND`, `STOP_COMMAND`, `PORT`, `WAIT_TIMEOUT`, `READY_COMMAND` inline (single-quoted examples; the two optional ones commented out); note it is project-owned, committed, never overwritten by the skill
- [X] T007 [P] Add the first-line HTML-comment marker to `SKILL/templates/_template.md` per `contracts/managed-marker.md`
- [X] T008 Write `SKILL/scripts/sync-managed.sh` per `contracts/sync-managed-cli.md`: root resolution (arg → `git rev-parse --show-toplevel` → `pwd`), skill dir from own location, managed table as parallel lists, marker detection (`head -3 | grep -q`), `--check` (always exit 0, `cannot check (…)` line on any precondition failure), `--apply` (cp preserving exec bit, mkdir -p parent, per-file action lines, `values-file` line, `changed: N`, `changed-paths:`; exit 2 on copy failure), usage → stderr exit 2; `chmod +x`. (`legacy` status and `--legacy-values` come in T019.)
- [X] T009 Refresh root reference copies: `cp SKILL/templates/dev.sh scripts/dev.sh`, `cp SKILL/templates/dev.env.example scripts/dev.env.example`, `cp SKILL/templates/_template.md uat/scenarios/_template.md`; confirm `scripts/dev.sh` executable
- [X] T010 Run `bash -n` on all scripts, `bash scripts/test-sync-managed.sh` (expect ALL PASSED for the non-legacy cases), `bash scripts/check-sync.sh` (expect the templates↔root pairs in sync; the demo-app pair drifts until T034)

**Checkpoint**: sync script + engine proven by the automated test; drift guard green for the parent repo.

---

## Phase 3: User Story 1 — Skill-owned files update themselves after a skill update (Priority: P1) 🎯 MVP

**Goal**: After a plugin/manual update, the next `/webapp-uat` invocation shows managed-file status at load, applies pending updates in Phase 0, commits exactly those paths, and reports it.

**Independent Test**: spec.md US1 Independent Test; automated cases "simulated skill update" in T003; live steps quickstart §2d–2e.

- [X] T011 [US1] `SKILL/SKILL.md` frontmatter: add `allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh *)` (keep `name`/`description` unchanged); the rule and the injected line in T012 use the identical unquoted form, as the official docs' pattern does, so the permission prefix-match holds
- [X] T012 [US1] `SKILL/SKILL.md`: insert a `## Managed files` block after the intro paragraph and before `## Phase -1`: explains the contract in three sentences (marker = permission to overwrite; project-owned files never touched; remove marker to take ownership), then the dynamic-context line `` !`bash ${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh --check` `` as a plain line (not inside a code fence — only the ```! fence form is substituted inside fences), then the echo rule: if any line is not `in-sync` (or the values-file line says `missing`), print those lines to the user verbatim before doing anything else, in every mode including `--help`; all in sync → say nothing; a policy placeholder instead of statuses → say nothing, Phase 0's own check covers it
- [X] T013 [US1] `SKILL/SKILL.md` Phase 0: add a **first** bullet "**Managed files**" (before the `config.md` consistency bullet): run `bash "${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh" --apply` from the project root; if `changed: N` with N>0 → `git add <changed-paths>` and `git commit -m "chore(webapp-uat): update managed files (<comma-separated paths>)"` — path-scoped, never `-A`, no confirmation, `--silent` included; record the list for the final report; `values-file … missing` **and** `scripts/dev.sh` not `legacy` → stop with "run `/webapp-uat setup`" (a managed engine can't run without `dev.env`; a legacy wrapper doesn't need it); script not found or exits non-zero → print "managed files could not be checked (<reason>)" and continue with the files as they are; unmanaged/legacy handling is added by T028/T026
- [X] T014 [US1] `SKILL/SKILL.md` Phase 5: add a bullet "Managed files: updated `<paths>` (committed as `<sha>`)" — only when Phase 0 changed something (plus the unmanaged/legacy lines added later); a run with nothing to report omits the bullet entirely (FR-012)
- [X] T015 [P] [US1] `SKILL/USAGE.md` Phase 0 list: first item "Managed files (`scripts/dev.sh`, `uat/scenarios/_template.md`) brought up to the installed skill's version and committed — automatic, `--silent` included; your `scripts/dev.env` and everything else you own is never touched"; `--help` section: note the status block shown at load writes nothing
- [X] T016 [P] [US1] `README.md`: new `## Updating` section directly after `## Installation & setup` (before `## Quick start`), with TOC entry: plugin path (`claude plugin marketplace update webapp-uat-marketplace` then `claude plugin update webapp-uat@webapp-uat-marketplace`, `--scope project` note, restart), manual path (re-copy the skill folder), "what the next run does" (status at load; Phase 0 applies + one commit; report line), "what is never touched" list, "taking ownership" pointer (marker removal), "existing installs" pointer (setup migrates the old `dev.sh` — US3); Prerequisites section gains one line: Claude Code ≥ 2.1.263 (skill-folder path substitution + load-time status check; older versions abort the skill at load)

**Checkpoint**: an updated skill propagates on the next run; README tells users how.

---

## Phase 4: User Story 2 — Start/stop values live outside the managed script (Priority: P1)

**Goal**: Setup writes `scripts/dev.env` from discovery and places the managed files via `--apply`; every skill self-reference uses `${CLAUDE_SKILL_DIR}`.

**Independent Test**: spec.md US2 Independent Test; automated engine cases in T003; live steps quickstart §2c.

- [X] T017 [US2] `SKILL/SKILL.md` Setup mode: step 2 text now proposes `scripts/dev.env` values (`START_COMMAND`, `STOP_COMMAND`, `PORT`; `WAIT_TIMEOUT`/`READY_COMMAND` only when evidence suggests them) — same detected/guessed/needs-your-input labels; step 5's draft includes the `dev.env` block; step 6 rewritten: write `config.md` (unchanged), write `scripts/dev.env` (new file: write; existing file: per-key show-current-vs-proposed, per-key approval as step 7 does for `config.md`), run `--apply` and report each managed file from its output lines, `mkdir -p` dirs (unchanged), `.gitignore` check (unchanged), report block updated (`scripts/dev.env ……… written`, `scripts/dev.sh ……… created (managed)`, `uat/scenarios/_template.md … in sync`); drop every "fill in placeholders" sentence
- [X] T018 [US2] `SKILL/SKILL.md`: replace every bundled-file self-reference with `${CLAUDE_SKILL_DIR}/…` — the Phase 2 axe-core path (`${CLAUDE_SKILL_DIR}/vendor/axe.min.js`), setup's template references, and the intro paragraph's "in this same folder" wording where it points at bundled files (keep the D12 wording about *project-local* `config.md` intact)
- [X] T019 [P] [US2] `SKILL/SETUP.md`: step 1 manual-copy list adds `scripts/dev.env.example` → copy to `scripts/dev.env`; step 2 text says the wizard writes `config.md` + `scripts/dev.env`; step 2b: fill in `scripts/dev.env` (not `dev.sh`) — list the keys; step 3 unchanged commands, add "never edit `scripts/dev.sh` itself — it's managed; see README Updating"; add a short "Updating later" pointer at the end
- [X] T020 [P] [US2] `SKILL/USAGE.md`: setup section mentions `scripts/dev.env`; File & directory reference adds `scripts/dev.env` (yours, committed), marks `scripts/dev.sh` and `uat/scenarios/_template.md` as managed (overwritten on update), adds `SKILL/scripts/sync-managed.sh` and `templates/dev.env.example`
- [X] T021 [P] [US2] `SKILL/config.md.example`: replace "upgrading the skill later is just replacing `SKILL.md`/`USAGE.md` wholesale" with a sentence pointing at README's Updating section
- [X] T022 [P] [US2] `README.md`: Installation step 1 text (plugin path: setup writes `scripts/dev.env` and places managed files; manual list adds `scripts/dev.env.example`), the "pulling in a future update … replacing those two files wholesale" sentence → pointer to Updating; Project structure block: `scripts/dev.env`, `scripts/dev.env.example`, `SKILL/scripts/sync-managed.sh`, `templates/dev.sh` (renamed), `templates/dev.env.example`, `scripts/test-sync-managed.sh`; "deliberate duplication" note lists the three pairs

**Checkpoint**: fresh setup yields engine + dev.env + template with no hand edits.

---

## Phase 5: User Story 3 — Existing installs migrate once, keeping their values (Priority: P2)

**Goal**: A marker-less four-value `scripts/dev.sh` is recognized as legacy, its values extracted deterministically, and migration offered (never under `--silent`).

**Independent Test**: spec.md US3 Independent Test; automated legacy cases (T023); live quickstart §2g.

- [X] T023 [US3] `scripts/test-sync-managed.sh`: add legacy cases — the pre-feature wrapper with values filled in, embedded verbatim as a heredoc in the test (not read from git history) → `--check` shows `legacy`, `--apply` shows `skipped-legacy` and leaves it byte-identical, `--legacy-values` prints exactly `START_COMMAND`/`STOP_COMMAND`/`PORT`/`WAIT_TIMEOUT` single-quoted, no `PROJECT_DIR`, values preserved including a value with spaces and a trailing comment; `--legacy-values` on a non-legacy file → `not-legacy`, exit 3. Confirm they FAIL before T024
- [X] T024 [US3] `SKILL/scripts/sync-managed.sh`: add `legacy` status (marker-less `scripts/dev.sh` with `^START_COMMAND=` and `^PORT=` lines) to `--check`/`--apply` (`skipped-legacy`), and the `--legacy-values` mode (subshell `eval` of only the matching assignment lines, single-quoted output with `'\''` escaping, fixed key order, exit 3 `not-legacy`)
- [X] T025 [US3] `SKILL/SKILL.md` Setup step 6: when `--check` reports `legacy` → run `--legacy-values`, show the kept values (start, stop, port; note `PROJECT_DIR` is dropped because the new wrapper derives it), propose `scripts/dev.env` from them (merged with discovery only for keys the legacy file lacks) and the managed wrapper replacement; on confirmation write `dev.env` then `--apply` after removing the legacy file (`--apply` treats a missing file as `created`); declined → leave both, report `scripts/dev.sh ……… legacy, left as-is`
- [X] T026 [US3] `SKILL/SKILL.md` Phase 0 managed-files bullet: `legacy` + not `--silent` → offer the same migration inline (values shown, confirm, write, `--apply`, then one path-scoped commit of `scripts/dev.sh` + `scripts/dev.env` with message `chore(webapp-uat): migrate scripts/dev.sh to managed engine + scripts/dev.env`); declined or `--silent` → continue using the legacy wrapper, record "legacy wrapper left unmigrated — `/webapp-uat setup` migrates it" for the final report; Phase 5 bullet gains that line
- [X] T027 [P] [US3] `README.md` Updating section "existing installs" paragraph and `SKILL/USAGE.md` Phase 0 item: one sentence each on legacy detection + migration-on-confirmation, `--silent` leaves it alone

**Checkpoint**: legacy installs migrate with values preserved; unattended runs never touch them.

---

## Phase 6: User Story 4 — A user can take ownership of a managed file (Priority: P2)

**Goal**: Marker removed → never overwritten, reported once per run, re-adoptable via setup with confirmation.

**Independent Test**: spec.md US4 Independent Test; automated unmanaged cases already in T003; live quickstart §2f.

- [X] T028 [US4] `SKILL/SKILL.md` Phase 0 managed-files bullet: `unmanaged` → never written; print one line "`<path>` is unmanaged (marker removed) — `/webapp-uat setup` can re-adopt it"; carry to the final report; Phase 5 bullet gains "Unmanaged: `<paths>`"
- [X] T029 [US4] `SKILL/SKILL.md` Setup step 6: `unmanaged` → offer "replace with the managed version (your edits are lost) / keep yours"; replace only on confirmation (delete then `--apply` → `created`); never under `--silent`; report line either way
- [X] T030 [P] [US4] `README.md` Updating section "Taking ownership of a managed file" paragraph (remove the marker line; what happens; how to get the skill's version back) and `SKILL/USAGE.md` File reference note on the marker

**Checkpoint**: all four stories complete in `SKILL.md` and docs.

---

## Phase 7: Polish & cross-cutting

- [X] T031 [P] `.github/workflows/sync-check.yml`: add steps `bash -n scripts/*.sh .claude/skills/webapp-uat/scripts/*.sh .claude/skills/webapp-uat/templates/dev.sh` and `bash scripts/test-sync-managed.sh` before `check-sync.sh`; update the header comment; rename the job/file only if the name would mislead (keep `sync-check` to preserve badge/URL stability)
- [X] T032 [P] `docs/requirements.md`: amend NR-026 (bundled-copy reference via the skill's own folder, not a project-relative path); add a note under UAT-11's FR-005 that its letter is superseded by UAT-13 (intent preserved: marker-less wrappers are never overwritten); add NR-028…NR-03x: managed set + marker (FR-001), engine carries no project values / `dev.env` schema (FR-002–004), setup writes `dev.env` + applies managed files (FR-005), load-time status never blocks (FR-006), Phase 0 apply + path-scoped auto-commit incl. `--silent` (FR-007–008), unmanaged/legacy handling (FR-009–010), self-references resolve for every install type (FR-011), report line (FR-012), copy-pairs (FR-013); NR-024's layout list adds `scripts/dev.env`
- [X] T033 [P] `docs/design-history.md`: add **D13 — Managed files: engine/values split, marker contract, and self-applied updates** (problem found 2026-09-06; the three moves; alternatives rejected with reasons — SessionStart hook, run-from-skill-dir, version tags, three-way merge; the auto-commit decision; the `${CLAUDE_SKILL_DIR}` axe-path defect and why text-tracing couldn't catch it, echoing D12's lesson; demo-app's wrapper deliberately left legacy)
- [X] T034 [P] `docs/roadmap.md`: add **UAT-13 — Self-Updating Managed Files** after UAT-12 (status, user outcome, scope included/deferred, dependencies UAT-01/UAT-11, completion evidence pointer to `specs/011-…/quickstart.md`); update the build-order paragraph and the "All 12 roadmap slices" paragraph to 13
- [X] T035 Re-sync `demo-app/.claude/skills/webapp-uat/` from `SKILL/` (tracked files only: `SKILL.md`, `USAGE.md`, `SETUP.md`, `config.md.example`, `templates/*`, `vendor/axe.min.js`, `scripts/sync-managed.sh`; delete its `templates/dev.sh.template`), commit inside the submodule (`chore: sync webapp-uat skill copy (UAT-13 managed files)`), bump the pointer in the parent; leave `demo-app/scripts/dev.sh` legacy-shaped (out of scope) and note in D13 that the new skill reports it as `legacy`
- [X] T036 Run all gates: `bash -n …`, `bash scripts/test-sync-managed.sh`, `bash scripts/check-sync.sh` → all green including the demo-app pair
- [X] T037 Live verification per `quickstart.md` §2 with the non-interactive `claude` CLI where possible (path-based marketplace add from this working copy, project-scope install into a scratch target, `--help` status block, setup, simulated update, Phase 0 apply + commit, ownership opt-out; the load-time status block appearing at all is the evidence that `${CLAUDE_SKILL_DIR}` resolves for a plugin install, which the axe-core path relies on — SC-007); record commands + observed output in `quickstart.md` "Done when"; revert any simulated-update commit in this repo
- [X] T039 (found in T037) `SKILL/scripts/sync-managed.sh --print <bundled path>` + test cases + `SKILL.md` `--help`/axe/dev.env.example references routed through it; contract, quickstart, D13 updated — plugin installs cannot read the skill folder directly (harness blocks `Read`/`cat` outside working dirs), only execute the pre-authorized script
- [X] T038 `docs/roadmap.md` UAT-13 status → Done (or "Done — live verification partial: …" with the exact remnant), mirroring UAT-11's honesty about what was and wasn't exercised

---

## Dependencies

- Phase 1 → Phase 2 → (Phase 3 ‖ Phase 4) → Phase 5 → Phase 6 → Phase 7.
- US1 and US2 both edit `SKILL.md` (different sections: Phase 0/5 + Managed-files block vs. Setup mode) — do them sequentially in one editing pass to avoid conflicting edits, but their doc tasks marked [P] are independent.
- US3 depends on US2 (setup step 6 shape) and on T008 (sync script). US4 depends on US1 (Phase 0 bullet) and US2 (setup step 6).
- T035 (demo-app re-sync) must come after every `SKILL/` edit; T036 after T035; T038 after T037.

## Parallel execution examples

- Phase 2: T005, T006, T007 in parallel (three different files), then T008, then T009.
- Phase 3: T015 and T016 in parallel after T011–T014.
- Phase 4: T019, T020, T021, T022 in parallel after T017–T018.
- Phase 7: T031, T032, T033, T034 in parallel; T035 after all `SKILL/` edits.

## Implementation strategy

1. **MVP** = Phase 2 + Phase 3 + Phase 4 (US1 + US2): after this, a fresh plugin install sets up cleanly and any later skill update propagates on the next run. Every automated gate is green for the parent repo.
2. Add US3 (legacy) — makes every *existing* install migrate safely; required before announcing the update path to current users.
3. Add US4 (ownership) — the escape hatch; small.
4. Polish: CI, docs, demo-app re-sync, live verification, roadmap.

## Format validation

All 38 tasks: checkbox ✔, sequential IDs T001–T038 ✔, [P] only where files differ and no pending dependency ✔, [USn] on every story-phase task and on none outside them ✔, explicit file path in every description ✔.
