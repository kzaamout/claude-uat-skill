# Feature Specification: One-Command Install

**Feature Branch**: `010-one-command-install`

**Created**: 2026-08-17

**Status**: Draft

**Input**: User description: "UAT-11 -- One-Command Install. User outcome: A stranger installs the skill in a project with two native Claude Code commands (/plugin marketplace add + /webapp-uat setup), no manual file-copying required, despite Claude Code plugins being unable to install files outside .claude/. Scope included: .claude-plugin/marketplace.json at repo root declaring webapp-uat as a git-sourced plugin pointing at .claude/skills/webapp-uat; scripts/dev.sh and uat/scenarios/_template.md shipped as templates inside the installable plugin folder (.claude/skills/webapp-uat/templates/); Setup mode extended to copy those templates into the target repo's own tree when missing, using the same confirm-before-write, best-effort-not-atomic pattern already used for config.md. Scope explicitly deferred: a separate curl | sh install script. Dependencies: UAT-01 (done, extends Setup mode). Relevant existing specification sources: SKILL.md Setup mode step 6 (already extended in a prior session to conditionally copy from bundled templates/ when scripts/dev.sh or uat/scenarios/_template.md don't already exist in the target repo -- this is the plugin-install case, distinct from the manual-copy case where the files already exist and only need placeholder-filling); .claude-plugin/marketplace.json (already exists, already committed); README.md Installation & setup section (already documents the one-command path). Completion evidence target: from a scratch clone, /plugin marketplace add kzaamout/claude-uat-skill + /plugin install webapp-uat@webapp-uat-marketplace + /webapp-uat setup lands config.md, scripts/dev.sh, and uat/scenarios/_template.md correctly with zero manual file copying. This is expected to land specified-but-not-live-verified for the /plugin portion specifically -- /plugin is an interactive CLI meta-command with no tool access available in this session, so the actual install flow needs real user/session testing; the Setup mode template-copy logic itself, and the marketplace.json schema, were already verified this session via direct SKILL.md reading and prior research-agent fact-checking against live Claude Code docs."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A stranger installs the skill with two commands, no manual copying (Priority: P1)

A user evaluating `webapp-uat` for the first time, with no prior familiarity with
this repo's structure, needs to get it working in their own project using only
Claude Code's own native commands — `/plugin marketplace add` then
`/webapp-uat setup` — without being told to manually clone, copy files, or edit
paths by hand first.

**Why this priority**: This is the entire point of the feature — the difference
between "clone this repo and copy these three files into yours" and "run two
commands." Independently testable and valuable on its own.

**Independent Test**: Can be fully tested from a scratch target project by
running `/plugin marketplace add kzaamout/claude-uat-skill`, `/plugin install
webapp-uat@webapp-uat-marketplace`, then `/webapp-uat setup`, and confirming
`config.md` is produced without any file having been manually copied first.

**Acceptance Scenarios**:

1. **Given** a target project with no prior `webapp-uat` files, **When**
   `/plugin marketplace add kzaamout/claude-uat-skill` then `/plugin install
   webapp-uat@webapp-uat-marketplace` are run, **Then** the skill becomes
   available as `/webapp-uat` in that project with no files manually copied.
2. **Given** the plugin is installed, **When** `/webapp-uat setup` runs,
   **Then** it proposes and (on approval) writes `config.md` using the same
   discovery-assisted flow as a manually-copied install — no different setup
   experience because the source was a plugin.
3. **Given** a plugin install only places files under the target project's
   `.claude/` directory, **When** setup needs to write files that live outside
   `.claude/` (e.g. `scripts/dev.sh`), **Then** it still succeeds — see Story 2.

---

### User Story 2 - Project-tree files land correctly even though the plugin can't install them directly (Priority: P1)

A user who installed `webapp-uat` as a plugin needs `scripts/dev.sh` and
`uat/scenarios/_template.md` to exist in their project's own tree after running
setup — even though the plugin mechanism itself is only able to place files
under `.claude/`, and these two files are meant to live outside it.

**Why this priority**: Without this, a plugin install would be a broken,
partial install — the skill would reference files that don't exist. This is
the mechanism that actually makes Story 1's "no manual copying" claim true, not
just a slogan.

**Independent Test**: Can be fully tested by running setup in a target project
that has neither `scripts/dev.sh` nor `uat/scenarios/_template.md`, and
confirming both are created by copying the plugin's own bundled template
copies, with placeholders filled in `scripts/dev.sh`.

**Acceptance Scenarios**:

1. **Given** `scripts/dev.sh` does not already exist in the target repo,
   **When** setup writes files, **Then** it is copied from the plugin's own
   bundled `templates/dev.sh.template`, with its placeholders filled in from
   discovery.
2. **Given** `uat/scenarios/_template.md` does not already exist, **When**
   setup writes files, **Then** it is copied verbatim from the plugin's bundled
   `templates/_template.md` — this file has no placeholders to fill.
3. **Given** `scripts/dev.sh` already exists in the target repo (the
   manual-copy install case, not plugin), **When** setup writes files,
   **Then** its existing placeholders are filled in place — it is not
   overwritten from the bundled template.

---

### User Story 3 - Install failures are partial and safely re-runnable, never all-or-nothing (Priority: P2)

A user whose setup run fails partway through writing files (e.g. a permission
error creating one directory) needs everything that already succeeded to stay
exactly as written, and needs re-running setup afterward to retry only what
failed — not have to start over, and not have already-correct files silently
clobbered on retry.

**Why this priority**: Without this, one failed item (e.g. a permissions issue
on one directory) could either corrupt an otherwise-successful install by
rolling back what worked, or require throwing away and redoing successful work
on retry. Priority P2: refines Stories 1-2's write behavior for the failure
case, not independently valuable without them.

