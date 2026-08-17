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
`plan.md`'s Summary). **Live verification of the actual `/plugin` install flow
remains blocked** — tracked explicitly as an open item, not silently treated
as done, pending a user or fresh session with real `/plugin` access.
