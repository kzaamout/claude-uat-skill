# LinkedIn Draft — webapp-uat

Text only — no posting integration in this session, so publishing stays a
manual step. Two length options below; pick one, don't post both.

---

## Option A — Full post (~150 words)

I've been building a Claude Code skill that runs real UAT against a web app —
not a linter, not a mocked test suite. It drives an actual Chrome window.

Here's what makes it different from a script:

→ Every scenario logs in fresh and drives a real browser — clicks, forms,
navigation, plus a real axe-core accessibility audit.

→ It doesn't trust the UI. After a scenario runs, it checks the claimed
outcome directly against the app's own API or database. Caught a real
class of bug this way: a UI that says "saved" while nothing persisted.

→ Confirmed bugs get fixed and *browser-retested* before they're marked
resolved — a passing automated test alone doesn't close anything out.

→ Anything touching security, auth, or data deletion always stops for a
human. No flag, no silent mode, skips that.

It sits after implementation, before merge — a QA gate, not a replacement
for code review.

Workflow diagram + the repo: [link]

Built with Claude Code. Open source, config-driven — point it at your own
app.

---

## Option B — Short post (~60 words)

Built a Claude Code skill that runs real end-to-end UAT: drives an actual
Chrome browser, checks results against the real backend (not just the UI),
fixes confirmed bugs, and re-tests them in the browser before calling them
resolved. High-risk changes always pause for a human.

Workflow + repo: [link]

Open source. Point it at your own app.

---

## Notes for whoever posts this

- **`[link]`** → the published workflow diagram (updated 2026-08-20 to the
  SDLC swimlane version — developer / webapp-uat / Chrome+app lanes):
  `https://claude.ai/code/artifact/2d795969-a2b9-4349-aadd-db6a66af9db9`
  (currently private — share it from the artifact's own share menu before
  the post goes live, otherwise the link 404s for anyone else). Repo:
  `https://github.com/kzaamout/claude-uat-skill`.
- Attach GIFs directly to the post (LinkedIn native video/GIF upload gets
  far more reach than an outbound link preview). Three recorded 2026-08-20
  against the demo app's silent-comment-failure bug (checked in under
  `docs/gifs/`), telling the full story in sequence:
  1. `uat-scenario-execution.gif` — a scenario running in real Chrome
     (login as the scenario's account, navigate to the documents list).
  2. `uat-bug-found-ui-lies.gif` — the catch: UI says "Comment added.",
     comment count stays 0, reload confirms nothing persisted (backend
     verification via direct Postgres read found 0 rows).
  3. `uat-fix-retest-passing.gif` — after the fix + app restart, the same
     steps re-driven: the comment persists and renders.
  The full recording from `docs/demo-recording-runbook.md` is still the
  first choice if it gets made; these GIFs are the ready-now fallback
  (older single `webapp-uat-demo-flow.gif` is superseded).
- The "UI says saved, nothing persisted" line is the single most
  differentiated claim in either draft — if trimming for length, cut
  elsewhere first.
- Neither draft claims performance numbers, adoption figures, or comparisons
  to named competitors — nothing here needs a citation.
