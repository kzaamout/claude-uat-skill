# Contract: Setup mode's plugin-install template copy

The process contract for how Setup mode gets project-tree files into a
plugin-installed target repo despite the plugin mechanism itself being unable
to place files outside `.claude/` — not a network API.

## 1. Marketplace declaration

**Trigger**: a user runs `/plugin marketplace add kzaamout/claude-uat-skill`
then `/plugin install webapp-uat@webapp-uat-marketplace`.

**MUST**: `.claude-plugin/marketplace.json` declare `webapp-uat`'s skill source
as `.claude/skills/webapp-uat`, so the installed plugin resolves to the
existing skill folder without duplication (`FR-001`).

## 2. Setup flow parity

**Trigger**: `/webapp-uat setup` runs after a plugin install.

**MUST**: behave identically to a manually-copied install's setup flow —
same discovery-assisted proposal (steps 1-5), same propose→confirm→write
pattern — regardless of install method (`FR-002`).

## 3. Project-tree file placement

**Trigger**: setup reaches its write step, on approval.

**MUST**, when `scripts/dev.sh` does not already exist in the target repo: copy
it from the plugin's bundled `templates/dev.sh.template`, then fill in its
placeholders from discovery (`FR-003`).

**MUST**, when `uat/scenarios/_template.md` does not already exist: copy it
verbatim from the plugin's bundled `templates/_template.md` (`FR-004`).

**MUST**, when `scripts/dev.sh` already exists (the manual-copy case): fill in
its existing placeholders in place — MUST NOT overwrite it from the bundled
template (`FR-005`).

## 4. Failure handling

**Trigger**: one item in the write step fails.

**MUST**: leave every other, already-successful item exactly as written — MUST
NOT roll back (`FR-006`). **MUST**: report every item individually, with its
own specific outcome — MUST NOT collapse into one generic success/failure
(`FR-007`).

**Trigger**: setup is re-run after a partial failure.

**MUST**: retry only the outstanding (failed or not-yet-attempted) items —
MUST NOT re-touch already-written items (`FR-008`).
