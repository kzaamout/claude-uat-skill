# Research: Bug-Fix Cycle (Spec-Kit Mechanism)

No `NEEDS CLARIFICATION` markers remained in the Technical Context, and
`/speckit-clarify` found zero critical ambiguities — this feature formalizes
already-deliberate, already-written `SKILL.md` Phase 4 spec-kit branch text
(plus Phase 5's report), most of which already correctly reuses `UAT-04`'s
shared cycle structure rather than duplicating it.

## Decision: Four targeted additions, most FRs already present via shared
structure

**Rationale**: Re-reading the current text against every FR in `spec.md` found
FR-001/002/003/005/006/007/009/010 already present, several verbatim — because
Phase 4's batching (step 1), restart-failure threshold (step 3), retry-budget
and pause-gate re-triggering (step 5), and per-bug commit granularity (step 6)
are all written once, outside the per-mechanism branch, and already apply
identically to `direct` and `spec-kit`. This is the correct architecture per
Constitution Principle V — confirmed by direct re-reading, not assumed from the
feature description's premise that the spec-kit branch was "unwritten/minimal."
Four real gaps: (1) FR-004 — the spec-kit branch's review-pause bullet
currently copies the direct mechanism's literal "summary, proposed fix,
affected files" phrasing, incorrectly implying the external tool's assessment
output is guaranteed that shape; (2) FR-008 — no stated retry-assessment-reuse
behavior specific to spec-kit; (3) FR-011/FR-012 — no tool-invocation-failure
handling at all, and Phase 5's existing two-way distinction (restart-threshold
vs. retry-exhausted, from `UAT-04`'s FR-013) doesn't yet know about this third
mode; (4) FR-013 — no stated behavior for a `<bug-test-command>`-vs-browser-
retest discrepancy.

**Alternatives considered**: Writing an entirely separate "spec-kit cycle"
section rather than editing the existing shared-structure architecture —
rejected per Constitution Principle V; the existing design (shared steps,
per-mechanism branch only where behavior genuinely differs) is sound and this
feature's job is closing its remaining gaps, not replacing it.

## Decision: Present the external tool's assessment artifact as-is, don't
require a specific shape

**Rationale**: The direct mechanism's assessment is guaranteed to have a
summary/proposed-fix/affected-files shape because Claude writes it in-session
to that shape deliberately. A Spec Kit bug-workflow extension is a black box
from this skill's perspective — its `<bug-assess-command>` might produce a
Markdown file, a structured JSON blob, a terminal summary, or something else
entirely, depending on which tool a given team has adopted. Requiring a
specific shape here would either be wrong for most real tools or require this
skill to reshape output it doesn't control. The review pause presents whatever
the tool actually produced.

**Alternatives considered**: Defining a minimal required shape (e.g. "must
include at least a one-line summary") that `<bug-assess-command>`'s output must
conform to — rejected as scope creep into constraining a target project's own
tooling choice, which this feature has no authority over and the constitution's
Principle VII (Deliberate Dependencies) treats as the adopting team's decision,
not this skill's to impose requirements on.

## Decision: A retry reuses the existing assessment slug, doesn't re-assess

**Rationale**: A retry happens because the *fix* didn't hold up under browser
retest — the underlying finding and its assessment haven't changed, only the
attempted fix did. Re-running `<bug-assess-command>` on an unchanged finding
would either produce an identical assessment (wasted tool invocation) or, if the
tool is non-deterministic, a *different* slug/assessment for the same
underlying problem — fragmenting what should be one bug's history across
multiple tool-side records. Reusing the slug keeps the bug-workflow tool's own
audit trail coherent across retries.

**Alternatives considered**: Re-running the full assess/fix/test sequence on
every retry — rejected, since it discards the assessment's already-correct
diagnosis to solve a problem (the fix not holding) that assessment isn't
responsible for.

## Decision: Tool-invocation failure is its own distinct, explicitly-reported
failure mode

**Rationale**: `UAT-04`'s spec already established that a restart-failure-
threshold stop and a retry-budget-exhausted unresolved bug must never be
conflated under one undivided "unresolved" label (its own FR-013). This
feature's tool-invocation failure is a third, genuinely distinct mode — the
*command itself* didn't run, which says nothing about whether the bug is hard
to fix (retry-exhausted) or the app environment is breaking (restart-failure).
Silently treating a command-not-found or non-zero-exit as if the bug were
resolved (or as an ordinary unresolved bug) would misreport what actually
happened and could mask a broken team-tooling setup as a webapp-uat/app
problem.

**Alternatives considered**: Folding tool-invocation failure into the existing
restart-failure-threshold category, since both represent "something outside the
bug itself broke" — rejected, since a restart failure is specifically about the
app's own `scripts/dev.sh` mechanism, and conflating it with the target
project's *bug-workflow tool* failing would misattribute the actual point of
failure when someone reads the final report later.

## Decision: No automated test/type-check/lint runner applies, same as prior
features

**Rationale**: No compiled source. Markdown lint stands in for the
constitution's Principle VIII gate; `quickstart.md`'s scenarios are
text-tracing only given the stated live-verification limitation.
