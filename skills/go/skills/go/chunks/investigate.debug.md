# investigate.debug — find the fault's root cause

Goal-specific read for a **fault**. Entry point is the **symptom**, and you work **backward** to the
cause. Hypothesis-driven, not a full read.

## Steps
0. **Suspect the code, never the toolchain.** `go run`/`go build`/`go test` and the build cache do
   not lie; a persisting error means the edit didn't fix the logic, hit the wrong place, or missed a
   second call site — see `../reference/debugging.md` before proposing any tool-level intervention.
1. **Start at the symptom.** A failing test, a panic stack, wrong output. Reproduce it first — a bug
   you can't reproduce, you can't confirm you fixed.
2. **Form falsifiable hypotheses.** 2–3 candidate causes, each one you can cheaply prove or kill.
3. **Trace the suspect path only.** Walk control + data flow from the symptom back toward the cause:
   state mutation, error wrapping/swallowing, and for concurrency — goroutine interleavings, channel
   direction, lock ordering, races (`-race`). To observe the path, pick the cheaper instrument: a
   temporary `t.Log`/print, or **live inspection with delve** (`../reference/delve.md` — scriptable
   `dlv test`/`dlv trace` invocations) when one live look at real state beats N print-recompile
   loops (deep structs, long repros, third-party internals). Whatever delve reveals, encode as the
   failing repro — the session itself proves nothing durable.
4. **Confirm.** A hypothesis is the root cause only when it explains **all** observed symptoms, not
   just the first. Reject hypotheses that explain some-but-not-all.

## Termination
Stop when one confirmed hypothesis explains every symptom and you have a minimal reproduction.

## Produces
A **diagnosis**: root cause + the suspect execution path + a failing repro that pins it.

## Next
- It's a small, local fix → `fix.md` (and write the repro as the regression test there).
- The root cause is a design flaw / a responsibility in the wrong place / a boundary issue →
  escalate: `triage.md` (→ refactor / extract).
- The user only wanted the diagnosis (not a fix) → report the root cause + repro and stop (terminal).
