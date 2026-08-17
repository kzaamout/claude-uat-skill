# Research: Manual Scenario Execution, Checks, Classification & Report

No `NEEDS CLARIFICATION` markers remained in the Technical Context — this feature is
well-precedented by `SKILL.md`'s existing Phase 1/2/3/5 sections, and the one real
ambiguity (app-crash vs. `TEST_ENVIRONMENT` classification) was already resolved via
`/speckit-clarify` before planning began. This document records the resulting
technical decisions, same shape as `UAT-01`'s `research.md`.

## Decision: Treat this feature as a verification-and-one-real-fix pass, not new logic

**Rationale**: As with `UAT-01`, `webapp-uat`'s "implementation" is the Markdown
operating instructions in `SKILL.md`. Phase 1 (scenario review), Phase 2 (execution,
minus backend verification), Phase 3 (classification), and Phase 5 (final report)
already fully specify this feature's scope. The only genuinely new text this plan
introduces is Phase 3's `TEST_ENVIRONMENT`-vs-app-crash disambiguation.

**Alternatives considered**: Rewriting Phase 1-5 from scratch to match the spec
one-to-one — rejected as a direct violation of Constitution Principle V (Reuse Before
Reinvention); there is no reason to duplicate already-correct, already-battle-tested
phases to add one classification clarification.

## Decision: No automated test/type-check/lint runner applies, same as `UAT-01`

**Rationale**: No source code to type-check or unit-test. The applicable automated
check is a Markdown lint pass over the edited section, and the closest equivalent to
a test suite is live invocation against constructed scenarios (see `quickstart.md`).

## Decision: App-crash-vs-`TEST_ENVIRONMENT` disambiguation (FR-009a)

**Rationale**: Already resolved via `/speckit-clarify` (Session 2026-08-16) and
recorded in `spec.md`'s Clarifications section. Restated here because it's the one
genuinely new piece of behavior this plan introduces into `SKILL.md`: an app crash is
a product failure and should be surfaced as a `BUG` a user will actually see and act
on, not filed into `TEST_ENVIRONMENT` where it would get comparatively little
attention and never reach Phase 4's (future) fix cycle.

**Alternatives considered**: Classifying all app-level unresponsiveness as
`TEST_ENVIRONMENT` (Option A), and a cause-dependent split based on prior restart
history (Option C) — both considered and rejected during the clarification session;
see `spec.md` for the full comparison.
