#!/usr/bin/env bash
# End-to-end test for webapp-uat's managed-file mechanism (roadmap UAT-13):
# the bundled sync script (scripts/sync-managed.sh) and the dev.sh engine.
# Runs entirely in a scratch directory holding a copy of the skill folder and a
# fake project. Needs bash 3.2+, git, cmp, curl, python3 (throwaway HTTP server).
# Exit 0 = ALL PASSED. CI runs this on every push (see .github/workflows/sync-check.yml).

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.."
SKILL_SRC="$PWD/.claude/skills/webapp-uat"

S="$(mktemp -d "${TMPDIR:-/tmp}/webapp-uat-test.XXXXXX")"
SKILL="$S/skill"
P="$S/proj"
SYNC="$SKILL/scripts/sync-managed.sh"
ENGINE="$P/scripts/dev.sh"

cleanup() {
  if [ -f "$P/.webapp-uat.pid" ]; then
    kill -INT "$(cat "$P/.webapp-uat.pid")" 2>/dev/null
  fi
  rm -rf "$S"
}
trap cleanup EXIT

PASS=0
FAIL=0
ok()   { PASS=$((PASS+1)); echo "  ok   $1"; }
fail() { FAIL=$((FAIL+1)); echo "  FAIL $1"; [ -n "${2:-}" ] && printf '       %s\n' "$2"; }

# expect_line <label> <output> <extended regex that must match one whole line>
expect_line() {
  if printf '%s\n' "$2" | grep -E -q "^$3\$"; then ok "$1"; else fail "$1" "no line matching /^$3\$/ in: $(printf '%s' "$2" | tr '\n' '|')"; fi
}
expect_no_line() {
  if printf '%s\n' "$2" | grep -E -q "^$3\$"; then fail "$1" "unexpected line matching /^$3\$/"; else ok "$1"; fi
}
expect_contains() {
  case "$2" in *"$3"*) ok "$1";; *) fail "$1" "expected to contain '$3', got: $(printf '%s' "$2" | tr '\n' '|')";; esac
}
expect_eq() { if [ "$2" = "$3" ]; then ok "$1"; else fail "$1" "expected '$3', got '$2'"; fi; }
expect_same() { if cmp -s "$2" "$3"; then ok "$1"; else fail "$1" "$2 differs from $3"; fi; }
expect_file() { if [ -f "$2" ]; then ok "$1"; else fail "$1" "missing $2"; fi; }
expect_no_file() { if [ ! -e "$2" ]; then ok "$1"; else fail "$1" "$2 exists"; fi; }

cp -R "$SKILL_SRC" "$SKILL"
mkdir -p "$P"
git -C "$P" init -q
git -C "$P" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init

echo "== bundled copies carry the marker"
if head -3 "$SKILL/templates/dev.sh" | grep -q 'webapp-uat managed file'; then ok "templates/dev.sh has marker"; else fail "templates/dev.sh has marker"; fi
if head -3 "$SKILL/templates/_template.md" | grep -q 'webapp-uat managed file'; then ok "templates/_template.md has marker"; else fail "templates/_template.md has marker"; fi
expect_file "sync script is bundled" "$SYNC"

echo "== --check on a fresh project"
out="$(bash "$SYNC" "$P" --check 2>&1)"; rc=$?
expect_eq "check exit code" "$rc" "0"
expect_line "dev.sh missing"        "$out" 'missing +scripts/dev.sh'
expect_line "_template.md missing"  "$out" 'missing +uat/scenarios/_template.md'
expect_line "values-file missing"   "$out" 'values-file +scripts/dev.env +missing'
expect_no_file "check writes nothing" "$P/scripts/dev.sh"

