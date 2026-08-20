# decompose.iterate — thin orchestrator: one fresh sub-agent per package

The loop hub. Its whole job is to **stay small**: it holds only the Ledger, never package source or
diffs. Each package is extracted in a **fresh sub-agent** with a clean context window, so the
orchestrator's context stays flat across all N packages. That flatness is the point — it's what
defeats context rot over a long decomposition.

## Steps
1. **Read only the Ledger** (`<repo>/.go-decompose/ledger.md`). Not the prior conversation.
2. **Pick the next package**: the first `[ ]` whose deps are all `[x]`. If none qualify but `[ ]`
   remain, the DAG is wrong — record an Amendment and reorder.
3. **Confirm ground truth**: `go build ./...` is green at `last-green-sha`. (Re-derive state from the
   repo, don't trust memory.)
4. **If the next node is the app/residual** (graduation = app, deps = all), it has no exported API —
   don't spawn an extractor. Go to `decompose.wire-app.md` (attended, main thread).
5. **Assemble the brief** for this package (small, self-contained):
   - package name + its single responsibility (from the DAG)
   - **allowed imports** = exactly its done-deps' Exported APIs from the Ledger (verbatim signatures)
   - **contracts to satisfy** = any open Cross-package contract this package owns
   - the target call-site / graduation
   - the unattended contract + the skill traversal rule (it bootstraps at `decompose.extract-one.md`)
6. **Spawn one fresh sub-agent** bootstrapped at `decompose.extract-one.md` with that brief. It runs
   the bounded chain in its own window, never loads the orchestrator's context, and returns ONLY a
   Package record.
7. **Mechanically validate the return — do not eyeball it.** Reliability lives here, not in trusting
   the sub-agent:
   - `go build ./...` and `go test ./... -race` — green (compiler/tests, not judgment).
   - **Import-diff**: inspect the new package's actual imports; if they exceed the brief's allowed
     set, **reject** (that seeds a future cycle) and either re-spawn or treat as an amendment.
   - **Schema check**: every required record field present; else reject and re-ask.
   - If the sub-agent returned an `amendment?`, do NOT silently accept — it changes the envelope.
7b. **Different-lens conformance verify (high-stakes gate).** The mechanical checks prove the package
   *compiles and passes*; they do NOT prove it *followed the skill*. Spawn a **fresh verifier
   sub-agent** — NOT the editor that wrote it — to audit the package's diff against the skill
   (SANCTIONED / OVER-REACH / MISREAD / MISSING: gateway applied where rule 1 demands? package doc?
   exported-API tests? naming?). Lens diversity is the active ingredient — a clone of the editor
   shares its blind spots. If it finds a real violation, bounce back to a fresh editor with the
   finding and re-run 7–7b. **Bounded: after 2 rounds without convergence, stop and escalate to the
   user** — never loop forever, never accept a convergence the agents reached only by sharing the
   same misreading.
8. **Integrate** the validated record into the Ledger: append it, flip `[ ]`→`[x]`, update Exported
   APIs + Cross-package contracts.
9. **Commit** the green package; write the new `last-green-sha`. Loop.

Loop termination is the **orchestrator's** decision (all `[x]`), never a sub-agent's — a sub-agent
that wanders cannot end or corrupt the decomposition.

## Produces
Updated Ledger: one more package `[x]`, its API + contracts recorded, repo committed green.

## Next
- Packages remain → loop (back to step 1; spawn the next sub-agent)
- Next node is the app/residual → `decompose.wire-app.md`
- Sub-agent returned an `amendment?` (missed dep / boundary change) → `decompose.md` (amend the DAG + re-confirm the changed envelope with the user)
- Sub-agents are unavailable in this harness → `decompose.checkpoint.md` (single-thread fallback)
- All packages `[x]` and green → `document.md` (final pass: package docs across the new kit)
