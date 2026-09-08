# Feature Specification: Self-Updating Managed Files

**Feature Branch**: `011-self-updating-managed-files`

**Created**: 2026-09-07

**Status**: Draft

**Input**: User description: "UAT-13 -- Self-Updating Managed Files (plugin-update propagation). User outcome: a user who installed webapp-uat as a plugin runs `claude plugin marketplace update webapp-uat-marketplace` + `claude plugin update webapp-uat@webapp-uat-marketplace`, restarts Claude Code, and the next `/webapp-uat` invocation brings every skill-owned file living in the project's own tree (`scripts/dev.sh`, `uat/scenarios/_template.md`) to the installed skill's version with zero manual merging and without touching any project-owned data (`scripts/dev.env`, `config.md`, `discovered-environment.md`, scenarios, fixtures). Manual (copy-by-hand) installs get the same behavior after re-copying the skill folder. Root cause being fixed: today `scripts/dev.sh` mixes skill logic (pidfile/SIGINT/wait-ready loop) with four project values filled in by setup (PROJECT_DIR, START_COMMAND, STOP_COMMAND, PORT), so it can never be overwritten; a plugin update refreshes the bundled `templates/` in the plugin cache but nothing propagates them into the project tree (setup copies only when the file is missing). Scope included: (1) split dev.sh into a placeholder-free, skill-owned engine (`scripts/dev.sh`, same `start|stop|wait-ready` interface, unchanged exit codes, derives the project root from its own location instead of a configured PROJECT_DIR) plus a project-owned committed values file `scripts/dev.env` (START_COMMAND, STOP_COMMAND, PORT, optional WAIT_TIMEOUT default, optional READY_COMMAND to replace the curl health check) that the engine sources; setup proposes/writes dev.env from a bundled `dev.env.example` using its existing discovery + confirm-before-write flow. (2) A managed-file contract: every skill-owned file placed in the project tree carries a first-lines marker ('webapp-uat managed file -- do not edit; overwritten on skill update; remove this line to take ownership'); the skill overwrites a file only when the marker is present; a marker-less file is left untouched and reported once per run. (3) A deterministic bundled sync script (`${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh <project-root> --check|--apply`): byte-compares each bundled managed file against the project copy; `--check` only reports (per-file status: in sync / update available / unmanaged / missing) and always exits 0; `--apply` copies every differing marker-bearing file and reports what changed; no version numbers, no LLM judgment. (4) Invocation points: SKILL.md runs `--check` at load time via dynamic context injection so the drift state is visible before any phase; Phase 0 pre-flight runs `--apply` before the clean-working-tree check and, if anything changed, commits the result as one chore commit whose message names the files (this commit happens under `--silent` too since managed files contain no project data); Setup mode's write step runs `--apply` as one of its items (covers first install and re-runs). (5) Every reference the skill makes to its own bundled files (templates, `vendor/axe.min.js`, the sync script) uses Claude Code's `${CLAUDE_SKILL_DIR}` substitution instead of a project-relative or 'this skill's own folder' phrasing -- fixes a latent D12-class defect: SKILL.md's axe-core path `.claude/skills/webapp-uat/vendor/axe.min.js` does not exist in the project tree for a plugin install (NR-026 must be corrected accordingly). (6) One-time legacy migration: a `scripts/dev.sh` with no marker but with the old four-variable block is legacy; Setup mode (and Phase 0 when not `--silent`) extracts the four values, proposes `dev.env` + the engine replacement, and writes on confirmation; under `--silent` a legacy dev.sh is left as-is (it still works -- the interface is unchanged) and the final report notes that setup will migrate it. (7) This repo's own copy-pairs: `templates/dev.sh.template` becomes `templates/dev.sh` (no placeholders left), `templates/dev.env.example` and root `scripts/dev.env.example` are added, root reference copies stay byte-identical, `scripts/check-sync.sh` updated to the new pair list. (8) Docs: README gains an 'Updating' section (both install paths, the two plugin commands, restart, what the next run does, what is never touched) and updated install/structure text; SETUP.md step 3 covers dev.env; USAGE.md Phase 0 + file reference; `docs/requirements.md` new NR entries; `docs/design-history.md` D13; `docs/roadmap.md` UAT-13. Scope explicitly deferred: a plugin SessionStart hook that syncs on every session start (writes into every project with the plugin enabled -- rejected); an explicit `/webapp-uat update` command (Phase 0 + setup cover it); release tags / version fields (byte comparison suffices); migrating demo-app's own project-specific dev.sh to the engine+dev.env shape (separate repo, follow-up). Dependencies: UAT-01 (extends Setup mode), UAT-11 (plugin install mechanics; D12 location rule for per-project files). Verified facts this rests on (official Claude Code docs, 2026-09-06): `${CLAUDE_SKILL_DIR}` is substituted in skill markdown and `allowed-tools` for plugin, project, and personal skills; dynamic context injection runs before Claude sees the skill body, never prompts for permission, and a non-zero exit aborts the invocation (hence `--check` must always exit 0); `claude plugin update` does not refresh the marketplace clone, so `claude plugin marketplace update` must run first; plugin version for this marketplace is the repo commit SHA, so every commit is an update. Completion evidence target: in a scratch target repo with a project-scope plugin install, `/webapp-uat setup` lands the engine dev.sh (with marker), dev.env, and _template.md; after installing a newer commit whose bundled files differ, the next `/webapp-uat` run's Phase 0 overwrites both managed files, leaves dev.env/config.md byte-identical, and produces exactly one chore commit; a copy with the marker removed is left untouched and reported; a legacy four-variable dev.sh is migrated by setup with its values preserved in dev.env; `scripts/check-sync.sh` passes."

