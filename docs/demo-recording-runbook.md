# Demo Recording Runbook

For capturing a full terminal + browser screen recording of `webapp-uat` in
one take. The Chrome-only GIF already produced
(`webapp-uat-demo-flow.gif`) covers only the browser-visible portion — this
runbook is for the complete picture: the terminal side (Phase 0 pre-flight,
Phase 1 approval, Phase 3 classification, Phase 4's fix cycle, Phase 5's
report) interleaved with the same Chrome window.

**Total runtime target: 4-6 minutes.** Longer than that loses a LinkedIn
audience; shorter can't show the full cycle (detection → fix → verified).

## Before you hit record

1. `demo-app` running cleanly: `cd demo-app && ./run.sh`, wait for
   `✓ Ready` in the terminal.
2. `demo-app/.env`: enable exactly one demo bug for this recording.
   **Recommended: `DEMO_BUG_SILENT_COMMENT_FAILURE=1`** — it's the sharpest
   demo of this skill's actual differentiator (backend verification catching
   a UI that lies about success), stronger than the accessibility bug already
   shown in the GIF. Restart `demo-app` after editing `.env` so the flag
   takes effect.
3. Screen layout: terminal (Claude Code session) on one side, Chrome window
   on the other, both visible simultaneously if your recording setup allows
   split-screen — otherwise, alt-tab deliberately and pause a beat each time
   so the recording doesn't feel rushed.
4. Have `uat/scenarios/` scoped to just the comment-length scenario for this
   recording (or point the invocation at that one file directly) — running
   the full bundled scenario set would blow the runtime budget.

## The recording script

Narration lines are suggestions, not a script to read verbatim — say it in
your own words, but hit the same beats.

### 1. Cold open (10-15s)

**Show**: terminal, empty prompt, in the `demo-app` directory (or wherever
`webapp-uat` is configured against).

**Narrate**: "This is `webapp-uat` — a Claude Code skill that runs real UAT
against a web app: drives a real Chrome browser, checks accessibility and
backend state, and fixes what it finds. Watch it catch a bug a UI-only test
would miss."

### 2. Invoke, watch Phase 0 (15-20s)

**Run**: `/webapp-uat uat/scenarios/comment-length.md` (or whichever scenario
file exercises comments on a document — check `uat/scenarios/` for the exact
name).

**Show**: terminal output as Phase 0 runs — git-clean check, Chrome
connection, `scripts/dev.sh` sanity check, fixture check, resume check
(should be a no-op on a fresh run), start-of-run cleanup (no-op if nothing to
purge).

**Narrate**: "Before anything touches the browser, it checks the environment
is sane — clean git tree, Chrome connected, the app's actually up."

### 3. Phase 1 approval (10s)

**Show**: the reviewed plan printed, the approve/adjust/cancel prompt.

**Action**: approve.

**Narrate**: "Nothing runs without a reviewed plan and explicit approval —
same for hand-written scenarios or generated ones."

### 4. Phase 2 execution — switch to Chrome (30-45s)

**Show**: Chrome window, visible, driving the scenario live — log in, navigate
to a document, add a comment long enough to trip the seeded bug (1001-2000
characters — have a pre-written paste-ready string of the right length handy
so you're not typing it live).

**Narrate**: "It's not scripted clicks — this is a real Chrome window, a real
session, logging in as the account the scenario names every time."

### 5. The catch — split attention terminal/browser (20-30s)

**Show**: the UI's own "Comment added" success toast in Chrome, then cut to
terminal showing the backend-verification step running and flagging the
discrepancy — comment not actually persisted server-side.

**Narrate**: "The UI says it worked. This is the part a UI-only test would
stop at — but it checks the backend directly. And the backend says nothing
was actually saved."

### 6. Classification (10s)

**Show**: terminal — finding classified `BUG`, severity assigned.

**Narrate**: "That's a P1 — a described feature silently not working. It
goes to the fix cycle automatically."

### 7. Phase 4 — the fix cycle (60-90s, the core of the demo)

**Show**: terminal — app stopped, in-session assessment printed (root cause,
proposed fix, affected files), the review pause (if `REVIEW_BEFORE_FIX` is
on) or straight to fix.

**Narrate while the fix happens**: "It stops the app before touching
anything, assesses the actual root cause — here it's a swallowed exception in
the comment handler — writes the fix, restarts."

**Show**: app restarting, then cut back to Chrome — the *exact same scenario
steps* re-driven in the browser, the comment now actually appearing.

**Narrate**: "And it doesn't just trust an automated test — it re-drives the
same scenario in the browser again. That's what actually closes the bug out."

### 8. Commit + report (15-20s)

**Show**: terminal — the commit for this one bug, then the final report
printed (scenarios run, bug fixed & browser-verified, evidence paths).

**Narrate**: "One commit per bug, and a full report — what ran, what broke,
what got fixed, what didn't."

### 9. Close (10s)

**Show**: terminal, final report on screen, or cut to the README/GitHub repo.

**Narrate**: "That's the whole loop — real browser, real backend check, real
fix, real retest. Link in the post if you want to try it against your own
app."

## After recording

- Trim dead air at the start/end.
- If the fix cycle (step 7) runs long in the raw take, this is the one
  section safe to speed up 1.5-2x in post — the narration still tracks, and
  it's the least visually interesting part (mostly text scrolling).
- Revert `demo-app/.env`'s `DEMO_BUG_SILENT_COMMENT_FAILURE` back to unset
  after recording, and re-run `./run.sh` (or just restart the dev server) so
  the repo's demo returns to its default, all-bugs-off state for the next
  person who clones it.
- If you commit the actual bug fix made during recording, revert it
  afterward too (`git log` in `demo-app` right after recording to find it) —
  the seeded bug needs to still be there, toggled off, for future demos.

## Fallback: no split-screen / single-monitor setup

Record two shorter clips instead of one continuous take:
- **Clip A** (Chrome only, ~30s): steps 4-5's browser side. This is
  essentially what `webapp-uat-demo-flow.gif` already captured — reuse it or
  re-record fresh footage of the actual bug flow instead of the a11y one.
- **Clip B** (terminal only, ~90s): steps 2-3, 6-8, sped up 1.5x, with text
  captions summarizing what's happening instead of live narration.

Stitch with a 1-2s crossfade in whatever editor is convenient — doesn't need
to be fancy.
