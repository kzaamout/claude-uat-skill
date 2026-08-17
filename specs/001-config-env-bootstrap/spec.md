# Feature Specification: Config & Environment Bootstrap

**Feature Branch**: `001-config-env-bootstrap`

**Created**: 2026-08-14

**Status**: Draft

**Input**: User description: "UAT-01 — Config & Environment Bootstrap. User outcome: point the skill at a repo and get a working config.md plus a verified start/stop/health-check wiring, without hunting down values by hand. Scope included: repo-root detection; start/stop/port detection using a most-specific-evidence-first rule; bug-fix-mechanism detection (spec-kit vs. direct); spec-dir detection; detected/guessed/needs-your-input labeling on every proposed value; a propose-then-confirm-then-write flow that never writes without approval; safe re-run against an already-configured project. Scope explicitly deferred: actually starting/stopping the target app during setup itself (stays a manual, later verification step); config-schema validation beyond existence (a separate capability). Relevant specification sources: SKILL.md's Setup mode section (steps 1-7), SETUP.md, config.md.example."

## Clarifications

### Session 2026-08-15

- Q: If the write step fails partway through (some files/directories created, others not), what must happen? → A: Best-effort — whatever succeeded stays, each failure is reported per item, re-running completes the rest (no rollback required).
- Q (found during `/speckit-implement`, not a formal clarification round): FR-002's third detection tier named `Procfile` alongside `Makefile`, but a real `Procfile` doesn't use `dev`/`up`/`down`-shaped target names — should the fixture/expectation be corrected, or is the requirement itself wrong? → A: The requirement was wrong — drop `Procfile` from this tier entirely; document as deferred (`docs/design-history.md` D5) rather than silently narrow the wording.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-time setup on a fresh project (Priority: P1)

A user has just installed the skill into their project and has no `config.md` yet. They want the skill to inspect their repo and propose working configuration values instead of making them hunt down a start command, a port, and a bug-fix mechanism by hand.

**Why this priority**: This is the entire point of the feature — without it, every other capability of the skill is blocked at invocation, since nothing else runs until `config.md` exists. It's the smallest slice that proves the core value loop: point at a repo, get a reviewed, working configuration.

**Independent Test**: Can be fully tested by running setup against a repo with no `config.md`, confirming a single consolidated draft is presented with every value labeled by confidence, and confirming nothing is written to disk until an explicit approval is given.

**Acceptance Scenarios**:

1. **Given** a repo with a `run.sh` at its root alongside a `docker-compose.yml`, **When** setup runs, **Then** the draft proposes that script as the start command and `docker compose down` as the stop command, both labeled **detected** with the specific file evidence named.
2. **Given** a repo with a `package.json` declaring a `dev` script and no compose file, **When** setup runs, **Then** the draft proposes the equivalent run command for whichever lockfile is present, labeled **detected**.
3. **Given** a repo with no `PORT` value discoverable anywhere, **When** setup runs, **Then** the draft proposes port `3000`, explicitly labeled **guessed**, never presented as though it were detected.
4. **Given** a repo containing a `.specify/` directory, **When** setup runs, **Then** the draft proposes `bug-fix-mechanism: spec-kit`, and the exact command names are not guessed — the user is shown `specify extension list`'s real output and asked which three entries are correct.
5. **Given** a repo with no `.specify/` directory and no `specify` on `PATH`, **When** setup runs, **Then** the draft proposes `bug-fix-mechanism: direct`, needing no further input.
6. **Given** the consolidated draft has been presented, **When** the user chooses to write it, **Then** `config.md` is created, `scripts/dev.sh`'s placeholders are filled in, and any missing `uat/scenarios`, `uat/runs`, `uat/artifacts`, `uat/fixtures` directories are created.
7. **Given** the same draft, **When** the user chooses to cancel instead, **Then** nothing is written to disk.
8. **Given** the user has confirmed the write, **When** one item (a file or a directory) fails to be created partway through, **Then** every item that already succeeded is retained as-is, the specific failure is reported for each item that did not succeed, and no already-written item needs to be manually undone before the process can be safely re-run to complete the rest.

---

### User Story 2 - Re-running setup on an already-configured project (Priority: P2)

A user who already has a working `config.md` runs setup again — deliberately, to pick up a repo change, or by accident.

