# migrate.plan — unit = consumer package; write the red-baseline ledger

Plan a migration too big for one pass. Three things differ from `refactor.plan`: the **unit is a
consumer package** (cross-cutting API drift makes sub-package units pointless), the baseline is
**red**, and the ledger tracks an **error count that must only shrink**.

## Steps
1. **Units = consumer packages.** Each tagged with its classification mix (re-point / in-source /
   preserve-verbatim). Do **not** split below package granularity — once a dependency type changes
   shape, the whole consuming package moves together.
2. **Order** so each finished unit removes its share of build errors without depending on a
   not-yet-migrated unit's new shape: shared/low-level consumers first, their dependents after.
3. **Write the migration Ledger** (`<repo>/.go-migrate/ledger.md`). NON-OPTIONAL sections: the
   **red-baseline error count**, the **unit table** (with per-unit classification), **per-unit
   records**, and an **assumptions log**. For an unattended run, **COMMIT the ledger** (do not
   gitignore it) so the assumptions ride with history and stay revertable.
4. **Agree the envelope** (units + old→new mapping + in-source decisions) with the user.
   **Headless fallback (the unattended gate protocol):** if no user is present, record each
   assumption + its rationale in the ledger, **commit it**, proceed, and **surface every assumption in
   the final report** for review. Don't block on a user who isn't there.

## Produces
The migration ledger + the recorded red baseline.

## Next
- Envelope agreed (or assumptions recorded) → `migrate.iterate.md`.
- Splitting reveals a removed capability needs redesign, not verbatim in-sourcing → `triage.md`
  (→ new / extract).
