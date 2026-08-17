# Contract: Backend verification path selection & reporting

The decision contract for which verification path a scenario's backend check uses,
and how the result gets represented in the finding — not a network API.

Result status values referenced below (`confirmed` / `discrepancy` / `ui-only` /
`verification-failed`) are `data-model.md`'s `Backend Verification Result.status`
enum — used verbatim here rather than re-described in different words per section.

## 1. Path selection

**Trigger**: a scenario's Expected Outcome names data that should be created or
changed.

**MUST**: prefer the app's own API when Phase 0.5 discovery recorded API coverage for
the relevant data (`FR-002`). **MUST**: fall back to a direct read against the
discovered data store only when API coverage doesn't apply (`FR-003`). **MUST NOT**:
attempt this check at all when the Expected Outcome names no backend data (`FR-007`).
Result status on success: `confirmed`.

## 2. No path discoverable

**Trigger**: neither API coverage nor any data store was discoverable for the
relevant data.

**MUST**: record an explicit `ui-only` note in the finding (`FR-004`). **MUST NOT**:
error, block the run, or silently omit the check. Result status: `ui-only`.

## 3. Result reporting

**Trigger**: verification completes (successfully or not).

**MUST**: when the backend's actual state contradicts the UI's claim, surface this as
an explicit `discrepancy` in the finding — **MUST NOT** silently prefer either signal
(`FR-006`). **MUST**: when the verification step's own connection fails or times out
(distinct from a `discrepancy`), record result status `verification-failed` and
classify this as a test-environment problem, not an app defect (`FR-008`).

## 4. Multi-store disclosure

**Trigger**: more than one discovered store is plausibly relevant to a single
scenario's outcome.

**MUST**: verify against the single primary path Phase 0.5 discovery identified.
**MUST NOT**: represent this as full coverage across every plausibly relevant store —
this is a disclosed, known limitation (`FR-009`), not a silently narrowed claim.

## Invariant across all four

**MUST NOT**: trigger the DB-write confirmation gate — this entire contract governs
reads against already-written data, never a write this skill performs itself
(`FR-005`).
