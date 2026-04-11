# Testing

## Rules

1. **Drive to 100% coverage.** Every uncovered line either gets a test or a documented justification (OS errors, stdlib failures). Run `go test -coverprofile` and `go tool cover -func` after every change. Don't wait to be asked.

2. **Table-driven tests.** Systematic case enumeration via `t.Run()`. Each row maps to a partition, boundary, or decision table entry.
   ```go
   tests := []struct {
       name string
       input string
       want  string
   }{
       {"empty", "", ""},
       {"single", "a", "A"},
   }
   for _, tt := range tests {
       t.Run(tt.name, func(t *testing.T) {
           got := Transform(tt.input)
           if got != tt.want {
               t.Errorf("Transform(%q) = %q, want %q", tt.input, got, tt.want)
           }
       })
   }
   ```

3. **Mock external integrations.** LLM, HTTP, databases. Test every pattern: success, error, empty, malformed, unexpected format. Verify fail-closed on unexpected responses.

4. **`t.Error` in loops, `t.Fatal` for setup.** `t.Error` continues to the next case. `t.Fatal` stops the test. Never call `t.Fatal` from a goroutine other than the test goroutine.

5. **Test file mirrors source file.** `foo.go` → `foo_test.go`. Always. Test helpers for one file live in that file, not `helpers_test.go`.

6. **Use `httptest.NewServer` for HTTP testing.** Real HTTP, no mocking the client.

7. **Use `t.TempDir()` for filesystem tests.** Automatic cleanup.

8. **Inline assertions, not assertion libraries.** `if got != want { t.Errorf(...) }`. Keeps failures clear. Use `t.Helper()` in helpers.

9. **Test error paths aggressively.** Missing args, invalid input, connection failures, permission errors, malformed responses. These are where bugs hide.

10. **Design test cases systematically.** Equivalence partitioning (classes of inputs), boundary analysis (edges), decision tables (condition combinations).

## Anti-Patterns

| Smell | Fix |
|---|---|
| Coverage < 100% without justification | Run coverage, test or document every gap |
| Writing implementation before tests | Tests first, always |
| `assert.Equal` from testify | Inline `if got != want { t.Errorf }` |
| `t.Fatal` inside table-driven loop | Use `t.Error` (continues to next case) |
| `helpers_test.go` shared across files | Helpers live in the test file that uses them |
| No mock for HTTP/LLM calls | `httptest.NewServer` or mock interface |
| Only testing happy path | Test errors, edge cases, malformed input |
| Test named `TestThing` when source renamed | Mirror source file names |
