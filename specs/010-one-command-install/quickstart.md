# Quickstart: Validating One-Command Install

**The `/plugin` portion is explicitly blocked for live verification in this
session.** `/plugin marketplace add` and `/plugin install` are interactive
Claude Code CLI meta-commands with no tool access available here — the same
limitation kind as `UAT-09`'s Spec Kit bug-workflow extension. This quickstart
documents text-tracing against `SKILL.md`/`marketplace.json`, the achievable
completion evidence for this slice; live verification of the actual `/plugin`
flow remains an open item for the user or a fresh session with real access.

Each scenario maps to acceptance scenarios in [spec.md](./spec.md).

## Scenario 1 — Two commands install the skill, no manual copying

→ validates User Story 1, all 3 acceptance scenarios (text-traced)

Trace `marketplace.json`'s `source`/`skills` fields against `FR-001` — confirm
they resolve to `.claude/skills/webapp-uat` directly. Trace `SKILL.md`'s Setup
mode steps 1-5 — confirm nothing in the discovery/proposal flow branches on
install method. **Live check (blocked)**: `/plugin marketplace add
kzaamout/claude-uat-skill` + `/plugin install webapp-uat@webapp-uat-marketplace`
+ `/webapp-uat setup` from a scratch target project.

## Scenario 2 — Project-tree files land correctly despite the plugin's `.claude/`-only limitation

→ validates User Story 2, all 3 acceptance scenarios (text-traced)

Trace `SKILL.md` Setup mode step 6 against `FR-003`/`FR-004`/`FR-005` — confirm
the bundled-template-copy-when-missing and fill-in-place-when-existing
behaviors are both stated. Confirm `templates/dev.sh.template` and
`templates/_template.md` both exist under
`.claude/skills/webapp-uat/templates/` (already verified present in this
repo). **Live check (blocked)**: run setup against a target repo with neither
file present, confirm both are created correctly.

## Scenario 3 — Partial failures don't roll back, and re-runs are safe

→ validates User Story 3, all 3 acceptance scenarios (text-traced)

Trace step 6's "best-effort, not atomic" text against `FR-006`/`FR-007`/`FR-008`
— confirm per-item reporting, no-rollback, and outstanding-only-retry are all
stated, matching the worked example in `SKILL.md` itself. **Live check
(blocked)**: force one item to fail (e.g. a read-only `uat/fixtures/`
directory), confirm the other items still wrote successfully and are reported
individually, then re-run and confirm only the failed item retries.

## Done when

All 3 scenarios (9 acceptance criteria total) are confirmed via text-tracing
against `SKILL.md` and `marketplace.json`, as documented above — **already
achieved**, since every FR already matched existing text exactly (see
`plan.md`'s Summary).

**Live verification: achieved 2026-08-20.** The blocker dissolved: `/plugin` is
interactive, but the `claude plugin` CLI is not, and it drives the identical
flow. Evidence, per scenario, all against a scratch target repo:

- **Scenario 1**: `claude plugin marketplace add kzaamout/claude-uat-skill`
  cloned and validated the real GitHub repo; `claude plugin install
  webapp-uat@webapp-uat-marketplace --scope project` succeeded, wrote the
  `enabledPlugins` entry to the target's `.claude/settings.json`, and
  `claude plugin details` resolved the plugin to exactly one skill
  (`webapp-uat`, ~124 always-on tokens). A headless `/webapp-uat setup` run
  then executed the full discovery→propose→write flow.
- **Scenario 2**: setup copied `scripts/dev.sh` (placeholders filled from
  detected values; port guess labeled as a guess) and
  `uat/scenarios/_template.md` (byte-identical to the bundled template, md5
  verified) into the target's own tree, created the four `uat/`
  subdirectories, and created `.gitignore` with both runtime entries.
- **Scenario 3**: a naturally occurring per-item failure (the headless
  session's permission gate blocked one write while the others succeeded)
  exercised the best-effort/no-rollback path — succeeded items stayed in
  place, the failure was named per-item, and a re-run retried only the
  outstanding items, leaving already-written files untouched (mtime-verified).

One real defect was found and fixed in the same session — setup tried to write
`config.md` into the plugin cache instead of the project tree, a gap
text-tracing structurally could not catch — recorded as
`docs/design-history.md` D12. **Remaining caveat**: the interactive `/plugin`
slash-command wrapper itself was not exercised (it invokes the same
marketplace/install machinery the CLI just verified); a user running the two
README commands interactively is the trivial confirmation left.
