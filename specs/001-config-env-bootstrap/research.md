# Research: Config & Environment Bootstrap

No `NEEDS CLARIFICATION` markers remained in the Technical Context after drafting —
this feature is small, well-precedented by `SKILL.md`'s existing Setup mode section,
and the one real ambiguity (write-step failure handling) was already resolved via
`/speckit-clarify` before planning began. This document records the resulting
technical decisions and why each was made, rather than open research questions.

## Decision: Treat this feature as an edit to existing agent instructions, not new application code

**Rationale**: `webapp-uat` is a Claude Code Skill — its "implementation" is the
Markdown operating instructions in `SKILL.md` that an agent follows when invoked, not
compiled or interpreted source code. Nearly the entirety of this feature's scope is
already written into `SKILL.md`'s Setup mode section (steps 1–7); this plan's actual
work is extending step 6 with the newly-clarified FR-013 failure-handling behavior,
not building a new mechanism.

**Alternatives considered**: Writing a wholly new, separate setup routine to house
the failure-handling behavior in isolation — rejected as a direct violation of
Constitution Principle V (Reuse Before Reinvention); there is no reason to duplicate
an already-correct, already-battle-tested six-step flow to add one new failure-path
clause to it.

## Decision: No automated test/type-check/lint runner applies in the traditional sense

**Rationale**: There is no source code to type-check or unit-test — `SKILL.md` is
prose that an LLM agent interprets at invocation time. The applicable automated
check is a Markdown lint pass over the edited section (catching broken structure,
heading-level mistakes, etc.), and the closest available equivalent to a test suite
is live invocation against constructed scenarios (see `quickstart.md`), since this
product's actual job elsewhere is exercising other projects this same way.

**Alternatives considered**: Skipping Constitution Principle VIII's gate entirely as
"not applicable" — rejected; the plan documents an explicit, honest interpretation
of the gate instead (Markdown lint + quickstart validation) rather than silently
treating a durable principle as inapplicable to this sub-project.

## Decision: Best-effort, per-item failure reporting (not atomic rollback) for the write step

**Rationale**: Already resolved via `/speckit-clarify` (Session 2026-08-15) and
recorded in `spec.md`'s Clarifications section and FR-013. Restated here because it's
the one genuinely new piece of behavior this plan introduces into `SKILL.md`: setup
is already required to be safely re-runnable (FR-012), so a full atomic-rollback
mechanism would add real implementation complexity for a rare, easily-recovered
failure mode (disk full, permissions) in a one-time local wizard.

**Alternatives considered**: Full atomic rollback (Option A) and fail-fast-no-rollback
(Option C) — both considered and rejected during the clarification session; see
`spec.md` for the full comparison.