**Why this priority**: Protects against the single most damaging failure mode this feature could have — silently clobbering a working configuration. Independently verifiable from first-time setup, since it only matters once a `config.md` already exists.

**Independent Test**: Can be fully tested by running setup a second time against a repo that already has a `config.md` and confirming the existing values are shown alongside the newly-proposed ones, with nothing replaced until the user explicitly approves.

**Acceptance Scenarios**:

1. **Given** an existing `config.md`, **When** setup runs again, **Then** the current value for each setting is shown next to what discovery now proposes, not silently replaced.
2. **Given** that comparison is shown, **When** the user declines to change a value, **Then** the existing value is left exactly as it was.
3. **Given** that comparison is shown, **When** the user approves specific changes, **Then** only the approved values are updated in `config.md`.

---

### User Story 3 - Setup on a genuinely ambiguous project (Priority: P3)

A user runs setup against a repo where the standard detection heuristics don't apply cleanly — the skill is installed inside a nested package of a monorepo, or nothing about the project's start mechanism matches any recognized convention.

**Why this priority**: Prevents the failure mode of a wrong guess being silently committed to and inherited by every future run. Independently testable from the two stories above, since it specifically exercises the "ask, don't guess" boundary.

**Independent Test**: Can be fully tested by running setup against a repo with an ambiguous root (the skill sitting in a monorepo subpackage) or an unrecognized start mechanism, and confirming the user is asked a direct question rather than receiving a silently-guessed answer presented as reliable.

**Acceptance Scenarios**:

1. **Given** the skill is installed inside a nested package of a monorepo, **When** setup tries to locate the repo root, **Then** the user is asked which root is intended rather than one being silently assumed.
2. **Given** a repo with no `run.sh`/`start.sh`, no compose file, no `package.json` dev/start script, and no recognizable `Makefile` target, **When** setup runs, **Then** the start/stop fields are left blank and labeled **needs your input**, not filled with a fabricated guess.
3. **Given** a repo with no `specs/` directory or equivalent convention, **When** setup runs, **Then** `spec-dir` is left unset, and the draft notes that spec-derived generation and the UI-conformance check will no-op without it.

---

### Edge Cases

