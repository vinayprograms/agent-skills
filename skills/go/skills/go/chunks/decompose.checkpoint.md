# decompose.checkpoint — compress + reset between packages (fallback)

Use this **only when the harness can't spawn sub-agents**, so the decompose loop runs in a single
thread. Without a fresh window per package, context grows; this chunk forces compression and reset
between iterations. Honest limitation: markdown can't *force* a harness to drop tokens — this works
only if the harness honors a compaction/clear instruction. Sub-agent mode (`decompose.iterate.md`)
is structurally stronger; prefer it.

## Steps
1. **Distill the just-finished package** into its Ledger Package record (API, call-site, declares,
   imports, note). Update Exported APIs + Cross-package contracts. Apply any Amendment.
2. **Commit** the green package; write `last-green-sha`.
3. **Drop the package's working context**: instruct a context compaction / clear now. Everything
   needed survives in the Ledger and the committed code; the transcript does not.
4. Hand back to the loop, which re-orients from the Ledger alone.

## Produces
Updated Ledger + committed package + a reset context.

## Next
- Re-enter the loop → `decompose.iterate.md` (it re-reads only the Ledger)
