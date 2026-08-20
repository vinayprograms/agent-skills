# simplify — adversarial back-gate

The keystone gate. After the code works, **attack it** as a skeptic whose job is to find over-abstraction, and **force** revision. This — not the rules merely being in context — is what kills Java-ish, verbose output. Mandatory on every code-producing path.

## Steps
Read the diff cold, as if a different engineer wrote it and you must refute its complexity, with
`../rubric/principles.md` as the lens (clarity > simplicity > concision > maintainability > consistency):
1. **Interfaces — do NOT reflexively delete a single-method, single-impl interface.** Your training prior will push you to; that prior is WRONG for kits. Apply `../rubric/api-design/interfaces.md`: a **kit** primary type KEEPS its gateway interface (front it with one if missing; the concrete stays unexported; the constructor returns the interface); an **app** drops an interface only when it has no real second implementation or test seam; a *consumed* dependency's interface is consumer-defined at the call site (both modes).
2. **Names:** scan the change against `../rubric/naming/checklist.md`. For any single name still contested after the scan, resolve it via `../rubric/naming/gauntlet.md`.
3. **Every layer / wrapper / manager / helper:** does it earn its keep, or is it ceremony? Collapse it if not. **Unexporting ceremony does not save it** — an unexported single-impl interface between two types in the same package is still a needless layer: DELETE the indirection (the concrete type calls the concrete type), don't just hide it.
4. **Every abstraction:** is it solving a problem you *have*, or one you imagined? Delete speculative generality.
5. **Errors, zero values, construction:** scan `../rubric/errors/checklist.md` (wrap with real context, not redundancy). Zero value useful? Constructor returns ready-to-use?
6. **Responsibility & concurrency:** scan `../rubric/responsibility/checklist.md` (incl. no mutable globals) and (if goroutines/locks are touched) `../rubric/concurrency/checklist.md`.
7. **Receivers, signatures, idioms:** if the change adds methods/params, check `../rubric/api-design/receivers.md` and `../rubric/api-design/signatures.md`; for control-flow/data-structure smells, `../rubric/idioms/control-flow.md` and `../rubric/idioms/data-structures.md`.
8. **Surface coherence:** if the change adds/alters the **exported surface**, read it as a whole against `../rubric/api-design/surface.md` — vocabulary consistency, symmetry/completeness, no temporal coupling, and no leaking/adopting references to internal mutable state.
9. **Modernity:** outdated idioms are complexity. Check the diff against `../reference/modern-go.md` — `sort.Slice`→`slices.Sort`, `interface{}`→`any`, hand-rolled helpers the stdlib provides, hand-rolled semaphores/pools where `errgroup.SetLimit` suffices, third-party routers where the 1.22 `ServeMux` suffices (`../reference/http.md`).

Then **revise the code**. If the revision changes behavior, re-run `verify.md`. If your revision
**reverses a recorded decision** (`docs/decisions/`), don't do it silently — **supersede** the zettel
(a new linked one, old flipped to `status: superseded`) per `../rubric/decisions.md`.

**High-stakes verify (graduated — not every change).** If this change introduces or breaks a **public
API**, or you're on a design-heavy route (new code / extract / a kit boundary), spawn a **fresh
different-lens verifier** sub-agent to audit your revised diff against the rubric (SANCTIONED /
OVER-REACH / MISREAD / MISSING) before finishing — **and hand it the relevant decision zettels
(`docs/decisions/`) in its brief, so it doesn't re-litigate a recorded decision** (a cold verifier
will try to undo your gateway interface). On a real finding, fix and re-check, bounded to 2
rounds → escalate to the user. **Skip this for trivial/light changes** (a one-line `fix`, a rename) —
effort graduation. The verifier exists for high-stakes work, not to tax small edits.
**No sub-agent support in this harness?** The audit still happens: re-read the revised diff cold in
a separate pass, as a skeptic who has not seen your reasoning, before finishing. Weaker than a fresh
agent, but not optional.

## Produces
Revised, simplified code.

## Next
- Running as an **unattended sub-agent** (decompose package / refactor unit) and this slice is done → **return your record to the orchestrator** and stop (it's integrated + validated by `decompose.iterate.md` / `refactor.iterate.md`)
- Single-thread `decompose` fallback, package done → `decompose.checkpoint.md`
- Revised and still green → `document.md`
- The critique surfaced a structural problem too big to fix here → escalate back: `triage.md`
