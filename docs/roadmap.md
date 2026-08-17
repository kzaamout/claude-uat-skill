# webapp-uat — Product Implementation Roadmap

Decomposes **webapp-uat** (this repo's actual product) into independently demonstrable
vertical slices. Two things deliberately excluded from the slice list below: (1) the
README overhaul, demo recording, and LinkedIn draft — these are supporting
deliverables, not independently demonstrable product capability, so they don't belong
in a capability decomposition; (2) "Relevant Claude Design screens" is `None` on every
slice — no Claude Design project exists for this product.

Each slice's **Status** reflects what's actually been verified, not assumed. Most of
this product's core behavior already exists as written instructions in `SKILL.md` —
there's no separate "build" phase the way a typical app has one, since the skill *is*
its spec. "Specified" is not the same claim as "formalized via Spec Kit" or "live-
verified end-to-end" — each status line is explicit about which of those has actually
happened.

---

### UAT-01 — Config & Environment Bootstrap
**Status: Done.** Formalized via Spec Kit (`specs/001-config-env-bootstrap/`), fully
implemented and converged.

- **User outcome**: Point the skill at a repo and get a working `config.md` + verified
  start/stop/health-check, without hunting down values by hand.
- **Scope included**: repo-root detection; start/stop/port detection
  (most-specific-evidence rule); bug-fix-mechanism detection (`spec-kit` vs `direct`);
  `spec-dir` detection; detected/guessed/needs-input labeling; propose→confirm→write;
  safe re-run against an existing `config.md`.
- **Scope explicitly deferred**: actually running `scripts/dev.sh start/stop/wait-ready`
  during setup itself (stays a manual Phase 0 step by design); config-schema
  validation beyond existence (see UAT-03).
- **Dependencies**: none — foundational.
- **Relevant specification sources**: `SKILL.md` "Setup mode" section (steps 1–7);
  `SETUP.md`; `config.md.example`.

---

### UAT-02 — Manual Scenario Execution, Checks, Classification & Report
**Status: Done.** Formalized via Spec Kit
(`specs/002-scenario-execution-reporting/`), fully implemented and converged.

- **User outcome**: Run one hand-written scenario in a real Chrome window and get
  accessibility/data-integrity findings, a category+severity classification, and a
  written report — the smallest slice that proves the core value loop without fixing
  anything.
- **Scope included**: Phase 1 scenario review; Phase 2 execution (login, viewport
  handling, axe-core audit, i18n/data-integrity checks, console/network/screenshot
  capture on anything that looks off); Phase 3 five-way classification + P0–P3
  severity; Phase 5 report (scenario/finding breakdown only — spec-update disposition
  and backend verification excluded, see UAT-05).
- **Scope explicitly deferred**: backend verification (UAT-05); bug-fix cycle
  (UAT-04/UAT-09); generation (UAT-07/UAT-08); resumability/gap promotion (UAT-10).
- **Dependencies**: UAT-01.
- **Relevant specification sources**: `SKILL.md` Phase 1, Phase 2 (steps 1–6, 8–10),
  Phase 3, Phase 5 (report structure only); `docs/design-history.md` R3, R5;
  `uat/scenarios/_template.md`.

---

### UAT-03 — Invocation Parsing & Flag Semantics
**Status: Done.** Fixed directly (not a full Spec Kit cycle — the confirmed `--help`
bug and related Phase 1 correctness fixes were resolved as targeted edits, per the
user's choice to fix directly rather than run full ceremony for this slice).

- **User outcome**: `--help`, `setup`, `generate`, and plain scenario invocation all
  dispatch correctly; `--silent`/`--review-before-fix`/`--priority` behave predictably
  and the documented "never skipped" safety set actually never skips.
- **Scope included**: Phase -1 dispatch logic; flag precedence resolution
  (`REVIEW_BEFORE_FIX`); `--silent`'s exact skip/never-skip boundary;
  contradictory-flag and unreadable-scope-path rejection; no-`config.md` fallback to
  setup offer; `config.md` internal-consistency validation.
- **Dependencies**: UAT-01.
- **Relevant specification sources**: `SKILL.md` Phase -1, Phase 0;
  `docs/design-history.md` R4.
- **Completion evidence**: `--help` now prints exactly `USAGE.md` and stops (fixed —
  root cause was a `$ARGUMENTS`-substitution artifact, not a logic bug); `config.md`
  internal-consistency (e.g. `bug-fix-mechanism: spec-kit` missing its three command
  fields) now caught at Phase 0 instead of surfacing opaquely mid-Phase-4.

---

### UAT-04 — Bug-Fix Cycle (Direct Mechanism)
**Status: Done.** Formalized via Spec Kit (`specs/005-bug-fix-cycle-direct/`), fully
implemented and converged (zero convergence findings).

- **User outcome**: A confirmed BUG finding gets stopped, assessed, optionally paused
  for review, fixed, restarted, and **retested in the browser** — not just re-run as
  an automated test — before being considered resolved, with no external bug-workflow
  tool required.
- **Scope included**: stop→assess→(optional pause)→fix→test→restart→browser-retest→
  per-bug-commit cycle; multi-bug-per-scenario batching (one restart/retest covering
  every bug from that scenario); high-risk carve-outs (security/auth/data-deletion/
  architecture) that no flag can skip; two-consecutive-restart-failure abort; per-bug
  retry budget (2 more cycles before marking unresolved).
- **Scope explicitly deferred**: Spec-Kit delegation (UAT-09).
- **Dependencies**: UAT-02, UAT-03.
- **Relevant specification sources**: `SKILL.md` Phase 4 (`bug-fix-mechanism: direct`
  branch); `docs/design-history.md` "Phase 4 clarification — multiple bugs from one
  scenario"; D4.
- **Completion evidence** (target): a seeded, deliberately broken scenario is fixed
  and the fix only counts as resolved after a real browser retest post-restart; a
  high-risk-category bug pauses for sign-off regardless of `--silent` or
  `--no-review-before-fix`. `demo-app`'s three seeded `DEMO_BUG_*` flags are exactly
  what this slice needs for real completion evidence.

---

### UAT-05 — Backend Verification
**Status: Done.** Formalized via Spec Kit (`specs/004-backend-verification/`), fully
implemented and converged (zero convergence findings).

- **User outcome**: A scenario's claimed data change is confirmed directly against the
  app's own API or a discovered data store — not just inferred from what the UI
  showed.
- **Scope included**: API-first, direct-store-fallback verification per Phase 0.5's
  discovered backend-verification path; graceful UI-only degradation with explicit
  note when no store is discoverable; treating this check as a read, not gated by the
  DB-write confirmation.
- **Scope explicitly deferred**: multi-store verification when more than one
  discovered store is relevant to a single outcome — open architecture question, not
  resolved by this slice.
- **Dependencies**: UAT-01, UAT-02.
- **Relevant specification sources**: `SKILL.md` Phase 0.5 "Backend verification
  path"; Phase 2 step 7; `docs/design-history.md` R10.
- **Completion evidence** (target): a scenario whose UI falsely reports success
  against a real backend is caught by this check where a UI-only pass would have
  missed it; a project with no discoverable store degrades cleanly to a UI-only note.
  `demo-app`'s silent-comment-failure bug and API-vs-direct-DB dual verification paths
  are built exactly for this.

---

### UAT-06 — Run Isolation & Data Hygiene
**Status: Done.** Formalized via Spec Kit (`specs/003-run-isolation-data-hygiene/`),
fully implemented and converged.

- **User outcome**: Every record the skill creates is safely, automatically cleaned up
  at both ends of a run, with collisions across runs structurally near-impossible
  rather than merely policy-discouraged.
- **Scope included**: run-id-suffixed naming (`uat-{run-id}-<descriptor>`) for every
  created record; start-of-run purge (self-heals from an interrupted prior run);
  end-of-run purge (only after the report is actually written); explicit confirmation
  on both purges, every run, `--silent` or not.
- **Dependencies**: UAT-01.
- **Relevant specification sources**: `SKILL.md` "Naming convention for UAT-created
  data (R7)"; Phase 0 start-of-run cleanup; Phase 5 end-of-run cleanup;
  `docs/design-history.md` R7 in full.

---

### UAT-07 — Scenario Generation: Spec-Derived + Route-Gap-Derived
**Status: Done.** Formalized via Spec Kit (`specs/006-spec-route-gap-generation/`),
fully implemented and converged (zero convergence findings).

- **User outcome**: Run `/webapp-uat generate` and get draft scenarios traced back to
  real acceptance criteria, plus stub coverage for screens nothing tests at all yet —
  reviewed through the same approval flow as hand-written scenarios.
- **Scope included**: spec-derived generation (one candidate per acceptance criterion,
  persona variants derived from the spec's own use cases); route-gap-derived
  generation (using Phase 0.5's discovered routing source); `--priority` scoping;
  `Source:` tagging.
- **Scope explicitly deferred**: boundary-derived generation and fixture synthesis
  (UAT-08).
- **Dependencies**: UAT-01.
- **Relevant specification sources**: `SKILL.md` Generation mode steps 1–2, Phase 0.5
  routing discovery; `docs/design-history.md` R6 (spec-derived, route-gap-derived
  portions).
- **Completion evidence**: `SKILL.md` Generation mode step 1 now states the symmetric
  routing-source-undiscoverable degradation case and the neither-prerequisite-met
  case (FR-008/FR-009), alongside the pre-existing spec-dir-unconfigured case; step
  2's `--priority` bullet now scopes every active source (not boundary-derived
  alone) and states the zero-eligible-flows outcome (FR-010/FR-012). Text-traced
  against all 12 FRs and 13 acceptance criteria, zero `/speckit-analyze` and zero
  `/speckit-converge` findings. Route-gap-derived is live-demonstrable today against
  `demo-app` (`/profile` and the settings landing page are deliberately uncovered by
  the bundled scenarios); spec-derived generation's happy path still needs a project
  with a real `spec-dir` to demonstrate against, since `demo-app` deliberately has no
  `specs/` of its own yet (see `demo-app`'s README) — tracked in
  `specs/006-spec-route-gap-generation/quickstart.md`'s "Done when" section.

---

### UAT-08 — Scenario Generation: Boundary-Derived + Fixture Synthesis
**Status: Done.** Formalized via Spec Kit (`specs/007-boundary-fixture-synthesis/`),
fully implemented and converged (zero convergence findings).

- **User outcome**: Critical/High-priority flows get real negative-path and
  boundary-case scenarios derived from actual validation code, and a missing fixture
  gets offered as a genuinely valid synthesized file rather than blocking the run.
- **Scope included**: per-flow (not global-catalog) validation/schema/ORM
  introspection for boundary-derived drafts, scoped to Critical/High priority;
  consolidated structured fixture/data list across every draft; Phase 0
  fixture-synthesis offer through the same batched-approval mechanism, auto-
  synthesized and noted under `--silent`.
- **Dependencies**: UAT-01, UAT-06, UAT-07.
- **Relevant specification sources**: `SKILL.md` Generation mode step 2
  (boundary-derived bullet), Phase 0 fixture-check/synthesis; `docs/design-history.md`
  R6 (boundary-derived portion).
- **Completion evidence**: `SKILL.md` Generation mode step 2's boundary-derived
  bullet now states drafting cardinality (one per distinct constraint category
  present), requires each draft to name the specific constraint value it targets
  (closing a traceability gap `/speckit-analyze` caught), and states the
  unreadable-validation-code and zero-constraints-found degradation cases
  (FR-002/FR-004/FR-011/FR-012); step 3's fixture list now states its dedup rule
  (FR-006). Phase 0's fixture-check step and R7 were confirmed — not assumed — to
  already satisfy the synthesis-offer, genuineness, `--silent`, and
  fixture-persistence requirements (FR-007–FR-010) as written; one incorrect
  assumption (that synthesized fixtures follow `UAT-06`'s run-id-suffixed cleanup
  like DB rows) was caught and corrected in `spec.md` before implementation —
  fixture files persist as reusable static assets, only a referencing DB row
  follows `UAT-06`. Text-traced against all 12 FRs and 11 acceptance criteria, one
  `/speckit-analyze` coverage-gap finding resolved inline, zero
  `/speckit-converge` findings. `demo-app` deliberately ships without
  `sample-oversized.pdf` and has real zod validation on its document-creation flow
  (`lib/validation.ts`), so both this slice's completion evidence targets are
  live-demonstrable against it; tracked in
  `specs/007-boundary-fixture-synthesis/quickstart.md`'s "Done when" section.

---

### UAT-09 — Bug-Fix Cycle (Spec-Kit Mechanism)
**Status: Not yet formalized. Live-verification blocked** — needs a target repo with
Spec Kit's bug-workflow extension actually installed and its three commands
configured; `demo-app` uses `bug-fix-mechanism: direct` deliberately (see D6), so it
cannot supply completion evidence for this slice as-is.

- **User outcome**: Same fix cycle as UAT-04, but delegated to an installed Spec Kit
  bug-workflow extension's assess/fix/test commands instead of Claude fixing
  in-session.
- **Scope included**: `bug-fix-mechanism: spec-kit` branch — running the configured
  `bug-assess-command`/`bug-fix-command`/`bug-test-command` against a finding;
  identical high-risk carve-outs and review-pause behavior as the direct mechanism.
- **Dependencies**: UAT-04 (proven working in `direct` mode first), a repo with Spec
  Kit's bug-workflow extension actually installed.
- **Relevant specification sources**: `SKILL.md` Phase 4 (`bug-fix-mechanism:
  spec-kit` branch); `config.md.example` "Bug-fix mechanism" section.

---

### UAT-10 — Resumability & In-Run Gap Promotion
**Status: Done.** Formalized via Spec Kit (`specs/008-resumability-gap-promotion/`),
fully implemented and converged (zero convergence findings).

- **User outcome**: An interrupted run can be resumed or deliberately abandoned rather
  than silently colliding with a fresh start; a gap Phase 1 review notices becomes a
  real, approvable scenario file immediately, not a line item someone has to
  separately ask for.
- **Scope included**: Phase 0 resume check (`test-plan.md` with no
  `final-report.md` → resume/abandon/start fresh; defaults to abandon under
  `--silent`, noted in the report); Phase 1 gap promotion (draft the actual scenario
  file, tag `review-derived`, include in the same approval decision).
- **Dependencies**: UAT-02.
- **Relevant specification sources**: `SKILL.md` Phase 0 "Resume check"; Phase 1 "Gap
  promotion (R9)"; `docs/design-history.md` R8, R9.
- **Completion evidence**: `SKILL.md`'s Phase 0 "Resume check" now specifies
  resume mechanics that were never previously written down — confirmed against
  `docs/design-history.md` R8, which only ever specified detection, not what
  "resume" does once chosen. Resume now reuses the existing `test-plan.md`,
  skips scenarios with a pre-interruption recorded result, executes the rest in
  original order, and produces one coherent final report; "abandon" and "start
  fresh" are now explicitly distinct (a real ambiguity in the initial spec draft
  caught during `/speckit-checklist` and fixed before implementation); multiple
  simultaneous interruptions now resolve to the most-recent-by-`run-id` deterministically.
  Phase 1's "Gap promotion (R9)" now bounds itself to one pass (no recursive
  re-review of a newly-promoted scenario). One coverage gap (FR-009's
  directory-untouched guarantee, initially miscategorized as already-specified)
  was caught by `/speckit-analyze` and fixed before convergence. Text-traced
  against all 17 FRs and 14 acceptance criteria, zero `/speckit-converge`
  findings. Fully live-verifiable against `demo-app` — both a deliberately
  interrupted CLI session and a deliberately gap-containing review batch are
  straightforward to construct; tracked in
  `specs/008-resumability-gap-promotion/quickstart.md`'s "Done when" section.
  This closes the review/generation-adjacent group (`UAT-07`, `UAT-08`,
  `UAT-10`) — all four `Source:` tags (`spec-derived`, `route-gap-derived`,
  `boundary-derived`, `review-derived`) are now fully specified.

---

### UAT-11 — One-Command Install
**Status: In progress** (approved plan, Phase 2).

- **User outcome**: A stranger installs the skill in a project with two native Claude
  Code commands (`/plugin marketplace add` + `/webapp-uat setup`), no manual
  file-copying required, despite Claude Code plugins being unable to install files
  outside `.claude/`.
- **Scope included**: `.claude-plugin/marketplace.json` at repo root; `scripts/dev.sh`/
  `uat/scenarios/_template.md` shipped as templates inside the installable plugin
  folder; Setup mode extended to copy those templates into the target repo's own tree
  when missing, using the same confirm-before-write pattern already used for
  `config.md`.
- **Scope explicitly deferred**: a separate `curl | sh` install script.
- **Dependencies**: UAT-01 (extends Setup mode).
- **Completion evidence** (target): from a scratch clone, `/plugin marketplace add` +
  `/plugin install` + `/webapp-uat setup` lands `config.md`, `scripts/dev.sh`, and
  `uat/scenarios/_template.md` correctly with zero manual file copying.

---

### UAT-12 — Demo/Test Application (`demo-app/`)
**Status: Done.** Built, live-verified (all three seeded bugs confirmed working via
real HTTP requests, cross-tenant isolation confirmed to hold even with the permission
bug on), and shipped as its own repo/submodule
([`webapp-uat-demo`](https://github.com/kzaamout/webapp-uat-demo)).

- **User outcome**: Anyone evaluating this skill can run it against a real, working
  app in minutes — no setup of their own project required — and see every core
  capability demonstrated for real, including on deliberately-seeded, toggleable bugs.
- **Scope included**: "Team Documents" domain (Next.js + Postgres) — multi-role auth
  with a real permission boundary and a correctly-enforced cross-tenant control; a
  substantively zod-validated form; file upload with real server-side accept/reject
  rules; a 6-entity relational schema queryable for backend verification; a genuine
  list-view empty state; file-based routing with an intentional coverage gap; 3
  env-gated, off-by-default seeded bugs (permission bypass, accessibility, silent
  backend-write failure); root-level `scripts/dev.sh`/`uat/scenarios/` wired to it.
- **Scope explicitly deferred**: the Spec-Kit specs needed to exercise UAT-07/UAT-09
  against this app; multi-locale support.
- **Dependencies**: none on other webapp-uat slices directly, but UAT-02/UAT-04/
  UAT-05/UAT-07/UAT-08's completion evidence is far stronger demonstrated against this
  app than a synthetic example.

---

**Build order followed so far**: `UAT-01 → UAT-03 → UAT-02 → UAT-06 → UAT-12 → UAT-05
→ UAT-04 → UAT-07 → UAT-08 → UAT-10`, ahead of the original suggested order in
places (`UAT-12` pulled forward once its architecture was approved, since later
slices' completion evidence depends on it existing).

**Remaining order**: `UAT-09 → UAT-11`
(`UAT-11` continues in parallel — no hard dependency on the others beyond UAT-01).
`UAT-09` is expected to land specified-but-not-live-verified, pending a Spec-Kit
bug-workflow extension being installed somewhere to demonstrate against.
