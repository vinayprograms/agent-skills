# refactor.unit — refactor ONE unit, unattended, behavior-preserving

You are a fresh sub-agent with a clean context. You apply one intended fix to **one unit**, preserve
its invariants, return a record, and STOP. No user. The plan is already agreed — you work strictly
inside the brief. (Skill traversal rule applies: one chunk at a time, follow `## Next`.)

## Your brief gives you
- the unit's intended fix (the smell → the change)
- **allowed files** — touch nothing else
- **behavior to preserve** — error semantics, concurrency, tested behavior (keep the tests green)
- **intended API/name changes** for this unit (may be none) — the only exported changes you may make

## Bounded chain — in order, then STOP
1. Apply the fix to the allowed files only. Preserve behavior. You may make the brief's *intended*
   API/name changes (and you must update their call-sites in your allowed files) — but make no OTHER
   exported-signature change, don't redesign the API, don't refactor neighbours. For a sanctioned
   rename, pick the name via `../rubric/naming/gauntlet.md`.
2. Verify. → `verify.md`
3. Adversarial simplify of **this unit's diff only**. → `simplify.md`
4. Return your record and stop. Don't document the whole project, re-triage, or start another unit.

## Produces (mechanically checked by the orchestrator)
A **unit record**:
```
- changed: <what, in which allowed files>
- call-sites touched: <list>
- invariants: held  (or:  CANNOT-PRESERVE: <which invariant + why>)
```
If you cannot make the fix without breaking an invariant, do NOT force it — return
`CANNOT-PRESERVE: …` and stop. The orchestrator and user decide.

## Next
- Terminal. Return the record to the orchestrator (`refactor.iterate.md`).
