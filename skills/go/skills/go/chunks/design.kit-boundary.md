# design.kit-boundary — design the kit's API from its call-sites

Turn the proposed boundary into the **keystone artifact**: the ideal call-site snippet. Design from the consumer inward. House style: **propose, don't ask** — show a concrete strawman and let the user poke it.

## Steps
1. **Write the ideal call-site first.** How will the app consume the kit? e.g. `client, err := agent.New(cfg)`. Read it aloud — does it flow, or stumble? The snippet is the design; the implementation will serve it.
2. **Invert the dependencies.** The app declares the narrow interface it needs; the kit satisfies it. The kit imports nothing app-specific.
3. **Strip app assumptions.** A kit serves diverse consumers — don't bake in one app's architecture.
4. **Be willing to shrink or kill it — this is the moment to do it.** If the "kit" is really a 3-line helper + a struct, say so out loud and don't make a package. Talking the work *down* is a valid, good outcome. But this is a **boundary-time** decision: once you commit to shipping a reusable package, its primary type gets the gateway interface (`../rubric/api-design/interfaces.md` rule 1) regardless of size — you don't get to drop the interface later for being "too small."
5. **Confirm the snippet with the user** before implementing — *unless* you are running **unattended**
   as a `decompose` sub-agent (`attended=false`), where the envelope (DAG + boundaries) is already
   user-agreed: skip confirmation and proceed. In that mode you never re-confirm a routine snippet;
   you only surface a *contract or DAG change* as an `amendment?` in your record.

6. **Record the decision** (`../rubric/decisions.md`): the kit's boundary, its call-site, what does
   NOT belong, the graduation, and any rejected shape. (Attended path; an unattended sub-agent records
   its decision in the brief's record instead, and the orchestrator persists it.)

## Produces
The **ideal call-site snippet(s)** + a short **design-intent**: constraints, what does NOT belong, the app-vs-kit decision — persisted as a decision zettel.

## Next
- Snippet agreed (or envelope-fixed in unattended mode) → `implement.md`
- Not worth a package after all — **attended** → escalate back: `triage.md`; **unattended sub-agent** → record an `amendment?` and return to the orchestrator (never re-triage)
- Naming the exported API → resolve each name via `../rubric/naming/gauntlet.md`, then `implement.md`