- What happens when the skill's location and the git repo root genuinely can't be reconciled (e.g., the skill folder isn't inside a git working tree at all)? The user is asked rather than the setup proceeding on an assumed root.
- What happens when a repo has multiple plausible start mechanisms at once (e.g., both a `run.sh`+compose pair and a `package.json` dev script)? The most-specific-evidence order applies: `run.sh`/`start.sh` + compose takes precedence over a bare `package.json` script.
- What happens when the user asks to write the draft but then cancels partway through reviewing it? Nothing already-written is left in a half-applied state — the write step is all-or-nothing per file.
- What happens when the write step itself technically fails partway through (e.g., a permissions error creating one of the `uat/` directories) after some items were already written? Whatever succeeded is retained, the specific failure is reported per item, and the process remains safe to re-run to complete what's left — not treated as requiring manual cleanup first.
- What happens when a `.specify/` directory exists but `specify` is not actually usable (e.g., not on `PATH` despite the directory being present)? The mechanism is still proposed as `spec-kit` since the directory is the detection signal used; the exact command values still require the user's explicit input either way.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST locate the target repo's root (e.g., via the skill's own installed location within a git working tree) and MUST ask the user rather than guess when that root is ambiguous, such as the skill sitting inside a nested package of a monorepo.
- **FR-002**: System MUST attempt to detect the project's start/stop mechanism using a most-specific-evidence-first order: a `run.sh`/`start.sh` at the repo root alongside a Docker Compose file takes precedence over a `package.json` dev/start script, which takes precedence over a `Makefile` with recognizable dev/up/down-shaped targets. If none of these are found, the start/stop fields MUST be left blank and labeled needs-your-input rather than filled with an invented value. (`Procfile` detection was considered and deliberately dropped from this feature — see Assumptions.)
- **FR-003**: System MUST attempt to detect a port from an environment file, a dev-server configuration file, or a container port mapping. When none is found, system MUST propose a default port value explicitly labeled as a guess, never presented with the same confidence as a detected value.
- **FR-004**: System MUST attempt to detect whether a spec-driven bug-fix workflow tool is present (evidenced by a recognizable configuration directory or the tool being available to invoke) and, if so, propose the corresponding bug-fix mechanism; otherwise it MUST propose the mechanism that requires no external tool as the default.
- **FR-005**: When the spec-driven bug-fix mechanism is proposed, system MUST NOT guess the exact commands that mechanism needs — it MUST surface the tool's own real list of available commands and ask the user which entries are the correct ones.
- **FR-006**: System MUST attempt to detect a specification-source directory (a conventional location containing specification files); when none is found, system MUST leave this setting unset and note which downstream capabilities will not run without it, rather than silently defaulting to a guessed path.
- **FR-007**: System MUST present every proposed configuration value labeled with exactly one of three confidence levels — detected (with the specific supporting evidence named), guessed (a heuristic default with no real evidence behind it), or needs-your-input (nothing found, or genuinely ambiguous) — and MUST NOT present these three levels in a way that makes them appear equally reliable.
- **FR-008**: System MUST NOT write any configuration file or modify any existing file as a result of this process until the user has explicitly confirmed doing so, choosing among writing the draft as shown, editing values first, or cancelling.
- **FR-009**: Upon confirmed write, system MUST create the project's configuration file, fill in the placeholders of the project's start/stop/health-check script, and create any of the skill's expected working directories that don't already exist.
- **FR-010**: This process MUST NOT start or stop the target application itself as one of its own steps; verifying the start/stop/health-check wiring actually works is a separate, later, manual step.
- **FR-011**: When an existing configuration file is found, system MUST NOT overwrite it silently — it MUST show the currently-set values next to the newly-proposed values and require explicit approval before replacing any of them.
- **FR-012**: This process MUST be safe to invoke more than once against the same project without causing an unintended or unreviewed change each time.
- **FR-013**: If the write step fails partway through (one file or directory cannot be created), system MUST retain whatever was already successfully written, MUST report the specific failure for each item that did not succeed, and MUST NOT require any already-written item to be manually undone before the process can be safely re-run to complete the rest.

### Key Entities

- **Configuration Draft**: The consolidated set of proposed values (start/stop/port, bug-fix mechanism and its commands, spec-source directory) presented for review in one pass, each carrying its own confidence label and, for detected values, the specific evidence that produced it.
- **Project Configuration**: The persisted result of an approved draft — the values downstream skill behavior reads on every subsequent invocation.
- **Start/Stop/Health-Check Wiring**: The project-specific script this feature fills in the placeholders of, but does not itself execute or validate.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user with no prior configuration can go from starting this process to having a reviewed, working project configuration in a single guided interaction, without hand-editing any file themselves.
- **SC-002**: Every proposed value's confidence level is visible to the user before they approve anything, and every value labeled as detected names the specific evidence that produced it.
- **SC-003**: Re-running this process against an already-configured project never results in a change the user did not explicitly approve.
- **SC-004**: A user in a genuinely ambiguous situation is asked a direct question rather than receiving a silently-guessed value presented as though it were reliable.

## Assumptions

- **Detection is convention-based, not exhaustive**: the start/stop/port/bug-fix-mechanism/spec-dir detection rules assume common, recognizable project conventions (Docker Compose, `package.json` scripts, `Makefile`, a `.specify/`-style directory, a `specs/`-style directory). A project using an entirely bespoke mechanism that matches none of these conventions correctly lands in needs-your-input rather than being falsely detected — this is the intended behavior, not a gap.
- **`Procfile` detection deliberately dropped, not deferred by oversight**: found during implementation that a real `Procfile` conventionally uses process-type names (`web`, `worker`) rather than the `dev`/`up`/`down`-shaped target names this tier actually checks for — the original wording claimed `Procfile` support it could never actually match. Removed from FR-002's tier 3 entirely rather than leave an unreachable rule in place; recorded as `docs/design-history.md` D5 for a properly-designed follow-up (e.g. detecting a `Procfile`'s `web:` entry specifically), not built here.
- **Verification is out of scope here**: confirming that the written start/stop/health-check wiring actually works end-to-end is treated as a separate, later, manual step and is not part of this feature's own completion criteria.
- **Configuration-content validation is a separate capability**: this feature validates that a configuration file gets written correctly through user approval; validating the internal consistency of an already-written configuration (e.g., a bug-fix mechanism selected without its required supporting values) is out of scope for this feature.
