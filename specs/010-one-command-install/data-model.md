# Data Model: One-Command Install

Process/state conventions, not a schema this feature owns.

## Plugin Marketplace Declaration

`.claude-plugin/marketplace.json`, repo root.

| Field | Notes |
|---|---|
| `name` | `webapp-uat-marketplace` |
| `plugins[0].name` | `webapp-uat` |
| `plugins[0].source` | `./.claude/skills/webapp-uat` — the skill folder itself, so an install copies only it (was `./`, the whole repo, until 2026-09-28; D7 payload correction) |
| `plugins[0].skills` | `["./"]` — the plugin root is the skill folder, no duplication (`FR-001`); was `["./.claude/skills/webapp-uat"]` relative to the repo root until 2026-09-28 |
| `plugins[0].strict` | *(removed 2026-09-28, D14/D7 correction: inert without a `plugin.json`, a load failure with one; was `false`)* |

## Bundled Template

A copy of a project-tree file shipped inside the installable plugin folder,
specifically so Setup mode can place it outside `.claude/` even though a
plugin install itself can't.

| File | Copied from | Target | Placeholder handling |
|---|---|---|---|
| `scripts/dev.sh` | `.claude/skills/webapp-uat/templates/dev.sh.template` | repo root `scripts/dev.sh` | filled in from discovery when copied fresh (`FR-003`); filled in place, not overwritten, when the file already exists (`FR-005`) |
| `uat/scenarios/_template.md` | `.claude/skills/webapp-uat/templates/_template.md` | repo root `uat/scenarios/_template.md` | verbatim copy, no placeholders (`FR-004`) |

## Write-Step Outcome

The per-item result reported for each file/directory Setup mode's write step
attempts to create.

| Field | Notes |
|---|---|
| granularity | one line per item — `config.md`, `scripts/dev.sh`, `uat/scenarios/_template.md`, each `uat/` subdirectory (`FR-007`) |
| values | `written` / `written (from bundled template)` / `already existed, left as-is` / `created` / `FAILED — <specific reason>` |
| atomicity | best-effort, not atomic — a failed item does not roll back items that already succeeded (`FR-006`) |
| re-run behavior | retries only outstanding (failed or not-yet-attempted) items; already-written items untouched (`FR-008`) |
