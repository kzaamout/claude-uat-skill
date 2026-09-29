#!/usr/bin/env bash
# Guards against silent drift between the deliberate copies this repo carries.
# Two copy-pairs exist by necessity (see docs/design-history.md D7/D8/D13, and the
# 2026-08-19 drift that motivated this script):
#
#   1. The skill's bundled templates vs. the root reference copies
#      (a plugin install can only write under .claude/, so both must exist)
#   2. The parent's skill folder vs. demo-app's installed copy
#      (demo-app is its own repo; which copy runs depends on session root - D8)
#
# Run from anywhere; exits non-zero on any drift. CI runs this on every push.

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

SKILL=".claude/skills/webapp-uat"
FAIL=0

check() { # check <label> <file-a> <file-b>
  if diff -q "$2" "$3" > /dev/null 2>&1; then
    echo "  in sync: $1"
  else
    echo "  DRIFT:   $1"
    echo "           $2"
    echo "           $3"
    FAIL=1
  fi
}

echo "Templates vs. root reference copies:"
check "dev.sh"          "$SKILL/templates/dev.sh"          "scripts/dev.sh"
check "dev.env.example" "$SKILL/templates/dev.env.example" "scripts/dev.env.example"
check "_template.md"    "$SKILL/templates/_template.md"    "uat/scenarios/_template.md"

echo ""
if [ -f "demo-app/$SKILL/SKILL.md" ]; then
  echo "Parent skill vs. demo-app's installed copy:"
  # Every tracked skill file, taken from git so a newly added bundled file can't
  # slip past this check. config.md and discovered-environment.md are local-only
  # (gitignored) and therefore never in this list.
  for f in $(git ls-files "$SKILL" | sed "s|^$SKILL/||"); do
    check "$f" "$SKILL/$f" "demo-app/$SKILL/$f"
  done
  # demo-app's copies of the files the skill manages in a project tree: its
  # _template.md must match the bundled one; its scripts/dev.sh is deliberately
  # still the pre-UAT-13 legacy wrapper (design-history D13), so only its status
  # is asserted, not its content.
  check "demo-app uat/scenarios/_template.md" "$SKILL/templates/_template.md" "demo-app/uat/scenarios/_template.md"
  st="$(bash "$SKILL/scripts/sync-managed.sh" demo-app --check | awk '$2=="scripts/dev.sh"{print $1}')"
  if [ "$st" = "legacy" ] || [ "$st" = "in-sync" ]; then
    echo "  in sync: demo-app scripts/dev.sh ($st)"
  else
    echo "  DRIFT:   demo-app scripts/dev.sh reports '$st' (expected legacy or in-sync)"
    FAIL=1
  fi
else
  echo "demo-app submodule not checked out - skipping that pair."
  echo "(git submodule update --init, then re-run, for the full check)"
fi

echo ""
if [ "$FAIL" -ne 0 ]; then
  echo "Sync check FAILED. Re-sync the drifted pair(s) - deliberately, in whichever"
  echo "direction is correct - and re-run. demo-app is a submodule: syncing its copy"
  echo "means a commit there plus a pointer bump here."
  exit 1
fi
echo "Sync check passed - all copy-pairs identical."
