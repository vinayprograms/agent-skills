# design.new — the front gate for new code

Greenfield code. The job here is NOT to start typing — it's to find the **right, smallest** thing to
build, designed from the call site. **Discovery is the default**: most users arrive vague, with an XY
problem, or with a wrong framing baked in. House style: **propose, don't quiz.**

## Steps
1. **Detect mode.** Does the user have a clear spec to *extract*, or are they *discovering* what they
   need? Assume discovery unless they clearly have the spec.
2. **Challenge the framing first (XY check).** What's actually breaking / needed? Don't build the
   thing they asked for if it solves the wrong problem. Reframe before collecting requirements.
3. **Propose a strawman call-site EARLY.** Show concrete usage — `cfg, err := config.Load()` — and
   let them poke it. People react ("no, per-tenant") far better than they spec cold. The snippet is
   the discovery instrument *and* the design artifact. If triage flagged a **domain leaf**
   (`../reference/cli.md`, `http.md`, `wails.md`, `files.md`), load it before proposing — the
   strawman must follow that domain's architecture (factory commands, service/adapter split, …).
   For project-layout questions, `../reference/packages.md`.
4. **Decide app vs kit.** App → concrete, pragmatic. Kit → the gateway rule
   (`../rubric/api-design/interfaces.md`): exported interface, unexported concrete, constructor
   returns the interface; consumer-defined interfaces for dependencies.
5. **Be willing to shrink or kill it.** The honest answer may be "you don't need a package — 3 lines
   and an env var." Talking the work *down* is the whole point of the gate.
6. **Confirm** the call-site snippet + the intent (constraints, what does NOT belong) before building.

7. **Record the decision.** Write a decision zettel (`../rubric/decisions.md`) capturing the call-site
   shape, the app-vs-kit call, **what does NOT belong**, and any rejected alternative. This is the
   keystone rationale — don't let it evaporate into the conversation.

## Produces
The **ideal call-site snippet** + design intent + the app/kit decision + a committed decision zettel.

## Next
- Snippet agreed → `implement.md` (then verify → simplify → document).
- It isn't worth building → say so and stop (or `advise.md` if they just need guidance).
- Naming the API → `../rubric/naming/gauntlet.md`, then `implement.md`.
