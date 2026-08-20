# migrate.unit — re-point ONE consumer package (unattended)

Fresh sub-agent: re-point one consumer package onto the new dependency API, return a record, STOP. No
user — work strictly inside the brief and the unattended gate protocol (record assumptions, don't ask).

## Your brief
- the consumer package + its old→new symbol mapping
- the classification: **re-point** / **in-source-verbatim** / **dropped**
- the behaviour invariant (tests to keep passing)

## Bounded chain — then STOP
1. **re-point:** update imports + call-sites to the new API shape. Apply the rubric **at the call
   site** (how *you consume* the kit — naming, error handling), but do **not** redesign the dependency.
2. **in-source / verbatim:** copy the removed capability's code into the consumer (or a new internal
   package). **PRESERVE IT VERBATIM.** Do **NOT** run the `simplify` lens over foreign code mid-
   migration — it would redesign working code while the module is red. Record any smells you notice
   into a **`parked-smells`** list in your record for the post-green cleanup pass; do not fix them now.
3. **dropped:** delete the dead usage.
4. Stay inside the brief's package(s). Record any **assumption** you had to make (no user to ask).
5. Return your record + stop. Do not document the whole repo, re-triage, or start another unit.

## Produces (mechanically checked by the orchestrator)
A record: `{ package, what changed, old→new applied, in-sourced files, parked-smells, assumptions,
build-error delta }`. If a symbol can't be mapped without a redesign, return
`needs-redesign: <what>` and stop.

## Next
- Terminal. Return the record to `migrate.iterate.md`.
