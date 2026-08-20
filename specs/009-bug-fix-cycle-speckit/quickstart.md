# Quickstart: Validating the Bug-Fix Cycle (Spec-Kit Mechanism)

**Live verification is explicitly blocked for this slice.** `demo-app`
deliberately uses `bug-fix-mechanism: direct` (see `docs/design-history.md` D6),
and no project in this repo's own tooling has a real Spec Kit bug-workflow
extension installed. This quickstart documents text-tracing against `SKILL.md`
plus a constructed example `config.md`, as the achievable completion evidence
for this slice — not a substitute for live verification, which remains an open
item for whoever next has access to a real installed extension.

Each scenario maps to acceptance scenarios in [spec.md](./spec.md).

## Constructed example `config.md` (for text-tracing only)

```
bug-fix-mechanism: spec-kit
bug-assess-command: /bug-assess
bug-fix-command: /bug-fix
bug-test-command: /bug-test
```

## Scenario 1 — The three configured commands run in order against a finding

→ validates User Story 1, all 4 acceptance scenarios (text-traced)

Trace `SKILL.md` Phase 4 step 2's spec-kit branch against a hypothetical BUG
finding under the constructed `config.md` above. Confirm the text specifies:
`<bug-assess-command>` runs first, producing a slug; `<bug-fix-command>` then
`<bug-test-command>` run with that slug, in that order; a completed cycle's
commit includes the tool's own records; multiple bugs from one scenario each
get their own cycle while sharing one restart/retest.

## Scenario 2 — High-risk and review-pause gates match the direct mechanism exactly

→ validates User Story 2, all 4 acceptance scenarios (text-traced)

Trace the spec-kit branch's pause-gate text against the direct mechanism's
(`specs/005-bug-fix-cycle-direct/`). Confirm: the high-risk pause's wording is
identical in trigger and unconditional nature; the routine review pause
presents `<bug-assess-command>`'s own artifact as-is, not a shape assumed to
match the direct mechanism's; `--silent` skips only the routine pause; a retry
re-applies both gates in full, no carried-forward approval.

## Scenario 3 — Retries reuse the assessment slug; tool failures are flagged, not hidden

→ validates User Story 3, all 4 acceptance scenarios (text-traced)

Trace the retry text to confirm it reuses the existing slug rather than
re-invoking `<bug-assess-command>`, and that the per-bug retry budget and
restart-failure threshold apply identically to spec-kit as they do to direct.
Separately, trace the tool-invocation-failure text to confirm a command failing
to execute is reported explicitly and pauses the run, and that the final report
distinguishes this from an ordinary unresolved bug or a restart-failure stop.

## Done when

All 3 scenarios (12 acceptance criteria total) are confirmed via text-tracing
against `SKILL.md` and the constructed example `config.md` above.

**Environment blocker resolved 2026-08-20; live run still open.** Spec Kit's
default extension catalog ships an installable bug-workflow extension:
`specify extension add bug` ("Bug Triage Workflow" v1.0.0, spec-kit-core).
Verified live in a scratch `specify init` project: it installs exactly three
Claude Code commands — `/speckit-bug-assess`, `/speckit-bug-fix`,
`/speckit-bug-test` (skills under `.claude/skills/`, backed by
`.specify/extensions/bug/commands/`) — matching the three `bug-*-command`
config keys one-to-one, so a real `config.md` for this mechanism is now:

```
bug-fix-mechanism: spec-kit
bug-assess-command: /speckit-bug-assess
bug-fix-command: /speckit-bug-fix
bug-test-command: /speckit-bug-test
```

What remains open is the actual Phase 4 delegation run: a full `/webapp-uat`
pass, in an interactive session with Chrome, against an app configured with
`bug-fix-mechanism: spec-kit` and the extension installed (e.g. `demo-app`
with a temporary spec-kit `config.md` — its committed config stays `direct`
per D6), producing a confirmed BUG finding and watching the three commands
run in order.
