# refactor.iterate — thin orchestrator: one sub-agent per unit, behavior preserved

The loop hub for a large refactor. Holds only the ledger; each unit runs in a fresh sub-agent so the
orchestrator's context stays flat. The defining check here is **behavior preservation** — the public
API and tests must be identical after each unit.

## Steps
1. **Read only the ledger** (`<repo>/.go-refactor/ledger.md`).
2. **Pick the next `[ ]` unit** whose ordering is satisfied. Confirm `go build` green at `last-green-sha`.
3. **Assemble the brief**: the unit's intended fix, its allowed files, the **behavior to preserve**,
   and any **intended API/name changes** for this unit (so the sub-agent knows a sanctioned rename
   from an accidental one).
4. **Spawn one fresh sub-agent** bootstrapped at `refactor.unit.md` with that brief + the skill
   traversal rule. It returns only a unit record.
5. **Mechanically validate — do not eyeball:**
   - `go build ./...` + `go test ./... -race` green (behavior preserved; build green also proves the
     call-sites were updated to match any rename).
   - **No UNINTENDED API drift**: diff the touched packages' exported symbols (`go doc` / API dump)
     before vs after; every change must be in the brief's *intended* set. An exported change that
     wasn't sanctioned → **reject**. (Sanctioned renames are fine — refactor preserves behavior, not
     necessarily the API surface.)
   - **Scope guard**: only the unit's allowed files changed; else reject.
5b. **Different-lens conformance verify (high-stakes gate).** Mechanical checks prove behavior held;
   they don't prove the unit *followed the skill*. Spawn a **fresh verifier sub-agent** — NOT the
   editor — to audit the unit's diff against the skill (SANCTIONED / OVER-REACH / MISREAD / MISSING).
   On a real violation, bounce to a fresh editor with the finding and re-run 5–5b. **Bounded: 2 rounds
   without convergence → stop and escalate to the user.** Don't accept a convergence the two agents
   reached by sharing the same misreading.
6. **Integrate** the record, flip `[ ]`→`[x]`, **commit**, update `last-green-sha`. Loop.

Loop termination is the orchestrator's (all `[x]`), never a sub-agent's.

## Produces
Updated ledger: one more unit `[x]`, behavior preserved, repo committed green.

## Next
- Units remain → loop (back to step 1)
- **A unit can't be done as a refactor** — it needs a boundary to MOVE (→ extract/decompose) or it's
  actually a bug (→ debug): **stop the whole sweep and re-triage, immediately.** The plan is now known
  wrong and later units may depend on the change, so do NOT continue the remaining units. The units
  already done stay committed (green, still valid); the re-routed route reads the *current* code as
  its ground truth — no ledger handoff needed. Tell the user why. → `triage.md`
- All units `[x]` and green → `document.md`
