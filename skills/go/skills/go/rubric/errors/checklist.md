# rubric / errors / checklist — error handling smells → fixes

| Smell | Fix |
|---|---|
| `if err.Error() == "not found"` (string match) | Sentinel `var ErrX = errors.New(...)` + `errors.Is`; typed error + `errors.As` for structured detail |
| Bare `return err` that loses context | `fmt.Errorf("doing X: %w", err)` — but add *new* context, don't repeat the inner error |
| `%w` at an RPC/storage boundary (leaks internals) | `%v` at boundaries; `%w` only *inside* the package/app |
| Redundant context (`"could not open settings.txt: %v"` when the path is already in the error) | Add only what the inner error lacks |
| `else` after `if err != nil { return }` | Handle the error first; keep the happy path at the left margin |
| Logging **and** returning the same error | Do one or the other — both duplicates noise up the stack |
| Exported func returns a concrete `*MyError` | Return the `error` interface (a concrete-typed nil is a non-nil interface trap) |
| Only the last error survives a fallback chain | `errors.Join(errs...)` |
| `panic` on bad input | Return an error; in a library, recover at the API boundary and convert |
| `Must…` on runtime/user input | `Must` only for package-init constants (`regexp.MustCompile`) |
| Capitalised / trailing-period error string | lowercase, no punctuation (it composes mid-sentence) |
| `%s`/`%v` for a string value in an error | `%q` — shows empty strings + escapes clearly |
| Sentinel/type errors named inconsistently | Sentinel vars: **`Err`-prefix** (`ErrNotFound`); custom error types: **`-Error` suffix** (`PathError`) |
| Ad-hoc `Err*` sentinels in an ecosystem with a structured errors kit | Use the kit's codes (`errors.New(errors.Timeout, …)`, `errors.Has(err, code)`) — the `Err`-prefix convention is for plain stdlib errors |
| `%w` placement arbitrary | `fmt.Errorf("context: %w", err)` — `%w` at the **end** for an annotation chain; at the **start** when wrapping a sentinel for a category |
| `log.Fatal`/`os.Exit` deep in library code | Return the error; `log.Fatal`/`log.Exit` only in `main` for unrecoverable startup, with an actionable message |
| Ignoring an error with `_` and no reason | Handle it, or add a comment justifying why it's safe to drop |