echo "== --apply on a fresh project"
out="$(bash "$SYNC" "$P" --apply 2>&1)"; rc=$?
expect_eq "apply exit code" "$rc" "0"
expect_line "dev.sh created"        "$out" 'created +scripts/dev.sh'
expect_line "_template.md created"  "$out" 'created +uat/scenarios/_template.md'
expect_line "changed: 2"            "$out" 'changed: 2'
expect_line "changed-paths lists both" "$out" 'changed-paths: scripts/dev.sh uat/scenarios/_template.md'
expect_same "dev.sh byte-identical" "$SKILL/templates/dev.sh" "$ENGINE"
expect_same "_template.md byte-identical" "$SKILL/templates/_template.md" "$P/uat/scenarios/_template.md"
if [ -x "$ENGINE" ]; then ok "dev.sh executable"; else fail "dev.sh executable"; fi
expect_no_file "apply never creates dev.env" "$P/scripts/dev.env"

echo "== second --apply is a no-op"
out="$(bash "$SYNC" "$P" --apply 2>&1)"
expect_line "dev.sh in-sync"        "$out" 'in-sync +scripts/dev.sh'
expect_line "_template.md in-sync"  "$out" 'in-sync +uat/scenarios/_template.md'
expect_line "changed: 0"            "$out" 'changed: 0'
expect_line "changed-paths empty"   "$out" 'changed-paths: *'

echo "== --check with no root argument, from inside the repo"
out="$(cd "$P/uat" && bash "$SYNC" --check 2>&1)"; rc=$?
expect_eq "check (no arg) exit code" "$rc" "0"
expect_line "root resolved via git" "$out" 'in-sync +scripts/dev.sh'

echo "== --check with a nonexistent root argument"
out="$(bash "$SYNC" "$S/nope" --check 2>&1)"; rc=$?
expect_eq "cannot-check exit code" "$rc" "0"
expect_line "single cannot-check line" "$out" 'managed-files: cannot check \(.*\)'
expect_eq "exactly one line" "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" "1"

echo "== simulated skill update (bundled _template.md changes)"
printf '\n<!-- v2 -->\n' >> "$SKILL/templates/_template.md"
out="$(bash "$SYNC" "$P" --check 2>&1)"
expect_line "update-available"      "$out" 'update-available +uat/scenarios/_template.md'
expect_line "dev.sh still in-sync"  "$out" 'in-sync +scripts/dev.sh'
out="$(bash "$SYNC" "$P" --apply 2>&1)"
expect_line "updated"               "$out" 'updated +uat/scenarios/_template.md'
expect_line "changed: 1"            "$out" 'changed: 1'
expect_line "changed-paths one"     "$out" 'changed-paths: uat/scenarios/_template.md'
expect_same "project copy now matches" "$SKILL/templates/_template.md" "$P/uat/scenarios/_template.md"

echo "== marker removed => unmanaged, never written"
tail -n +2 "$P/uat/scenarios/_template.md" > "$S/unmanaged.md" && cp "$S/unmanaged.md" "$P/uat/scenarios/_template.md"
printf '\n<!-- v3 -->\n' >> "$SKILL/templates/_template.md"
out="$(bash "$SYNC" "$P" --check 2>&1)"
expect_line "unmanaged status"      "$out" 'unmanaged +uat/scenarios/_template.md'
out="$(bash "$SYNC" "$P" --apply 2>&1)"
expect_line "skipped-unmanaged"     "$out" 'skipped-unmanaged +uat/scenarios/_template.md'
expect_line "changed: 0 (unmanaged)" "$out" 'changed: 0'
expect_same "unmanaged file untouched" "$S/unmanaged.md" "$P/uat/scenarios/_template.md"

echo "== legacy wrapper (pre-UAT-13 dev.sh with values filled in)"
cp "$ENGINE" "$S/engine.sh"
cat > "$ENGINE" <<'LEGACY'
#!/usr/bin/env bash
# Start/stop/wait-ready for the app under test. Fill in the four values below for
# your project, then confirm each of start/stop/wait-ready works once, run manually,
# before trusting webapp-uat to rely on it.

set -u

