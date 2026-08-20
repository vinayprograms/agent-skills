# document — doc comments + package doc

Document what the code now is. Terminal chunk for code-producing paths.

## Steps
1. Doc comments start with the declared name: `// New returns …`, `// Encode writes …`.
2. "reports whether" for boolean functions, not "returns true if".
3. **Package comment is MANDATORY for a kit:** `// Package x …` immediately before the `package` clause. A kit without one is incomplete — do not finish without it.
4. Document the contract: cleanup requirements (`Close()`), error conditions, concurrency safety (`// Safe for concurrent use.`).
5. Keep it to what a consumer needs — don't narrate the implementation.

## Produces
Documented code. **Done** — summarize for the user what changed and why, and **surface any decision
zettel(s) written so they get committed *with* the change** (an uncommitted zettel doesn't travel with
the repo — see `../rubric/decisions.md`).

## Next
- Terminal. Stop here, or return to `triage.md` if the user raises new work.
