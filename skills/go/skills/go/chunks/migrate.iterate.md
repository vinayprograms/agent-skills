# migrate.iterate — thin orchestrator; red baseline, monotonic shrink

Loop hub for a migration. The whole-module build is **RED until the last unit**, so the per-unit gate
is NOT "module green" (that's unsatisfiable mid-migration) — it's **"the module's build-error count
strictly shrank, and nothing previously green regressed."**

## Steps
1. **Read only the Ledger.**
2. Pick the next **consumer-package** unit in order.
3. **Assemble the brief:** the unit's package, its slice of the old→new mapping, its classification
   (re-point / in-source-verbatim / dropped), the behaviour invariant, the unattended gate protocol,
   and — for verbatim units — the **preserve-verbatim instruction** (`migrate.unit.md`).
4. **Spawn one fresh sub-agent** bootstrapped at `migrate.unit.md`.
5. **Mechanically validate — red-baseline, not green:**
   - `go build ./...`: the **total error count strictly decreased** vs the ledger's current count, and
     **no previously-passing package newly fails**. If it didn't shrink → reject.
   - The unit's own package + its tests build/pass in isolation where its deps already allow.
   - **Scope guard:** only this unit's package(s) changed (plus any sanctioned in-sourced files).
     "Changed" = semantic change — gofmt may reformat whole files, that's fine, ignore whitespace.
   - **Different-lens verifier** (high-stakes): a fresh verifier audits the unit vs the skill; bounded
     2 rounds → escalate / record an assumption.
6. Integrate the record, update the error count, **commit (unit + ledger)**. Loop.
7. **When the error count hits zero:** run the full `verify.md` gate (whole-module
   gofmt/vet/build/`test -race` green) as final acceptance — THEN an optional **cleanup pass** over
   the in-sourced/verbatim code, fixing the `parked-smells` the preserve-verbatim mode deferred.

Loop termination is the orchestrator's: error count 0 **and** final `verify.md` green.

## Produces
Updated ledger; the module's error count reduced; repo committed per unit.

## Next
- Errors remain → loop (back to step 1).
- A unit reports a removed capability needs redesign → `triage.md` (→ new / extract).
- Error count 0 + final verify green → `document.md` (then the parked-smells cleanup pass).
