# Decker UAT Skill — Setup

One-time checklist to get `/decker-uat` running in this repo. For what the skill
actually does once it's running, see `README.md`; for full command syntax, `USAGE.md`.

## 1. Unzip into the repo

```bash
cd /Users/kzaamout/Desktop/code/Decker
unzip ~/Downloads/decker-uat-setup.zip -d .
```

Places:
- `.claude/skills/decker-uat/{SKILL.md, USAGE.md, README.md, decker-uat-v2-requirements.md}`
- `scripts/decker-dev.sh` (already executable)
- `uat/scenarios/_template.md`

## 2. Two manual edits before anything runs

- [ ] `.claude/skills/decker-uat/SKILL.md` — find the `FILL IN BEFORE FIRST RUN`
      line near the top. Replace `<bug-assess>`, `<bug-fix>`, `<bug-test>` with the
      real command names `specify extension list` shows in this repo.
- [ ] `scripts/decker-dev.sh` — confirm `PORT=3000` (a guess) and `DECKER_DIR`
      actually match reality before trusting `wait-ready`/`stop`.

## 3. Create the remaining directories

The zip only brings `uat/scenarios/`, since that's the only one with a file in it:

```bash
mkdir -p uat/runs uat/artifacts uat/fixtures
```

## 4. Confirm Chrome is actually connected

```bash
claude --chrome
```

Then `/chrome` inside the session to verify it connects. Quit Claude Desktop first
if it's running on this machine — known native-messaging-host conflict with Claude
Code's Chrome bridge on macOS.

## 5. Write one real scenario

```bash
cp uat/scenarios/_template.md uat/scenarios/my-first-scenario.md
```

Fill it in. Drop anything it needs — a real, valid file, not a placeholder — into
`uat/fixtures/`.

## 6. Run it

```
/decker-uat uat/scenarios/my-first-scenario.md
```

First run is slower than every run after it: Phase 0.5 inspects Decker's codebase
once (routing, locale, test-data tooling, backend verification options) and caches
the result at `.claude/skills/decker-uat/discovered-environment.md`. Worth reading
that file once it's written, before trusting anything downstream of it — route-gap
generation and backend verification both build on what it found.

## Done when

- [ ] `/chrome` connects without error
- [ ] `specify extension list` command names are in `SKILL.md`, not the placeholders
- [ ] `scripts/decker-dev.sh start` / `wait-ready` / `stop` all work once, run manually
- [ ] At least one scenario exists in `uat/scenarios/` with its fixtures in place
- [ ] First `/decker-uat` run completes and `discovered-environment.md` looks right