## Background

`webapp-uat` places two of its own files into the project it is installed in, outside
the skill folder: the app start/stop wrapper (`scripts/dev.sh`) and the scenario
template (`uat/scenarios/_template.md`). Today the wrapper has four project values
written into it by setup, so it can never be replaced without losing them, and nothing
copies a newer bundled version into the project after the skill itself is updated. The
result is that every skill release that touches either file leaves existing installs
running the old one, and the only remedy is a hand merge — which this feature
eliminates.

Two decisions were made with the product owner on 2026-09-07 before this spec was
written and are treated as settled here: (a) the wrapper is split into a skill-owned
engine with no project data plus a small project-owned values file, so the engine can
be overwritten freely; (b) when a run finds a pending update it applies it and commits
the result on its own, including in unattended (`--silent`) runs, because the files
being replaced contain nothing project-specific.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Skill-owned project files update themselves after a skill update (Priority: P1)

A user who installed `webapp-uat` as a plugin updates it with Claude Code's own two
update commands, restarts, and runs `/webapp-uat` as usual. Without editing, copying,
or merging anything, the project's copies of the skill-owned files (`scripts/dev.sh`,
`uat/scenarios/_template.md`) are now the versions that shipped with the newly
installed skill. The run tells them what was updated, records it as one commit, and
carries on. Nothing the user owns — their start/stop values, config, cached
environment facts, scenarios, fixtures, run history — is touched.

**Why this priority**: This is the feature. Without it, every release that changes
either file strands every existing install on the old version, and the documented
"update" is a hand merge.

**Independent Test**: In a scratch project with the plugin installed and set up,
install a newer skill version whose bundled copies of both files differ from the
project's, run `/webapp-uat`, and confirm both project files now match the bundled
versions, every project-owned file is byte-identical to before, and exactly one new
commit exists containing only the two managed files.

**Acceptance Scenarios**:

1. **Given** a set-up project whose two managed files differ from the installed
   skill's bundled copies, **When** `/webapp-uat` runs, **Then** before any other
   pre-flight step both files are replaced with the bundled copies, the change is
   committed as one commit whose message names both files, and the run continues.
2. **Given** the same starting state, **When** the run finishes, **Then** the final
   report lists which managed files were updated in that run.
3. **Given** a set-up project whose managed files already match the installed
   skill, **When** `/webapp-uat` runs, **Then** no file is written, no commit is
   made, and the report does not mention managed files at all.
4. **Given** a pending update, **When** `/webapp-uat --silent` runs, **Then** the
   update and its commit happen without a confirmation prompt and are noted in the
   final report.
5. **Given** a pending update and a project working tree that also has unrelated
   uncommitted changes, **When** `/webapp-uat` runs, **Then** the managed-file
   commit contains only the managed files, and the unrelated changes are then handled
   by the existing clean-working-tree step exactly as before.
6. **Given** a pending update, **When** `/webapp-uat` is invoked at all (any mode,
   including `--help`), **Then** the per-file managed status (in sync / update
   available / unmanaged / missing) is visible to the user at the start of the
   invocation, and the invocation is never blocked or aborted by that status check.
7. **Given** a manual (copy-by-hand) install, **When** the user re-copies the skill
   folder from a newer source and runs `/webapp-uat`, **Then** the same update
   behavior applies with no additional steps.

---

### User Story 2 - Start/stop values live outside the managed script (Priority: P1)

