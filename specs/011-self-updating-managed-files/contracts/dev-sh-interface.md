# Contract: `scripts/dev.sh` (engine) and `scripts/dev.env` (values)

## Engine commands (unchanged interface)

| Command | Behavior | Exit |
|---|---|---|
| `start` | If `.webapp-uat.pid` names a live process: print `Already running (pid N)`, exit 0. Else `cd` to the project root (exit 1 if that fails), run `START_COMMAND` through `bash -c` (so `&&`, pipes, env prefixes and quoting all work), backgrounded in its own process group (job control on), output to `dev.log`; write the pid, print `Started (pid N)`. | 0 / 1 |
| `stop` | If a pidfile exists: SIGINT the job's whole process group (plus the pid and its direct children, for a pidfile written by an older engine), wait 2s; if the pid is still alive, SIGTERM the same set, wait 1s, then SIGKILL as the last resort; remove the pidfile. Then, if `STOP_COMMAND` is set, run it from the project root. Print `Stopped`. | 0 |
| `wait-ready` | Poll once per second up to `WAIT_TIMEOUT` times: `READY_COMMAND` (exit 0 = ready) if set, else `curl -sf http://localhost:$PORT`. Print `Ready` / `Timed out after ~Ns waiting for ...`. | 0 / 1 |
| anything else | `Usage: … {start|stop|wait-ready}` | 1 |

## Resolution order at startup

1. `PROJECT_DIR` = the directory above the script's own directory (`scripts/..`).
2. Capture any per-run `WAIT_TIMEOUT` from the environment.
3. `scripts/dev.env` must exist → else print
   `scripts/dev.env not found -- run /webapp-uat setup` and exit 1.
4. Source `scripts/dev.env`.
5. `START_COMMAND` must be non-empty → else
   `START_COMMAND is not set in scripts/dev.env -- run /webapp-uat setup`, exit 1.
6. `PORT` or `READY_COMMAND` must be non-empty → else
   `PORT (or READY_COMMAND) is not set in scripts/dev.env -- run /webapp-uat setup`, exit 1.
7. `WAIT_TIMEOUT` = env override, else `dev.env` value, else 30.

Steps 3–6 run before the command dispatch, so every command fails the same way on a
missing/invalid values file.

*(Amended 2026-09-28, D14: `bash -c` + process group for `start`, group signalling for
`stop`. Interface, messages and exit codes unchanged.)*

## Managed marker

Line 1 shebang, line 2:
`# webapp-uat managed file -- do not edit; overwritten on skill update; remove this line to take ownership`

## `scripts/dev.env` schema

See `data-model.md` (Values file). Bash-sourceable `KEY=value` lines; single or
double quotes both fine; comments allowed. Written by Setup (proposal →
confirmation) or legacy migration; never by any automatic step. Committed to the
project.

Example (the bundled `templates/dev.env.example` documents each key inline):

```
START_COMMAND='npm run dev'
# STOP_COMMAND='docker compose down'
PORT='3000'
# WAIT_TIMEOUT='60'
# READY_COMMAND='curl -sf http://localhost:3000/api/health'
```