PROJECT_DIR="/Users/someone/code/my-app"     # absolute path to the app's repo root
START_COMMAND="docker compose up -d && npm run dev"   # brings up everything the app needs (backend, db, etc.)
STOP_COMMAND="docker compose down"  # anything START_COMMAND doesn't tear down via SIGINT
PORT=4321                           # what the app serves its health check on
WAIT_TIMEOUT="${WAIT_TIMEOUT:-45}"  # wait-ready gives up after ~this many seconds

PIDFILE="$PROJECT_DIR/.webapp-uat.pid"

case "${1:-}" in
  start) echo "legacy start" ;;
  *) echo "Usage: $0 {start|stop|wait-ready}"; exit 1 ;;
esac
LEGACY
cp "$ENGINE" "$S/legacy.sh"
out="$(bash "$SYNC" "$P" --check 2>&1)"
expect_line "legacy status"         "$out" 'legacy +scripts/dev.sh'
out="$(bash "$SYNC" "$P" --apply 2>&1)"
expect_line "skipped-legacy"        "$out" 'skipped-legacy +scripts/dev.sh'
expect_same "legacy file untouched" "$S/legacy.sh" "$ENGINE"
out="$(WAIT_TIMEOUT=999 bash "$SYNC" "$P" --legacy-values 2>&1)"; rc=$?
expect_eq "legacy-values exit code" "$rc" "0"
expected="START_COMMAND='docker compose up -d && npm run dev'
STOP_COMMAND='docker compose down'
PORT='4321'
WAIT_TIMEOUT='45'"
expect_eq "legacy-values output exact" "$out" "$expected"
expect_no_line "PROJECT_DIR never printed" "$out" 'PROJECT_DIR=.*'
cp "$S/engine.sh" "$ENGINE"
out="$(bash "$SYNC" "$P" --legacy-values 2>&1)"; rc=$?
expect_eq "not-legacy exit code" "$rc" "3"
expect_eq "not-legacy output" "$out" "not-legacy"

echo "== engine: dev.env missing"
out="$(bash "$ENGINE" start 2>&1)"; rc=$?
expect_eq "no dev.env exit code" "$rc" "1"
expect_contains "no dev.env message" "$out" "scripts/dev.env not found -- run /webapp-uat setup"

echo "== engine: dev.env without START_COMMAND"
printf "PORT='1'\n" > "$P/scripts/dev.env"
out="$(bash "$ENGINE" wait-ready 2>&1)"; rc=$?
expect_eq "no START_COMMAND exit code" "$rc" "1"
expect_contains "no START_COMMAND message" "$out" "START_COMMAND is not set in scripts/dev.env -- run /webapp-uat setup"

echo "== engine: neither PORT nor READY_COMMAND"
printf "START_COMMAND='sleep 5'\n" > "$P/scripts/dev.env"
out="$(bash "$ENGINE" start 2>&1)"; rc=$?
expect_eq "no PORT exit code" "$rc" "1"
expect_contains "no PORT message" "$out" "PORT (or READY_COMMAND) is not set in scripts/dev.env -- run /webapp-uat setup"

echo "== engine: start / wait-ready / stop against a throwaway HTTP server"
if command -v python3 >/dev/null 2>&1; then
  FREE_PORT="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1])')"
  cat > "$P/scripts/dev.env" <<EOT
START_COMMAND='python3 -m http.server $FREE_PORT --bind 127.0.0.1'
PORT='$FREE_PORT'
WAIT_TIMEOUT='20'
EOT
  out="$(bash "$ENGINE" start 2>&1)"; rc=$?
  expect_eq "start exit code" "$rc" "0"
  expect_contains "start message" "$out" "Started (pid"
  expect_file "pidfile written" "$P/.webapp-uat.pid"
  out="$(bash "$ENGINE" wait-ready 2>&1)"; rc=$?
  expect_eq "wait-ready exit code" "$rc" "0"
  expect_eq "wait-ready message" "$out" "Ready"
  out="$(bash "$ENGINE" start 2>&1)"
  expect_contains "second start reports already running" "$out" "Already running"
  out="$(bash "$ENGINE" stop 2>&1)"; rc=$?
  expect_eq "stop exit code" "$rc" "0"
  expect_eq "stop message" "$out" "Stopped"
  expect_no_file "pidfile removed" "$P/.webapp-uat.pid"
  sleep 1
  if curl -sf "http://127.0.0.1:$FREE_PORT" >/dev/null 2>&1; then fail "server actually stopped"; else ok "server actually stopped"; fi
  expect_file "dev.log written" "$P/dev.log"
