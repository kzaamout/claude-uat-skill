# Data Model: Config & Environment Bootstrap

Files, not database rows — this feature's "data model" is the shape of the artifacts
it reads and writes on the target project's filesystem. Documented here for the same
reason a database schema would be: so downstream work (tasks, tests) has one
authoritative reference instead of re-deriving field names from prose each time.

## Configuration Draft

The consolidated, in-memory proposal presented for review before anything is written
(spec `FR-007`). Not persisted anywhere itself — it exists only for the duration of
one setup invocation, until the user approves, edits, or cancels it.

| Field | Confidence label | Detected from (when applicable) |
|---|---|---|
| `project-name` | needs-your-input | never auto-detected — always asked |
| `project-dir` | detected | the resolved repo root (spec `FR-001`) |
| start command | detected / guessed / needs-your-input | `run.sh`/`start.sh` + compose, else `package.json` script, else `Makefile` (spec `FR-002`; `Procfile` detection dropped — see `docs/design-history.md` D5) |
| stop command | detected / needs-your-input | paired with the detected start mechanism |
| port | detected / guessed | `.env`/`.env.example`, dev-server config, or compose port mapping; else guessed `3000` (spec `FR-003`) |
| `bug-fix-mechanism` | detected / guessed | `.specify/` directory or `specify` on `PATH` → `spec-kit`; else `direct` (spec `FR-004`) |
| `bug-assess-command` / `bug-fix-command` / `bug-test-command` | needs-your-input (when mechanism is `spec-kit`) | never guessed — surfaced from `specify extension list`'s real output (spec `FR-005`) |
| `spec-dir` | detected / unset | a `specs/`-shaped directory containing spec files; left unset otherwise (spec `FR-006`) |
| `review-before-fix` | not part of this draft | out of this feature's scope — defaults in `config.md.example`, not detected here |

**Validation rule**: every field above MUST carry exactly one of the three confidence
labels (spec `FR-007`) before the draft is ever presented — no field is shown
unlabeled or blended in with a different confidence level.

## Project Configuration (`config.md`)

The persisted result of an approved draft. Schema already fully defined by the
existing `config.md.example` — this feature is a *writer* of this shape, not the
owner of its definition. Fields: `project-name`, `project-dir`, `bug-fix-mechanism`
(+ its three command fields when `spec-kit`), `spec-dir` (optional),
`review-before-fix`, `backend-stores` (optional). No schema change from this feature.

**State transitions**: `absent` → `written` (User Story 1) → `re-reviewed, partially
or fully updated` (User Story 2, repeatable indefinitely). There is no `deleted`
state — this feature never removes a `config.md`.

## Start/Stop/Health-Check Wiring (`scripts/dev.sh`)

The project-specific script whose placeholders (`PROJECT_DIR`, `START_COMMAND`,
`STOP_COMMAND`, `PORT`) this feature fills in from the approved draft. This feature
edits the placeholder values only — it does not change the script's logic, and does
not execute `start`/`stop`/`wait-ready` itself (spec `FR-010`).

## Write Outcome (new, from FR-013)

Not a persisted entity — the per-invocation result of the write step, used only to
drive the failure report the user sees.

| Field | Meaning |
|---|---|
| item | which artifact was being written (`config.md`, `scripts/dev.sh`, or one of the four `uat/` subdirectories) |
| result | `succeeded` or `failed` |
| reason (if failed) | the specific, named cause — never a generic "write failed" |

**Rule** (spec `FR-013`): a `failed` item never rolls back an already-`succeeded` one;
the invocation is safe to re-run afterward to retry only what's outstanding.
