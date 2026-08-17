# Research: One-Command Install

No `NEEDS CLARIFICATION` markers remained in the Technical Context, and
`/speckit-clarify` found zero critical ambiguities — this feature retroactively
formalizes already-built, already-committed work rather than designing new
scope.

## Decision: No `SKILL.md` or `marketplace.json` edit — this is a
verification-only plan, unlike every prior slice this session

**Rationale**: Re-reading `marketplace.json` and `SKILL.md`'s Setup mode step 6
against every FR in `spec.md` found all 8 FRs already satisfied, several
verbatim: `marketplace.json`'s `source`/`skills` fields already resolve to
`.claude/skills/webapp-uat` exactly as FR-001 requires; step 6's text already
states the bundled-template-copy behavior (FR-003/004), the
existing-file-fills-in-place behavior (FR-005), and the
best-effort/per-item-reporting/safe-re-run behavior (FR-006/007/008) nearly
word-for-word against this spec's own phrasing. This is because the work was
built directly in an earlier session, before this session adopted the practice
of running every roadmap slice through the full Spec Kit cycle. This plan's
purpose is to give that already-correct work a written spec it never had,
confirm nothing has drifted since, and let `/speckit-analyze` verify the
zero-gap expectation before `/speckit-implement` runs as a no-op.

**Alternatives considered**: Skipping the full cycle for this slice, since no
edit is expected — rejected; Constitution Principle I (Written Requirements Are
the Source of Truth) applies exactly here — this feature was implemented before
it had a written spec, which is itself the gap this cycle closes, independent
of whether the *code* (agent instructions) needs to change.

## Decision: `/plugin` install-flow verification stays explicitly blocked, same
limitation pattern as `UAT-09`

**Rationale**: `/plugin marketplace add` and `/plugin install` are interactive
Claude Code CLI meta-commands with no tool access available in this session —
identical in kind to `UAT-09`'s Spec Kit bug-workflow extension limitation.
Text-tracing against `SKILL.md` and `marketplace.json`, verified in a prior
session's research-agent pass against live Claude Code docs, is the achievable
completion evidence; the actual install flow needs real user or session
testing.

**Alternatives considered**: Attempting to simulate `/plugin`'s behavior by
manual file inspection alone and calling that "verified" — rejected, since it
would overstate what's actually been confirmed, the same reasoning `UAT-09`'s
Assumptions section already applied to its own external-tool dependency.

## Decision: Template/root-copy drift stays a documented concern, not
automated

**Rationale**: `templates/dev.sh.template` (inside the installable plugin
folder) and the root `scripts/dev.sh` (this repo's own working demo/dev
workflow, and what `demo-app`'s bundled scenarios point at) are necessarily two
separate files — a plugin install cannot place files outside `.claude/`, so the
bundled copy has to exist independently. Building drift-detection tooling
(e.g. a CI diff check) is out of scope for this feature; the Edge Cases section
documents this honestly rather than implying an automated guarantee that
doesn't exist.

**Alternatives considered**: Symlinking the two files — rejected, since a
symlink into `.claude/skills/webapp-uat/templates/` from outside it would
itself not survive a plugin's cache-based install mechanism, and this repo
needs `scripts/dev.sh` to work as a normal file for its own direct use
regardless of plugin packaging.

## Decision: No automated test/type-check/lint runner applies, same as prior
features

**Rationale**: No compiled source. Markdown/JSON structural review plus
`quickstart.md`'s text-traced scenarios stand in for the constitution's
Principle VIII gate, within the stated `/plugin`-verification limitation.
