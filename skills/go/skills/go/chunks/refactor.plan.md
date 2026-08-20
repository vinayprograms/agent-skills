# refactor.plan — split a large sweep into units + write the safety ledger

For a refactor too big for one context window (e.g. rework error handling across 40 files). Like
`decompose`, this is a separate machinery — but its ledger tracks **invariants to preserve**, not new
APIs. The user agrees the unit plan here (sub-agents then run unattended).

## Steps
1. **Break the sweep into units.** A unit = the smallest independently-greenable change (a file, a
   symbol and its call-sites, one responsibility move). Keep units small.
2. **Order to stay green.** Independent units first; sequence so each unit compiles + tests green on
   its own. No cross-unit dependency? Any order. Otherwise topological.
3. **Write the refactor ledger** (`<repo>/.go-refactor/ledger.md`, gitignored). NON-OPTIONAL
   sections: the **global invariants** (must hold across ALL units — exported API, error semantics,
   concurrency), the **unit status table**, and **per-unit records**.
4. **Agree the plan with the user** — the unit list + the invariants are the envelope the unattended
   loop runs on. Strawman to poke. **Headless fallback (no user present):** record each assumption +
   rationale in the ledger, **commit it** (a committed ledger keeps assumptions revertable — don't
   gitignore it in an unattended run), proceed, and surface every assumption in the final report.

## Ledger template
```
# Refactor Ledger — <module path>
## Invariants (must hold after EVERY unit)
- exported API of package X unchanged (signatures + names)
- sentinel errors ErrFoo/ErrBar preserved; %w chains intact
- <Type> stays safe for concurrent use
- baseline-sha / last-green-sha
## Units
1. [ ] errors.go: wrap bare returns        files: errors.go
2. [ ] store.go: dedupe retry logic        files: store.go, store_test.go
## Per-unit records (append-only)
### unit 1 — DONE (sha …)  changed: …  call-sites touched: …  invariants: held
```

## Produces
The refactor ledger.

## Next
- Plan agreed + ledger written → `refactor.iterate.md`
- It's actually small (one unit) → `refactor.propose.md`
- Splitting into units reveals the real work is a **boundary move** (a package wants to be born or
  split) → escalate: `triage.md` (→ extract/decompose)
