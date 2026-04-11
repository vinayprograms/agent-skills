# Concurrency

## Rules

1. **Prefer synchronous functions.** Return results directly. Let the caller add concurrency by calling from a goroutine. Async-by-default is impossible for callers to undo.

2. **Make goroutine lifetimes obvious.** When you spawn a goroutine, make it clear when and whether it exits. Goroutines that block on channels can never be GC'd.

3. **Channels orchestrate; mutexes serialize.** Use channels for coordination between goroutines. Use mutexes when you just need serialized access to a shared resource.

4. **Specify channel direction.** `<-chan` for receive-only, `chan<-` for send-only. Prevents accidental misuse.
   ```go
   func sum(values <-chan int) int { ... }
   ```

5. **Buffered channels as semaphores.** Capacity N limits concurrency to N simultaneous operations.
   ```go
   var sem = make(chan struct{}, MaxOutstanding)
   func handle(r *Request) {
       sem <- struct{}{}
       defer func() { <-sem }()
       process(r)
   }
   ```

6. **Worker pool over goroutine-per-request.** Start fixed workers reading from a shared channel.

7. **Document concurrency safety.** Assume unsafe by default. Explicitly state when a type IS safe for concurrent use.
   ```go
   // Counter is safe for concurrent use.
   type Counter struct { ... }
   ```

8. **Context is always the first parameter.** Named `ctx`. Never store it in a struct.
   ```go
   func (s *Server) Handle(ctx context.Context, req *Request) error
   ```

9. **Types with sync.Mutex use pointer receivers.** And return pointers from constructors. Copying a mutex breaks it.

10. **Variable shadowing in conditional blocks.** `:=` in an inner scope creates a new variable. Use `=` to reassign the outer one.
    ```go
    // BAD — shadows ctx
    if cond {
        ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
        defer cancel()
    }
    // ctx is original here!
    ```

## Anti-Patterns

| Smell | Fix |
|---|---|
| Goroutine with no clear exit path | Document exit conditions; use context cancellation |
| Shared `httpClient` package var | Each instance owns its own client |
| Global mutex for per-instance state | Move mutex + state to instance fields |
| Async function that caller must synchronize | Return synchronously; let caller add `go` |
| Bidirectional channel in parameter | Restrict to `<-chan` or `chan<-` |
| `context.Context` stored in struct field | Pass as first parameter |
| Value receiver on type with sync.Mutex | Use pointer receivers |
