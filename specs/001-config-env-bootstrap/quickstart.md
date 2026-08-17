# Quickstart: Validating Config & Environment Bootstrap

Manual validation runbook for this feature — there is no automated test suite for
`SKILL.md` prose (see `research.md`'s Automated Quality Gates decision), so this
guide is the repeatable check referenced by the plan's Constitution Check.

Each scenario below maps to an acceptance scenario in [spec.md](./spec.md) — details
of expected behavior live there; this file is the runnable sequence, not a
restatement.

## Prerequisites

- The updated `SKILL.md` (with FR-013's failure-handling addition) installed at
  `.claude/skills/webapp-uat/` in a scratch test repo — not this repo itself, to
  avoid touching its real `config.md`.
- A handful of disposable fixture repos (can be `git init`-ed empty directories with
  specific files dropped in per scenario below).

## Scenario 1 — Fresh setup, most-specific-evidence detection (tier 1: `run.sh` + compose)

→ validates User Story 1, Acceptance Scenarios 1, 6

```bash
mkdir /tmp/wuat-fresh && cd /tmp/wuat-fresh && git init -q
printf 'services:\n  app:\n    build: .\n' > docker-compose.yml
printf '#!/bin/sh\necho starting\n' > run.sh && chmod +x run.sh
```
Run `/webapp-uat setup`. Expect: start command detected as `./run.sh`, stop as
`docker compose down`, both labeled **detected** with the file evidence named.
Approve the write. Expect: `config.md`, filled-in `scripts/dev.sh`, and the four
`uat/` subdirectories all created.

## Scenario 2 — Guessed port, no bug-fix tooling

→ validates User Story 1, Acceptance Scenarios 3, 5

Same fixture, no `.env`, no `.specify/` directory. Expect: port proposed as `3000`
labeled **guessed** (not detected); `bug-fix-mechanism` proposed as `direct`.

## Scenario 3 — Spec-Kit detected, commands not guessed

→ validates User Story 1, Acceptance Scenario 4

Add an empty `.specify/` directory to the fixture. Expect: `bug-fix-mechanism`
proposed as `spec-kit`, and the three command fields are **not** pre-filled — the
wizard surfaces `specify extension list`'s real output and asks which three entries
are correct.

## Scenario 4 — Cancel leaves nothing written

→ validates User Story 1, Acceptance Scenario 7

Run setup on a fresh fixture, choose Cancel at the decision step. Expect: no
`config.md`, no `scripts/dev.sh` changes, no new `uat/` directories.

## Scenario 5 — Write-step partial failure (FR-013, the clarified behavior)

→ validates User Story 1, Acceptance Scenario 8; Edge Cases (write-step failure)

```bash
mkdir /tmp/wuat-fail && cd /tmp/wuat-fail && git init -q
mkdir -p uat/fixtures && chmod 000 uat/fixtures   # force one item to fail
```
Run setup and approve the write. Expect: `config.md` and `scripts/dev.sh` (and the
other three `uat/` subdirectories) succeed and are reported as such; `uat/fixtures`
is reported as a named failure (permission denied), not a generic error. Restore
permissions (`chmod 755 uat/fixtures`) and re-run setup. Expect: the already-written
items are left as-is (not rewritten or duplicated), and only the previously-failed
item is retried successfully.

## Scenario 6 — Safe re-run against an existing config

→ validates User Story 2, all acceptance scenarios

Re-run setup against the fixture from Scenario 1. Expect: current values shown
alongside newly-proposed ones; declining a change leaves it untouched; approving a
specific change updates only that field in `config.md`.

## Scenario 7 — Ambiguous root, unrecognized project

→ validates User Story 3, Acceptance Scenarios 1–2

Install the skill inside a subdirectory of a repo containing another, unrelated git
repo one level up (a monorepo-nested-package shape), and separately, a fixture with
no `run.sh`/compose/`package.json`/`Makefile` at all. Expect: the root
question is asked outright in the first case; start/stop are left blank and labeled
**needs your input** (not guessed) in the second.

## Scenario 8 — Spec-dir detected

→ validates User Story 1 (spec-dir detection, positive path)

```bash
mkdir -p /tmp/wuat-specdir/specs/001-example && cd /tmp/wuat-specdir && git init -q
printf '# Feature Specification: Example\n' > specs/001-example/spec.md
```
Run `/webapp-uat setup`. Expect: `spec-dir` proposed as `specs/`, labeled
**detected**, with the specific evidence (the `specs/001-example/spec.md` file
found) named.

## Scenario 9 — Spec-dir absent

→ validates User Story 3, Acceptance Scenario 3

```bash
mkdir /tmp/wuat-no-specdir && cd /tmp/wuat-no-specdir && git init -q
```
Run `/webapp-uat setup` against a fixture with no `specs/` directory anywhere.
Expect: `spec-dir` is left unset — not defaulted to a guessed path — and the draft
explicitly notes that spec-derived generation and the UI-conformance check will
no-op without it.

## Scenario 10 — Start/stop detection, tier 2 (`package.json` dev script, no compose)

→ validates User Story 1, Acceptance Scenario 2

```bash
mkdir /tmp/wuat-pkg && cd /tmp/wuat-pkg && git init -q
printf '{"name":"x","scripts":{"dev":"vite"}}' > package.json
printf '{}' > package-lock.json
```
Run `/webapp-uat setup`. Expect: the start command is proposed as the equivalent run
command for the detected lockfile (`npm run dev` here), labeled **detected** — not
the tier-1 `run.sh`/compose path, since neither is present.

## Scenario 11 — Start/stop detection, tier 3 (`Makefile`, no compose, no `package.json`)

→ validates `spec.md` FR-002's third detection tier (no dedicated numbered
acceptance scenario in `spec.md` — this scenario exists to close the coverage gap
identified in `/speckit-analyze` finding E2). Originally used a `Procfile` fixture;
corrected during `/speckit-implement` to `Makefile` after finding a real `Procfile`
doesn't actually match this tier's detection criterion — see `docs/design-history.md`
D5.

```bash
mkdir /tmp/wuat-makefile && cd /tmp/wuat-makefile && git init -q
printf 'dev:\n\tnode server.js\n' > Makefile
```
Run `/webapp-uat setup`. Expect: the start command is proposed from the `Makefile`'s
recognizable `dev` target, labeled **detected**, since no `run.sh`+compose pair or
`package.json` dev/start script is present.

## Done when

All 11 scenarios produce the expected outcome above, matching the confidence-label
and write-outcome-report contracts in `contracts/setup-interaction-contract.md`.