else
  echo "  skip python3 not available — HTTP server case not run"
fi

echo "== engine: READY_COMMAND replaces the port poll; env WAIT_TIMEOUT wins"
cat > "$P/scripts/dev.env" <<'EOT'
START_COMMAND='sleep 30'
READY_COMMAND='true'
WAIT_TIMEOUT='7'
EOT
out="$(bash "$ENGINE" start 2>&1)"
expect_contains "start (ready-command case)" "$out" "Started (pid"
out="$(bash "$ENGINE" wait-ready 2>&1)"; rc=$?
expect_eq "ready via READY_COMMAND" "$out" "Ready"
expect_eq "ready exit code" "$rc" "0"
bash "$ENGINE" stop >/dev/null 2>&1
cat > "$P/scripts/dev.env" <<'EOT'
START_COMMAND='sleep 30'
READY_COMMAND='false'
WAIT_TIMEOUT='7'
EOT
out="$(WAIT_TIMEOUT=1 bash "$ENGINE" wait-ready 2>&1)"; rc=$?
expect_eq "timeout exit code" "$rc" "1"
expect_contains "env override used (1s, not 7s)" "$out" "Timed out after ~1s"

echo "== engine: wait-ready timeout names the port"
cat > "$P/scripts/dev.env" <<'EOT'
START_COMMAND='sleep 30'
PORT='1'
EOT
out="$(WAIT_TIMEOUT=1 bash "$ENGINE" wait-ready 2>&1)"; rc=$?
expect_eq "port timeout exit code" "$rc" "1"
expect_contains "port timeout message" "$out" "waiting for localhost:1"

echo "== engine: usage"
out="$(bash "$ENGINE" bogus 2>&1)"; rc=$?
expect_eq "usage exit code" "$rc" "1"
expect_contains "usage message" "$out" "{start|stop|wait-ready}"

echo "== --apply never touches project-owned files"
printf "START_COMMAND='x'\nPORT='1'\n" > "$P/scripts/dev.env"
cp "$P/scripts/dev.env" "$S/dev.env.before"
mkdir -p "$P/uat/scenarios" && printf 'mine\n' > "$P/uat/scenarios/my-scenario.md"
bash "$SYNC" "$P" --apply >/dev/null 2>&1
expect_same "dev.env untouched by apply" "$S/dev.env.before" "$P/scripts/dev.env"
expect_eq "other scenarios untouched" "$(cat "$P/uat/scenarios/my-scenario.md")" "mine"

echo "== --print reads a bundled file"
out="$(bash "$SYNC" --print USAGE.md 2>&1)"; rc=$?
expect_eq "print exit code" "$rc" "0"
expect_eq "print content matches bundled file" "$out" "$(cat "$SKILL/USAGE.md")"
bash "$SYNC" --print ../../../etc/hosts >/dev/null 2>&1; rc=$?
expect_eq "print rejects .. paths" "$rc" "2"
bash "$SYNC" --print /etc/hosts >/dev/null 2>&1; rc=$?
expect_eq "print rejects absolute paths" "$rc" "2"
bash "$SYNC" --print nope.md >/dev/null 2>&1; rc=$?
expect_eq "print missing file exits 2" "$rc" "2"

echo "== usage errors"
bash "$SYNC" "$P" >/dev/null 2>&1; rc=$?
expect_eq "missing mode exits 2" "$rc" "2"
bash "$SYNC" "$P" --bogus >/dev/null 2>&1; rc=$?
expect_eq "unknown mode exits 2" "$rc" "2"

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL PASSED ($PASS checks)"
  exit 0
else
  echo "$FAIL FAILED, $PASS passed"
  exit 1
fi
