# rubric / concurrency / checklist — concurrency smells → fixes

| Smell | Fix |
|---|---|
| Async-by-default function the caller must synchronize | Return synchronously; let the caller add `go` (async can't be undone) |
| Goroutine with no clear exit path | Document when/whether it exits; use `context` cancellation (blocked goroutines never GC) |
| Using channels for simple shared-state access | Channels orchestrate; **mutexes serialize**. Pick the right one. |
| Bidirectional channel in a parameter | Restrict: `<-chan` (receive) / `chan<-` (send) |
| Unbounded goroutine-per-item fan-out | `errgroup.WithContext` + `g.SetLimit(n)`; plain `sync.WaitGroup.Go` (1.25) when errors don't propagate |
| Hand-rolled semaphore channel or static worker pool | `errgroup.SetLimit` — Go's scheduler doesn't need managed thread pools |
| Old `x := x` loop-variable capture | Delete — loop variables are per-iteration since 1.22 |
| Function-based atomics (`atomic.AddInt64(&n, 1)`) | Typed values: `var n atomic.Int64; n.Add(1)` (also `atomic.Bool`, `atomic.Pointer[T]`) |
| Background work tied to a request context | `context.WithoutCancel(reqCtx)` — detaches cancellation, keeps values |
| Type's concurrency safety unstated | Assume unsafe; document explicitly when safe: `// Safe for concurrent use.` |
| `context.Context` stored in a struct field | Pass as the first parameter, named `ctx`; never store it |
| Value receiver on a type containing `sync.Mutex` | Pointer receivers; return pointers from the constructor (copying a mutex breaks it) |
| `ctx, cancel := context.WithTimeout(ctx, …)` inside an `if` | `:=` shadows — the outer `ctx` is unchanged; use `=` to reassign |
| Shared package-var client/state | Each instance owns its own |
| `time.Sleep` in a test to "wait for a goroutine" | `testing/synctest` (1.25), channels, or explicit synchronization — see `../testing/checklist.md` |
