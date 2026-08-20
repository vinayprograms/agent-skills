# rubric / testing / checklist — test smells → fixes

| Smell | Fix |
|---|---|
| Ad-hoc repeated test bodies | **Table-driven** via `t.Run(tt.name, …)`; field-named case structs |
| Failure message lacks context | `Func(%q) = %v, want %v` — name the func, the input, **got before want** |
| Diff direction unlabeled | `cmp.Diff(want, got)` → label `(-want +got)`; use `cmp`/`cmpopts`, **not** `reflect.DeepEqual` or testify |
| `t.Fatal` inside a table loop | `t.Error` continues to the next case; `t.Fatal` only when continuing is meaningless |
| `t.Fatal`/`FailNow` from a non-test goroutine | `t.Error` + return on the test goroutine |
| Helper reports its own line on failure | `t.Helper()`; prefer helpers that **return values** over taking `*testing.T` |
| Manual temp dir / resource cleanup | `t.TempDir()`, `t.Cleanup(...)` |
| Mocking the HTTP client | `httptest.NewServer`; prefer real transports to hand-written mocks |
| Heavy mock-generation / BDD frameworks | Simple manual fakes via implicit interfaces — Go testing is just Go programming |
| Only the happy path tested | Test error/edge/malformed paths aggressively — that's where bugs hide (partitions, boundaries) |
| External integration (LLM/HTTP/DB) tested on success only | Fake every response pattern: success, error, empty, malformed; verify fail-closed on the unexpected |
| Coverage crusade on a small fix | Cover the exported API's success+error+edge; justify gaps — but **match effort to the change** (a one-line fix needs its regression test, not 100%) |
| Parallelizable tests run serially | `t.Parallel()` where independent |
| `context.Background()` in a test | `t.Context()` (1.24) — canceled automatically when the test ends |
| Classic `for i := 0; i < b.N; i++` benchmark loop | `for b.Loop()` (1.24) — more accurate, defeats dead-code elimination |
| `time.Sleep` to wait for goroutines/timeouts | `testing/synctest` (1.25) — fake clock, deterministic; or channels/sync |
| Large inputs/outputs inline in the test file | **Golden files** in `testdata/` (ignored by the go tool) |
| Hardcoded `os` calls deep in the logic under test | A filesystem seam — consumer-defined narrow interface or `afero.Fs`; inject an in-memory fs |
| Env-var dependent test mutating the process env | `t.Setenv` — auto-restored, guards against `t.Parallel` misuse |
| CLI tested via compiled binary + `os/exec` | In-memory through the command factory — see `../../reference/cli.md` |