A user setting up `webapp-uat` in a project gets a start/stop wrapper they never edit
and a small, plainly named values file that holds only what is specific to their app:
how to start it, how to stop it, which port to wait on, and optionally how long to
wait or a custom readiness check. Setup proposes those values from what it discovers
in the repo, the user confirms, and the wrapper works. Nothing about how the wrapper
is driven (`start`, `stop`, `wait-ready`) changes from before.

**Why this priority**: Story 1 is only safe because of this story. A wrapper that
carries project values cannot be overwritten; one that carries none can be.

**Independent Test**: Run `/webapp-uat setup` in a fresh project (plugin install),
confirm the proposed values, then run start / wait-ready / stop by hand. All three
work; the wrapper contains no project-specific value; every project-specific value is
in the values file.

**Acceptance Scenarios**:

1. **Given** a fresh plugin install with no wrapper or values file, **When** setup
   runs and the user confirms, **Then** the wrapper is written with the managed
   marker and no project values, and the values file is written with the discovered
   start command, stop command, and port.
2. **Given** a written wrapper and values file, **When** the user runs start,
   wait-ready, then stop by hand, **Then** each behaves as documented and returns the
   same success/failure status the previous wrapper did for the same situations.
3. **Given** the values file is absent or missing a required value, **When** the
   wrapper is run, **Then** it stops immediately with a message that names the
   missing file or value and says to run setup.
4. **Given** an app whose readiness cannot be detected by a plain port check,
   **When** the user sets the optional readiness-check value, **Then** wait-ready
   uses that check instead of the port check.
5. **Given** the wrapper is moved together with its project (e.g. cloned to a
   different path), **When** it is run, **Then** it still resolves the project root
   correctly without any value being changed.

---

### User Story 3 - An existing install migrates once, keeping its values (Priority: P2)

A user who set up `webapp-uat` before this change has a wrapper with their four values
written into it. After updating the skill, setup (or a normal attended run) notices
this, shows the values it found, proposes the values file plus the new wrapper, and
writes them on confirmation. Their start/stop/port values are preserved; the old
absolute project path is dropped because the new wrapper derives it. Until they
confirm, the old wrapper keeps working exactly as it did.

**Why this priority**: Every install that exists today is in this state. Without a
migration path, Story 1 would either overwrite their values or permanently skip them.

**Independent Test**: Take a project with the old-style wrapper filled in, update the
skill, run setup, confirm the migration, and check the values file holds the same
start command, stop command, and port, and that start / wait-ready / stop still work.

**Acceptance Scenarios**:

1. **Given** an old-style wrapper with four filled-in values, **When** setup runs,
   **Then** it reports the wrapper as legacy, shows the three values it will keep,
   proposes the values file and the replacement wrapper, and writes both only on
   confirmation.
2. **Given** an old-style wrapper, **When** an attended `/webapp-uat` run reaches
   pre-flight, **Then** it offers the same migration; declining leaves the wrapper
   untouched and the run continues using it.
3. **Given** an old-style wrapper, **When** `/webapp-uat --silent` runs, **Then**
   nothing is migrated, the run uses the old wrapper as-is, and the final report says
   setup will migrate it.
4. **Given** a migrated project, **When** a later skill update changes the wrapper,
   **Then** Story 1 applies to it like any other managed file.

---

### User Story 4 - A user can take ownership of a managed file (Priority: P2)

A user who needs to customize a managed file beyond what its values file allows
removes the marker line from it. From then on the skill leaves that file alone,
tells them once per run that it is unmanaged, and never silently reclaims it. If they
later want the skill's version back, setup offers to replace it, with confirmation.

**Why this priority**: Automatic overwriting needs an explicit, discoverable off
switch, or users with a legitimate customization are forced to fight the tool.

**Independent Test**: Remove the marker from a managed file, run `/webapp-uat` with a
pending update, and confirm the file is unchanged and reported as unmanaged; then run
setup and confirm it offers to re-adopt the file and only does so on confirmation.

**Acceptance Scenarios**:

1. **Given** a managed file whose marker line has been removed, **When** an update
   for that file is pending and `/webapp-uat` runs, **Then** the file is not written,
   and pre-flight output and the final report both say it is unmanaged and how to
   re-adopt it.
2. **Given** an unmanaged file, **When** setup runs, **Then** it offers to replace the
   file with the managed version and does so only on confirmation.
3. **Given** an unmanaged file, **When** `/webapp-uat --silent` runs, **Then** the
   file is never replaced.

---

### Edge Cases

- A managed file has the marker **and** hand edits: it is overwritten. The marker's
  own text says so, and removing it is the supported way to keep edits.
