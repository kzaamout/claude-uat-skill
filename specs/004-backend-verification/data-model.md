# Data Model: Backend Verification

Conceptual entities this feature reasons about, not a schema it owns — it defines a
verification *contract* over whatever API/data store the target project already has.

## Discovered Verification Path

Established once per project by Phase 0.5 discovery, reused by every scenario's
backend verification rather than re-derived per run.

| Field | Notes |
|---|---|
| kind | `api` \| `direct-store` \| `none` |
| coverage | which data the API covers reads for (if `kind: api`), or which store is relevant (if `kind: direct-store`) |
| connection method | how discovery reaches it (e.g. an endpoint pattern, or a DB connection string source) |

**Validation rule**: when both `api` coverage and a `direct-store` fallback exist for
the same data, the `api` path MUST be preferred (`FR-002`) — `direct-store` is used
only when API coverage doesn't apply (`FR-003`).

## Backend Verification Result

The outcome of checking one scenario's claimed data change against the app's actual
backend state.

| Field | Notes |
|---|---|
| status | `confirmed` (backend matches UI claim) \| `discrepancy` (backend contradicts UI claim) \| `ui-only` (no store/API discoverable) \| `verification-failed` (the check itself couldn't complete) |
| path used | which Discovered Verification Path was used, or `none` for `ui-only` |
| note | required for `ui-only` (`FR-004`) and `verification-failed` (`FR-008`) — explains why full verification didn't happen |
| classification impact | `verification-failed` → test-environment problem, not an app defect (`FR-008`); `discrepancy` → surfaced explicitly, neither signal silently preferred (`FR-006`) |

**Validation rule**: this check is a read, never a write, and MUST NOT trigger the
DB-write confirmation gate (`FR-005`). MUST NOT be attempted at all when a scenario's
Expected Outcome names no backend data (`FR-007`).

**Multi-store limitation** (`FR-009`): when more than one discovered store is
plausibly relevant to a single outcome, `Backend Verification Result` still reflects
only the single primary path used — it is not a claim of full multi-store coverage,
and the finding must not represent it as such.
