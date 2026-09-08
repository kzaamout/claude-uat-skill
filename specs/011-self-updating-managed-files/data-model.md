# Data Model: Self-Updating Managed Files

No database. The "data" is a fixed table of files and a per-file status.

## Managed-file table (the source of truth, inside `sync-managed.sh`)

| Bundled source (in the skill folder) | Project path | Marker form |
|---|---|---|
| `templates/dev.sh` | `scripts/dev.sh` | line 2, `# webapp-uat managed file -- ...` (line 1 is the shebang) |
| `templates/_template.md` | `uat/scenarios/_template.md` | line 1, `<!-- webapp-uat managed file -- ... -->` |

Adding a managed file = adding a row and putting the marker in the bundled copy.

## Entities

### Managed file
- **project_path** — relative to the project root.
- **bundled_path** — relative to the skill folder.
- **marker_present** — literal phrase `webapp-uat managed file` found in the first
  three lines of the project copy.
- **status** — derived, see below.

### Values file — `scripts/dev.env`
Project-owned, committed, bash-sourceable `KEY=value` lines. Never written by
`--apply`; written only by Setup (proposal → confirmation) or the legacy migration
(proposal → confirmation).

| Key | Required | Default | Meaning |
|---|---|---|---|
| `START_COMMAND` | yes | — | Brings the app up; run from the project root, backgrounded, output to `dev.log` |
| `STOP_COMMAND` | no | (none) | Extra teardown after SIGINT to the start process and its children |
| `PORT` | yes, unless `READY_COMMAND` set | — | `wait-ready` polls `http://localhost:$PORT` |
| `WAIT_TIMEOUT` | no | 30 | Seconds `wait-ready` polls (one check per second); a per-run env var still wins |
| `READY_COMMAND` | no | (none) | Replaces the port poll; `wait-ready` succeeds when it exits 0 |

Unknown keys are ignored (the file is sourced). Validation happens in the engine at
run time (FR-004), not in the sync script.

### Legacy wrapper
A `scripts/dev.sh` with **no marker** and with both a `START_COMMAND=` and a `PORT=`
assignment line. Carries the old four values. Treated as *unmanaged* by every
automatic step; eligible for one-time migration.

### Sync report
One line per managed file: `<status><spaces><project path>`, followed by one line
for the values file, and — in `--apply` — a `changed: N` summary and a
`changed-paths:` line. Format is fixed (see `contracts/sync-managed-cli.md`) so
both a human and Claude can read it without parsing prose.

## Managed-file status (per file)

| Status | Definition | `--apply` action |
|---|---|---|
| `in-sync` | Project copy exists, marker present, byte-identical to bundled | none |
| `update-available` | Project copy exists, marker present, differs from bundled | overwrite (reports `updated`) |
| `missing` | No project copy | copy in (reports `created`) |
| `unmanaged` | Project copy exists, marker absent, not legacy | none (reports `skipped-unmanaged`) |
| `legacy` | `scripts/dev.sh` only: marker absent, old four-value block present | none (reports `skipped-legacy`) |

Values-file line: `values-file  scripts/dev.env  present` or `... missing`.

## State transitions

```text
missing ──(--apply / setup)──▶ in-sync
in-sync ──(skill updated; bundled copy changes)──▶ update-available ──(--apply)──▶ in-sync
in-sync | update-available ──(user removes marker)──▶ unmanaged
unmanaged ──(setup re-adoption, confirmed)──▶ in-sync
legacy ──(migration, confirmed: dev.env written + engine copied)──▶ in-sync
legacy ──(--silent, or migration declined)──▶ legacy  (still works; reported)
```

## Invariants

- No automatic step ever writes a file that is not a marker-bearing or missing
  managed file. In particular `scripts/dev.env`, `config.md`,
  `discovered-environment.md`, scenarios other than the template, fixtures, and
  `uat/runs/`/`uat/artifacts/` are never touched by `--apply` or by Phase 0's
  managed-files step.
- The Phase 0 commit contains only paths listed on the `changed-paths:` line.
- The engine (`scripts/dev.sh`) contains no project-specific literal. Its only
  inputs are `scripts/dev.env` and the process environment.
- Root reference copies in this repo are byte-identical to the bundled copies
  (`check-sync.sh`).