- A managed file is missing entirely (e.g. deleted, or plugin installed but setup
  never run): pre-flight recreates it when it carries no project data; the values
  file is never fabricated by pre-flight — that is setup's job, and pre-flight says so.
- The values file contains a key the wrapper does not know: it is ignored. A required
  key is absent: the wrapper stops with a message naming the key.
- The status check at skill load cannot run (e.g. an organization policy disables
  shell execution in skills): the invocation still proceeds, pre-flight performs the
  same check through its normal tooling, and nothing is lost except the early notice.
- The bundled sync mechanism itself is missing or unrunnable: pre-flight reports that
  managed files could not be checked and continues with the files as they are, rather
  than blocking the run.
- The two update commands are run in the wrong order or only one is run: no harm — the
  next run simply finds nothing to update, and the README's Updating section states
  the required order.
- The repository's own reference copies (this repo dogfoods the skill) and the bundled
  copies drift: the existing sync-check guard fails CI, as it does today.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST define a fixed managed-file set — the files it owns that
  live in the project tree: `scripts/dev.sh` and `uat/scenarios/_template.md`. Each
  MUST carry, within its first three lines, a marker stating that the file is managed
  by webapp-uat, is overwritten on skill update, must not be edited, and that removing
  the marker line takes ownership. The presence of that marker is the sole authority
  for overwriting a file.
- **FR-002**: The start/stop wrapper MUST contain no project-specific value. Every
  project-specific value MUST live in a separate project-owned values file at
  `scripts/dev.env`, which the wrapper reads when run. The wrapper's command
  interface (`start`, `stop`, `wait-ready`) and its success/failure statuses for the
  same situations MUST be unchanged from the previous wrapper.
- **FR-003**: The values file MUST support: a start command (required); a stop
  command (optional; nothing extra is run when absent); a port to wait on (required
  unless a readiness check is given); a wait timeout with the same default and
  per-run override behavior as today (optional); and a readiness check command that
  replaces the port check (optional). The wrapper MUST derive the project root from
  its own location, never from a configured path.
- **FR-004**: When the values file is absent or a required value is missing, the
  wrapper MUST stop immediately with a message that names the missing file or value
  and points to setup, and MUST return a failure status.
- **FR-005**: Setup mode MUST propose the values file's contents from its existing
  discovery, using the same confirm-before-write, per-item outcome reporting it
  already uses, and MUST NOT write project values into the wrapper. Setup's write step
  MUST also place or refresh every managed file as one of its items.
- **FR-006**: At every skill invocation, before any mode or phase runs, a per-file
  status for each managed file — *in sync*, *update available*, *unmanaged*, or
  *missing* — MUST be computed and, whenever any file is not *in sync*, shown to the
  user before anything else happens; when every file is in sync the invocation stays
  silent about managed files. This status check MUST be deterministic (content
  comparison, no judgment), MUST never prompt, and MUST never block or abort the
  invocation, whatever it finds.
- **FR-007**: Pre-flight MUST apply pending managed-file updates before its
  clean-working-tree check: overwrite each marker-bearing file whose content differs
  from the bundled copy, create each missing managed file, and touch nothing else.
  Project-owned files — the values file, `config.md`, `discovered-environment.md`,
  scenarios other than the template, fixtures, run history and artifacts — MUST
  never be written by this step.
- **FR-008**: If the pre-flight apply changed anything, the skill MUST commit exactly
  the changed managed files, and nothing else, as one commit whose message names
  them. This MUST happen in `--silent` runs as well, without a confirmation prompt.
  Unrelated uncommitted changes MUST be left for the existing clean-working-tree
  step. If nothing changed, no commit is made.
- **FR-009**: A managed file without the marker MUST be left untouched by every
  automatic step. It MUST be reported once per run, in pre-flight output and in the
  final report, with how to re-adopt it. Setup MUST offer to replace it with the
  managed version and do so only on confirmation; `--silent` runs MUST never replace
  it.
- **FR-010**: A marker-less wrapper that carries the previous four-value block MUST be
  recognized as legacy. Setup, and attended pre-flight, MUST show the three values
  that will be kept (start command, stop command, port), propose the values file plus
  the replacement wrapper, and write on confirmation only. Declining MUST leave the
  legacy wrapper in use. `--silent` runs MUST leave it as-is and state in the final
  report that setup will migrate it.
- **FR-011**: Every reference the skill makes to a file bundled inside its own folder
  (templates, the accessibility script, the sync mechanism) MUST resolve correctly for
  plugin, project-level, and manual installs alike, without assuming the skill folder
  is inside the project tree. The accessibility script reference MUST be corrected
  accordingly, and the corresponding existing requirement (NR-026) amended.
