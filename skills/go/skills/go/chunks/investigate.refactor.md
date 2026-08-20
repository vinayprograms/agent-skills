# investigate.refactor — diagnose, size, and build the safety net

Goal-specific read for improving code **within existing boundaries**. Two jobs: find what's worth
fixing (adversarial diagnosis), and capture what must NOT change (the safety net). No edits yet.

## Steps
1. **Adversarially diagnose.** Read the target as a skeptic. List concrete smells, each = one
   intended fix: over-abstraction, a responsibility sitting on the wrong type *within these
   packages*, dead code, duplication, a fat interface (>2 methods), leaky/!wrapped errors, weak
   names. (This is diagnosing *existing* code — distinct from `simplify`, which critiques *your new*
   diff later.)
2. **Confirm the boundaries stay.** If fixing a smell needs a boundary to MOVE or a new package →
   stop, this is `extract`/`decompose`. If it's "why is this wrong" → it's `debug`. (See Next.)
3. **Capture what must be PRESERVED — and what's intentionally CHANGING.**
   - *Preserve (always):* observable **behavior** (the tests must still pass), error semantics
     (sentinels, `%w` chains), concurrency guarantees. Behavior preservation is the real invariant.
   - *Change (intentionally):* the **exported API / names are NOT frozen** — renaming a stuttering
     type or dropping `Get` is a normal refactor. But an API/name change is intentional and must
     (a) update **every** call-site in the impact set, and (b) if the package has external
     consumers, be flagged as a **breaking change** for the user to approve (see `refactor.propose`).
   List both sets explicitly so later steps know an intended rename from an accidental signature drift.
4. **Close the impact set.** Every consumer / call-site of what you'll touch.
5. **Size the work.** trivial (one symbol/file, mechanical) · medium (one package, attended) ·
   large (the impact set can't be held/edited in one pass without a ledger or sub-agents — key on
   that, NOT raw file count: a few tiny files are still medium).
   **Any breaking exported rename is at least medium → `refactor.propose` — never the trivial shortcut.**

## Produces
A **refactor plan**: `{ smell→fix list, invariants to preserve, impact set, size }`.

## Next
- A boundary must move / a new package appears → escalate: `triage.md` (→ extract/decompose)
- It's diagnosis, not a known improvement → escalate: `triage.md` (→ debug)
- **trivial** → `implement.md` (just do it; verify + the Stop hook guard behavior)
- **medium** → `refactor.propose.md`
- **large** (many units) → `refactor.plan.md`
