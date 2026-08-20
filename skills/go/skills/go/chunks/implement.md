# implement — write the change to serve the call-site

Make the code real, in service of the agreed call-site snippet. Nothing more.

## Steps
1. Implement to the **snippet**. The call-site is the contract; the implementation serves it.
2. One major type per file; file name matches its purpose. Constructors return **ready-to-use** objects — no `Init()` / `SetX()` two-step.
3. **Conform to the surrounding codebase.** Match existing conventions, naming, error style. Refactor neighbours only by **proposal**, never unilaterally.
3b. **Use current Go.** Check `go.mod` for the version; when emitting any idiom you're not certain is current, check `../reference/modern-go.md` — stale training priors (`sort.Slice`, `interface{}`, `x := x`, hand-rolled stdlib helpers) are smells the back-gate will catch anyway. Load any **domain leaf** triage flagged (`../reference/cli.md`, `http.md`, `wails.md`, `files.md`, `logging.md`) before writing that layer.
4. Apply discipline by **mode** (`../rubric/api-design/interfaces.md`): **kit** — front the primary type with an exported **gateway interface**, keep the concrete type unexported, the constructor returns the interface; **app** — pragmatic concrete types, an interface only for a real second implementation / test seam. Dependencies a package *consumes* = consumer-defined narrow interfaces in both modes.
5. **Tests are part of the code, not optional.** Kit/reusable packages MUST ship tests for their
   exported API (success + error + edge cases, table-driven). Without them `verify` passes vacuously
   (`[no test files]` = untested, not safe). App code: test the non-trivial logic. (Testing rubric — *pending*.)

## Produces
The code change **and its tests**.

## Next
- Code written → `verify.md`