- **FR-012**: The final report MUST list, in a run where any of these occurred:
  managed files updated, managed files reported unmanaged, a legacy wrapper left
  unmigrated. A run where none occurred MUST NOT mention managed files.
- **FR-013**: This repository's own copy-pairs MUST stay byte-identical: the bundled
  wrapper, values example, and scenario template versus their root reference copies
  (`scripts/dev.sh`, `scripts/dev.env.example`, `uat/scenarios/_template.md`). The
  existing sync-check guard MUST cover the new pair list and pass.
- **FR-014**: User-facing documentation MUST describe the update path end to end:
  the README MUST gain an "Updating" section covering both install paths, the exact
  two commands and their order, the restart, what the next run does, and what is
  never touched; the setup checklist MUST cover the values file; the usage reference
  MUST cover the pre-flight behavior and the new file; the requirements reference,
  design history, and roadmap MUST record this feature.

### Key Entities

- **Managed file**: A skill-owned file placed in the project tree, identified by its
  marker. Attributes: project path, bundled source, marker present/absent, status
  relative to the bundled source.
- **Marker**: The first-lines text that declares a file managed and grants
  permission to overwrite it. Removing it transfers ownership to the user.
- **Values file** (`scripts/dev.env`): Project-owned, committed, holds every
  project-specific start/stop/readiness value. Never written by any automatic step.
- **Bundled source**: The copy of a managed file that ships inside the installed
  skill; the single source of truth for what the project copy should contain.
- **Managed-file status**: One of *in sync*, *update available*, *unmanaged*,
  *missing*, computed per file by content comparison.
- **Legacy wrapper**: A marker-less wrapper containing the previous four-value block;
  eligible for one-time migration, otherwise treated as unmanaged.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After a skill update, a user reaches fully updated managed files with
  zero file edits and zero merge steps: two update commands, one restart, one skill
  invocation.
- **SC-002**: Across an update run, 100% of project-owned files (values file, config,
  cached environment facts, scenarios, fixtures, run history) are byte-identical
  before and after.
- **SC-003**: An update run adds exactly one commit, and that commit contains only
  managed files.
- **SC-004**: A fresh setup on a plugin install yields a working start / wait-ready /
  stop with zero hand edits to the wrapper.
- **SC-005**: A legacy install migrates with 100% of its kept values (start command,
  stop command, port) preserved and start / wait-ready / stop working afterwards.
- **SC-006**: A file whose marker was removed survives 100% of update runs unchanged
  and is reported in every one of them.
- **SC-007**: The accessibility check runs successfully on a plugin install where the
  skill folder is not inside the project tree.
- **SC-008**: The repository's sync-check guard passes on the change, in CI.
- **SC-009**: A reader of the README's Updating section can perform an update
  without consulting any other document.

## Out of Scope

- A plugin session-start hook that syncs on every session start (rejected: it would
  write into every project with the plugin enabled, whether or not that project uses
  the skill).
- A dedicated `/webapp-uat update` command (pre-flight and setup already cover it).
- Release tags or version fields for the plugin (content comparison makes them
  unnecessary).
- Migrating the demo application's own project-specific wrapper to the new shape
  (separate repository; a follow-up there).
- Windows / PowerShell support for the wrapper (unchanged from today).

## Assumptions

- The skill is installed either through the plugin marketplace or by copying its
  folder into the project. Skills synced from a claude.ai account are out of scope.
- The Claude Code in use supports the skill-folder path substitution and load-time
  shell injection this feature relies on (both verified against the official docs on
  2026-09-06; the local version, 2.1.263, has both). Where an organization policy
  disables shell injection in skills, the early status notice degrades gracefully and
  pre-flight still performs the same check through its normal tooling.
- The project uses git, and `bash`, `git`, and `curl` are available, as the skill
  already assumes.
- The managed-file commit uses the project's existing git identity, the same way the
  bug-fix cycle's commits do today.
- The managed set is exactly two files. Adding a managed file later means adding it
  to the bundled list with a marker, with no other mechanism change.
- The demo application's own copy of the skill folder (a separate repo, included as a
  submodule) must be re-synced for the repository's sync-check to pass; the demo
  app's own project-specific wrapper stays in its legacy shape until a follow-up in
  that repo, and this feature's legacy handling keeps it working meanwhile.
- The values file is committed to the project, since it contains shared,
  machine-independent values; the per-machine absolute project path it replaces is
  no longer needed anywhere.
