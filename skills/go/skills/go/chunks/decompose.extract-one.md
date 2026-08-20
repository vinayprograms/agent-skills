# decompose.extract-one — extract ONE package (unattended sub-agent entry)

You are a **fresh sub-agent** with a clean context. You extract exactly **one** Go package, return a
record, and STOP. You have **no user**. The architecture (DAG, boundaries, graduation) is already
agreed — you work strictly inside the brief the orchestrator gave you. This is your bounded world:
do the chain below and nothing beyond it. (Skill traversal rule still applies: load one chunk at a
time, follow its `## Next`.)

## Your brief gives you
- the package name + its single responsibility
- **allowed imports** = the exact exported APIs of its already-extracted dependencies (verbatim)
- **contracts to satisfy** = consumer-declared interfaces this package owns
- target call-site + graduation (kit vs app)

## Bounded chain — in order, then STOP
1. Design the boundary to the brief's call-site. → `design.kit-boundary.md` (mode: **unattended** —
   the envelope is agreed; do NOT seek user confirmation).
2. Implement to it. → `implement.md`
3. Verify. → `verify.md`
4. Adversarial simplify of **this package's diff only**. → `simplify.md`
5. Return your record and stop. Do NOT document the whole project, re-triage, or start another
   package — those are the orchestrator's job.

## Produces (the ONLY thing the orchestrator consumes — it is mechanically checked)
A **Package record**:
```
- API: <exported signatures>
- call-site: <usage line>
- declares: <consumer interfaces this package declares>
- imports: <actual imports>          # orchestrator diffs this vs allowed; widening is rejected
- amendment?: <a dep/boundary change you needed but could NOT make inside the brief — name it>
- note: <responsibility moves, etc.>
```
If you cannot satisfy the brief without a new dependency or a boundary change, do **not** improvise —
put it in `amendment?` and stop. The DAG belongs to the orchestrator and the user, not to you.

## Next
- Terminal. Return the record to the orchestrator (`decompose.iterate.md` integrates and validates it).