**Independent Test**: Can be fully tested by forcing one write step to fail
(e.g. a read-only directory), confirming every other item still wrote
successfully and is reported individually, then re-running setup and
confirming only the failed item is retried.

**Acceptance Scenarios**:

1. **Given** one item in the write step fails (e.g. permission denied), **When**
   the write step completes, **Then** every other item that succeeded remains
   exactly as written — not rolled back.
2. **Given** a write step just completed, **When** its outcome is reported,
   **Then** each item (`config.md`, `scripts/dev.sh`,
   `uat/scenarios/_template.md`, each `uat/` subdirectory) is reported
   individually with its own specific outcome — not a generic
   success/failure for the whole step.
3. **Given** setup is re-run after a partial failure, **When** it reaches the
   write step again, **Then** only the outstanding (failed or
   not-yet-attempted) items are retried — already-written items are left
   untouched.

---

### Edge Cases

- What happens when the bundled `templates/dev.sh.template` and the root
  `scripts/dev.sh` (used directly by this repo's own demo/dev workflow) drift
  out of sync over time, since they are two separate files by necessity (one
  lives inside the installable plugin folder, one is this repo's own working
  copy)? Not resolved by this feature automatically — this is a maintenance
  discipline documented as an open item (Assumptions), not an automated
  guarantee, since enforcing sync would need tooling this feature doesn't
  build.
- What happens when a target project already has `.claude/skills/webapp-uat/`
  from a prior manual copy, and the user then also adds the plugin? Not
  resolved by this feature — a project with both an existing manual copy and a
  plugin install of the same skill is a configuration conflict the user
  created, not something setup silently reconciles; Setup mode's own existing
  re-run behavior (diff current vs. proposed, per-field approval) is what
  would surface any resulting inconsistency, not a new mechanism.
- What happens when `/plugin install` succeeds but the target project's
  `.claude/skills/webapp-uat/templates/` directory is somehow missing or
  incomplete (a broken plugin cache)? Setup's file-copy step for the affected
  item fails and is reported individually, per Story 3 — not a special case
  beyond the existing best-effort, per-item failure handling.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A `.claude-plugin/marketplace.json` MUST exist at the repo root,
  declaring `webapp-uat` as a plugin whose skill source resolves to
  `.claude/skills/webapp-uat`.
- **FR-002**: After a plugin install, `/webapp-uat setup` MUST run and behave
  identically to a manually-copied install's setup flow — same
  discovery-assisted proposal, same propose→confirm→write pattern.
- **FR-003**: When `scripts/dev.sh` does not already exist in the target repo,
  setup MUST copy it from the plugin's bundled `templates/dev.sh.template` and
  fill in its placeholders from discovery.
- **FR-004**: When `uat/scenarios/_template.md` does not already exist, setup
  MUST copy it verbatim from the plugin's bundled `templates/_template.md`.
- **FR-005**: When `scripts/dev.sh` already exists in the target repo (the
  manual-copy case), setup MUST fill in its existing placeholders in place —
  MUST NOT overwrite it from the bundled template.
- **FR-006**: If one item in the write step fails, every other item that
  succeeded MUST remain exactly as written — MUST NOT be rolled back.
- **FR-007**: Every write-step item MUST be reported individually with its own
  specific outcome — MUST NOT be collapsed into one generic success/failure for
  the whole step.
- **FR-008**: Re-running setup after a partial failure MUST retry only the
  outstanding (failed or not-yet-attempted) items — MUST NOT re-touch
  already-written items.

### Key Entities

- **Plugin Marketplace Declaration**: `.claude-plugin/marketplace.json`,
  declaring `webapp-uat` as a git-sourced plugin pointing at
  `.claude/skills/webapp-uat`.
- **Bundled Template**: A copy of a project-tree file
  (`templates/dev.sh.template`, `templates/_template.md`) shipped inside the
  installable plugin folder specifically so setup can place it outside
  `.claude/` in a plugin-installed target project.
- **Write-Step Outcome**: The per-item result (written / already existed /
  failed, with a specific reason) reported for each file/directory setup
  attempts to create.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A scratch target project reaches a working `config.md`,
  `scripts/dev.sh`, and `uat/scenarios/_template.md` using only
  `/plugin marketplace add` + `/plugin install` + `/webapp-uat setup` — zero
  manual file copying at any point.
- **SC-002**: 100% of write-step items are reported individually, with a
  specific outcome, in 100% of setup runs.
- **SC-003**: A setup run with one forced item failure leaves 100% of the
  other, successful items unchanged, and a subsequent re-run retries only the
  failed item.

## Assumptions

- **The `/plugin` install flow itself is expected to land specified-but-not-
  live-verified**: `/plugin` is an interactive Claude Code CLI meta-command
  with no tool access available in this session — the actual
  marketplace-add/install flow needs real user or session testing. The
  `marketplace.json` schema and Setup mode's template-copy logic were already
  verified this session via direct `SKILL.md` reading and prior
  research-agent fact-checking against live Claude Code docs; that verification
  stands, but it is not the same claim as having actually run `/plugin` for
  real.
- **A `curl | sh` install script is explicitly out of scope**: two native
  Claude Code commands are the whole point of this feature; a third,
  non-native install mechanism isn't needed and isn't built.
- **Template/root-copy drift is a documented maintenance concern, not an
  automated guarantee**: `templates/dev.sh.template` and the root
  `scripts/dev.sh` are necessarily two separate files; keeping them in sync
  is a discipline this feature documents but does not enforce with tooling.
