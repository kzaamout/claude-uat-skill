#!/usr/bin/env bash
# Start/stop/wait-ready for Decker, wrapping run.sh + docker compose.
# Assumes run.sh brings up everything (including docker compose for backend/db)
# and only the frontend needs interrupting to stop — docker still needs an
# explicit `compose down` afterward, per how you shut it down manually.
#
# CONFIRM before relying on this:
#   - PORT below (guessed 3000 — adjust if the frontend serves elsewhere)
#   - that `run.sh` lives directly in DECKER_DIR

set -u

DECKER_DIR="/Users/kzaamout/Desktop/code/Decker"
PORT=3000
PIDFILE="$DECKER_DIR/.decker-uat.pid"

case "${1:-}" in
  start)
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "Already running (pid $(cat "$PIDFILE"))"
      exit 0
    fi
    cd "$DECKER_DIR" || exit 1
    nohup ./run.sh > dev.log 2>&1 &
    echo $! > "$PIDFILE"
    echo "Started (pid $!)"
    ;;
  stop)
    if [ -f "$PIDFILE" ]; then
      PID="$(cat "$PIDFILE")"
      # Ctrl+C equivalent — SIGINT is what an interactive terminal sends.
      kill -INT "$PID" 2>/dev/null
      sleep 2
      # If run.sh didn't forward SIGINT to its own children, this catches them.
      pkill -INT -P "$PID" 2>/dev/null
      rm -f "$PIDFILE"
    fi
    ( cd "$DECKER_DIR" && docker compose down )
    echo "Stopped"
    ;;
  wait-ready)
    for i in $(seq 1 30); do
      if curl -sf "http://localhost:$PORT" > /dev/null; then
        echo "Ready"
        exit 0
      fi
      sleep 1
    done
    echo "Timed out waiting for localhost:$PORT"
    exit 1
    ;;
  *)
    echo "Usage: $0 {start|stop|wait-ready}"
    exit 1
    ;;
esac
