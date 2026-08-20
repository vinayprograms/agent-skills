# reference / delve — live runtime inspection (scriptable, never interactive)

Delve closes the loop tests can't: inspecting **actual runtime state** — deep structs, live
goroutines, third-party internals, state only reachable mid-session — in one run instead of N
print-recompile round-trips. It is an **escalation and a graduated verification tool**, not a
default step; the durable proof of behavior is still a test. After delve reveals the truth,
**encode it as a regression test**.

Availability: `command -v dlv || go install github.com/go-delve/delve/cmd/dlv@latest`

## When to use what

| Situation | Tool |
|---|---|
| Data race suspected | `go test -race` — not a debugger |
| Performance | pprof / benchmarks (`../chunks/benchmark.md`) |
| Simple logic question | A focused test or `t.Log` — cheaper than a session |
| Deep/nested state, long-running repro, third-party internals, mid-session-only state | **delve** |
| Confirm a fresh design's runtime path once (post-implement) | **`dlv trace`** over the new exported functions (see `../chunks/verify.md`) |

Escalation rule: reach for delve when **one live inspection beats N print-recompile loops**.
Otherwise don't.

## Agent-shaped invocations (always `--init` script or `trace`; never the REPL)

```bash
dlv test ./pkg --init s.dlv -- -test.run TestX   # debug one test — the most common entry
dlv debug ./cmd/app --init s.dlv -- <args>       # build+debug a main package
dlv exec ./bin --init s.dlv -- <args>            # debug a prebuilt binary
dlv attach <pid> --init s.dlv                    # live process (script must end: detach / exit)
dlv core ./bin ./core                            # post-mortem on a core dump
dlv trace --regex 'mypkg\.(Parse|Load)' ./pkg    # function-call tracing w/ args — ZERO setup
```

`dlv trace` is the cheapest instrument: prints every call + args + return values of matching
functions while the program (or its tests) runs — often all a hypothesis needs.

## Init scripts

One command per line; **always end with `exit`** so the session terminates (add
`--allow-non-terminal-interactive=true` if dlv complains about a non-terminal stdin).

```
# s.dlv — stop-and-inspect
break mypkg.Handle
condition 1 req.ID == "x-42"
continue
print req
locals
stack
goroutines -with-user
exit
```

```
# s.dlv — non-stopping tracepoints (preferred in scripts: nothing blocks)
trace mypkg.Handle
on 1 print req.ID
continue
exit
```

Useful in scripts: `break` / `trace` (tracepoint: prints, doesn't stop) · `condition <n> <expr>` ·
`on <n> <cmd>` (attach actions: `print`, `stack`) · `print` / `locals` / `args` · `watch -w <expr>`
(write watchpoint — who mutates this?) · `goroutines -with-user` / `goroutine <n> stack` (leak and
deadlock inspection) · `continue` / `next` / `step` / `stepout`.

## Discipline

- Read-only stance: inspect; don't `set` variables to force a pass — that's fabricating evidence.
- A delve finding is transient — it dies with the session. The chunk that sent you here says what
  to do next (usually: pin it as a failing test in `fix`, or fix the design and re-verify).
- Don't debug what `-race`, `go vet`, or the error message already tells you.
