# Contract: the managed-file marker

## Phrase

The literal phrase **`webapp-uat managed file`** is the detection key. The full
marker line is:

```
webapp-uat managed file -- do not edit; overwritten on skill update; remove this line to take ownership
```

## Placement by file type

| File | Form | Line |
|---|---|---|
| `scripts/dev.sh` | `# webapp-uat managed file -- …` | 2 (line 1 is `#!/usr/bin/env bash`) |
| `uat/scenarios/_template.md` | `<!-- webapp-uat managed file -- … -->` | 1 |

## Detection rule

Present ⇔ the phrase occurs anywhere in the first three lines of the project copy.
Nothing else about the file is inspected for this decision.

## Semantics

- Present → the skill may overwrite the file with its bundled copy, without asking,
  whenever the two differ. The marker's own text says so.
- Absent → the skill never writes the file automatically. It reports the file as
  `unmanaged` (or `legacy`, for a pre-marker wrapper) once per run and tells the
  user that Setup can re-adopt it, with confirmation.
- Bundled copies always carry the marker; a bundled copy without it is a bug
  (`test-sync-managed.sh` asserts this).
