# verify — correctness baseline (non-skippable)

Prove the change builds and passes before judging its quality. This step is never skipped, even for one-line edits.

> Enforced structurally: this plugin ships a `Stop`/`SubagentStop` hook (`hooks/go-baseline.sh`) that runs gofmt+vet+build+`test -race` and **blocks the turn from ending** until green. Run these yourself anyway — the hook is the backstop for when attention slips or the harness skips it, not a reason to omit the step.

## Steps
1. **gofmt — only the files you changed**, not the whole repo: `git diff --name-only HEAD -- '*.go' | xargs gofmt -l`. A clean *changed* set passes even if the repo has pre-existing unformatted files (that dirt is out of your scope — don't sweep it into your change; if it must be fixed, do it as a separate commit).
2. `go vet ./...` — no vet complaints.
3. `go build ./...` — compiles.
4. `go test ./... -race` — tests pass, no data races.
5. If anything fails, fix it before moving on.
6. **Runtime verification (graduated — design-heavy routes only).** If this change introduced a
   new public API, kit boundary, or subsystem (new code / extract / decompose — never a small fix),
   walk the agreed call-site **once, live**, after green: `dlv trace` the new exported functions
   while the tests (or a tiny driver) run, or a breakpoint script over the primary flow, and
   confirm runtime behavior — values, call order, goroutine exits — matches the design intent, not
   just the assertions (`../reference/delve.md`). A failed expectation here goes back to
   `implement.md` and gets **pinned as a test** — the delve session is the detector, never the
   durable proof.

## Produces
A green build, or a concrete failure list.

## Next
- Green → `simplify.md`
- Failures → `implement.md` (fix, then return)
