# reference / debugging — the Go toolchain is not the problem

**The Go tool is extremely reliable. It is almost never the source of a bug.** Do not waste time
suspecting `go run`, `go build`, `go test`, or the build cache:

- `go run` always recompiles from source — it does not use a stale cached binary.
- `go build` is deterministic and correct.
- `go test` runs the actual compiled test binary.
- The build cache is keyed by source content — if the source changed, it invalidates itself.

**If an error persists after an edit, the explanation is one of these — in order of likelihood:**

1. The edit did not fix the underlying logic error.
2. The edit was made in the wrong file, wrong function, or wrong package.
3. There is a second call site with the same bug that was not updated.
4. The error comes from a different code path than the one being edited.

**Instead of blaming the tool:**

- Re-read the error message carefully. Go's error messages are accurate.
- Confirm the edited file is actually being compiled: `go list -f '{{.GoFiles}}' .`
- Add a `fmt.Println` / `t.Log` at the exact site to verify execution reaches it.
- For deep or hard-to-print state, inspect the live process instead of guessing — scriptable
  delve recipes in `delve.md`.
- Check that every call site of a changed function was updated.

Never suggest `go clean -cache`, restarting the toolchain, or any tool-level intervention before
exhausting all code-level explanations. The tool is not lying to you.
