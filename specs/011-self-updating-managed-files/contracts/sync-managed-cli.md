# Contract: `sync-managed.sh`

Location (bundled): `<skill folder>/scripts/sync-managed.sh`, addressed from the
skill as `${CLAUDE_SKILL_DIR}/scripts/sync-managed.sh`.

## Usage

```
bash sync-managed.sh [<project-root>] --check
bash sync-managed.sh [<project-root>] --apply
bash sync-managed.sh [<project-root>] --legacy-values
bash sync-managed.sh --print <bundled path>
```

- `<project-root>` optional. When absent: `git rev-parse --show-toplevel` from the
  current directory, else the current directory.
- The skill folder is derived from the script's own location (`../` from
  `scripts/`), never from the project.
- Bash 3.2 compatible. Uses only `bash`, `git`, `cmp`, `grep`, `head`, `cp`, `mkdir`, `chmod`.

## `--check`

Prints, in this order, one line per managed file then the values-file line:

```
<status><padding><project path>
values-file       scripts/dev.env  <present|missing>
```

`<status>` ∈ `in-sync` | `update-available` | `missing` | `unmanaged` | `legacy`,
left-aligned in an 18-character column. **Exit code is always 0**, including when the
project root cannot be determined or a bundled file is absent — in those cases the
output is a single line beginning `managed-files: cannot check (` and a reason `)`.
Writes nothing.

## `--apply`

For each managed file, prints one line with the action taken:

```
updated           <project path>        # was update-available
created           <project path>        # was missing (parent dir created)
in-sync           <project path>
skipped-unmanaged <project path>
skipped-legacy    <project path>
values-file       scripts/dev.env  <present|missing>
changed: <N>
changed-paths: <space-separated project paths, or empty>
```

Copies preserve the executable bit of the bundled file (`scripts/dev.sh` stays
executable). Never writes anything not in the managed table. Exit 0 on success
(including `changed: 0`); exit 2 if a copy fails (message on stderr names the path).

## `--legacy-values`

Requires `scripts/dev.sh` to be `legacy`; otherwise prints
`not-legacy` and exits 3. Otherwise prints bash-sourceable lines suitable for
`scripts/dev.env`, single-quoted, in this fixed order and only for keys found:

```
START_COMMAND='<value>'
STOP_COMMAND='<value>'
PORT='<value>'
WAIT_TIMEOUT='<value>'
```

`PROJECT_DIR` is never printed. Extraction evaluates only the matching assignment
lines in a subshell; nothing else in the legacy file runs. Exit 0.

## `--print <bundled path>`

Prints the named file from the skill folder (relative path; absolute paths and any
`..` segment are rejected with usage, exit 2; a missing file exits 2 with a message
on stderr). Exists because, for a plugin install, the skill folder is outside the
project and Claude Code blocks direct reads there (`Read`, `cat`) while executing
the pre-authorized bundled script is allowed — found during live verification
(2026-09-07). Used for `USAGE.md` (`--help`), `vendor/axe.min.js`, and
`templates/dev.env.example`.

## Usage errors

Unknown or missing mode: prints usage to stderr, exit 2.

## Marker detection (shared with `--check`/`--apply`)

Literal phrase `webapp-uat managed file` present in the first three lines
(`head -3 <file> | grep -q 'webapp-uat managed file'`).

## Legacy detection

`scripts/dev.sh` exists, marker absent, and both `grep -q '^START_COMMAND='` and
`grep -q '^PORT='` succeed.
