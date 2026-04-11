# Error Handling

## Rules

1. **Errors are values — program with them.** Use `errors.Is()` and `errors.As()` for inspection. Never match error strings.
   ```go
   var ErrNotFound = errors.New("not found")
   if errors.Is(err, ErrNotFound) { ... }
   ```

2. **Wrap with `%w` inside, `%v` at boundaries.** `%w` preserves the chain for `errors.Is`/`errors.As`. `%v` hides internals at RPC/storage boundaries.
   ```go
   return fmt.Errorf("loading config: %w", err)   // inside app
   return fmt.Errorf("database unavailable: %v", err)  // at boundary
   ```

3. **Add context, not redundancy.** Don't repeat what the inner error says.
   ```go
   // GOOD — adds new context
   return fmt.Errorf("launch codes unavailable: %v", err)
   // BAD — file path already in os.Open error
   return fmt.Errorf("could not open settings.txt: %v", err)
   ```

4. **Handle error case first — happy path at left margin.** Early return, no `else` after error check.
   ```go
   x, err := f()
   if err != nil {
       return err
   }
   // use x — at left margin
   ```

5. **Don't log errors you return.** One or the other. Both causes duplicate noise up the chain.

6. **Exported functions return `error`, not concrete error types.** Returning `*MyError` creates a nil-interface trap.

7. **Rich error types for structured context.** When callers need to inspect error details programmatically.
   ```go
   type PathError struct {
       Op   string
       Path string
       Err  error
   }
   ```

8. **`Must` functions only at program startup.** `template.Must`, `regexp.MustCompile` — never on user input.

9. **Collect all errors in fallback chains.** `errors.Join(errs...)` — the consumer needs the full picture.

10. **Don't panic.** Never for normal error handling. In libraries, recover at the API boundary and convert to errors.

## Anti-Patterns

| Smell | Fix |
|---|---|
| `if err.Error() == "not found"` | Sentinel errors + `errors.Is` |
| Logging AND returning an error | Do one or the other |
| `func Open() (*File, *PathError)` | Return `error` interface, not concrete type |
| `panic` on invalid input | Return error |
| Only reporting last error in fallback | `errors.Join` all errors |
| `%w` at system boundary | Use `%v` to hide internals |
| Error string "Could not open settings.txt" | Don't repeat info the inner error has |
| Capitalized error string | Lowercase, no trailing punctuation |
