# decompose — derive the package architecture from a monolith

The heavy, distinctive work of multi-package extraction: turn one tangled unit into a *structured
set* of packages with a clean dependency order. This is design, not mechanics. Entry point is the
monolith's **capabilities/domains**, not any single seam.

## Steps
1. **Enumerate capabilities.** What distinct responsibilities does the monolith hold? (e.g. llm,
   mcp, memory, tools, policy, credentials…). One capability = one candidate package. Name each by
   what it *provides*, never `util`/`common`/`types`.
2. **Assign ownership.** For each piece of state and behavior, ask "who owns this knowledge?" and
   place it in the package that is its expert. Pull consumer-specific metadata off shared types.
3. **Build the dependency DAG.** Draw the import edges between candidate packages. Break every
   cycle by inverting it: the consumer declares the narrow interface it needs; the provider
   satisfies it (consumer-defines-interfaces). The top-level app/orchestrator wires them — it
   should end up a thin, one-file aggregator.
4. **Order leaf-first.** Topologically sort: packages with no internal dependencies come out first.
   This is the tracer-bullet extraction order — each package is extractable and green before the
   ones that depend on it.
5. **Mark the graduation line.** Everything carved into a package gets **kit discipline**; whatever
   stays in the app stays **pragmatic**.
6. **Agree the envelope with the user — this is the one user gate for the whole loop.** Because each
   package is then extracted by a fresh sub-agent with no user present, the user confirms the *whole
   architecture* here as a strawman to poke: the DAG, the per-package boundaries, the graduation
   line. Get this right; the loop runs on it unattended. **Headless fallback (no user present):**
   record the architecture decisions + assumptions in the ledger, commit it, proceed, and surface
   them in the final report.
7. **Write the Ledger** (`<repo>/.go-decompose/ledger.md`, add to `.gitignore`). This is the
   externalized memory that survives every context reset — see template below.
8. **Record the architecture decision** as decision zettel(s) (`../rubric/decisions.md`): the package
   boundaries, the graduation line, and *why this DAG*. The ledger is transient working state; the
   zettel is the durable *why* that outlives the migration.

## Termination
Stop when you have a named package set, an acyclic DAG, a leaf-first order, a user-agreed envelope,
and a written Ledger — and each proposed package "compiles in your head" (closed API, no
app-specific imports).

## Produces
The **Ledger** at `<repo>/.go-decompose/ledger.md` — the single source of truth the loop reads
(never the prior transcript). Three sections are NON-OPTIONAL (their loss reintroduces cycles or
re-extraction): the DAG status table, the Exported APIs of done packages, and the Cross-package
contracts (interface inversions).

```
# Decompose Ledger — <module path>
<!-- Source of truth. Read THIS, not prior conversation. -->

## Module
- path: github.com/x/y
- go: 1.23
- baseline-sha: <git SHA at decompose start>
- last-green-sha: <SHA after last extracted package>

## DAG (leaf-first)              # status table — anti-re-extraction + order guard
1. [ ] errs     deps: —
2. [ ] config   deps: errs
3. [ ] store    deps: errs,config
N. [ ] app      deps: all

## Exported APIs (done packages — the literal import surface downstream may use)
### errs
    func Wrap(err error, msg string) error

## Cross-package contracts (consumer-declared interfaces / inversions)
- store declares `Logger interface{ Log(...) }`, satisfied by app, injected via store.New(l Logger).
  store MUST NOT import app.

## Graduation line
- kit (full discipline): errs, config, store
- app (pragmatic): main wiring only

## Amendments (DAG drift discovered during extraction)
- <date>: <what changed + reorder>

## Package records (append-only, one per DONE package)
### <pkg> — DONE (sha …)
- API: …
- call-site: …
- declares: …
- imports: …
- note: …
```

## Next
- Envelope agreed + Ledger written → `decompose.iterate.md`
- It's really just one package after all → de-escalate: `investigate.extract.md`
- The decomposition is contested / too big to settle in one pass → discuss trade-offs with the user, then re-enter here
