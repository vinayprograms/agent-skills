# orient — cheap shared orientation

The identical, low-cost front-half of understanding any existing Go code. Reused by every code-reading intent. Do **not** go deep here — depth belongs to the `investigate.*` leaf you load next.

## Steps
1. Read `go.mod` / `go.work`: module path, Go version, dependencies in play.
2. Map the package / directory structure. Note `internal/` boundaries, which packages are `main` (app) vs imported libraries (kit). Confirm the **mode** triage carried.
3. Locate the target area the user named. Read its **package boundary** — the exported symbols and doc comments — not the whole implementation.
4. **Recall prior rationale.** Read any existing **decision zettels** for the target area
   (`docs/decisions/` by scope/keyword + `doc.go` `Design:` pointers) — see `../rubric/decisions.md`.
   Inherit the recorded *why*; don't re-litigate or silently contradict it.
5. Stop. You now know *where* things are + *why* they're shaped that way, not yet *how* they work.

## Produces
An **orientation model**: module/version, package map, app-vs-kit signal, and the located target boundary.

## Next
Branch on the intent triage carried:
- extract (one package) → `investigate.extract.md`
- decompose (whole monolith → many packages) → `decompose.md`
- migrate (re-point onto a changed dependency) → `investigate.migrate.md`
- debug → `investigate.debug.md`
- review → `investigate.review.md`
- refactor → `investigate.refactor.md`
- optimize → `investigate.optimize.md`
- explain → `investigate.explain.md`
