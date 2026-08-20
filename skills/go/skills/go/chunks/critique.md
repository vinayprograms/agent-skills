# critique — apply the rubric as findings (no edits)

The read-only twin of `simplify`: same adversarial lens, but you **report findings, you do not edit**.
Used by the `review` route.

## Steps
Read the code cold, as a skeptic, with `../rubric/principles.md` as the lens (clarity > simplicity >
concision > maintainability > consistency). For each issue, produce a finding — don't fix it:
1. **API & interfaces:** check `../rubric/api-design/interfaces.md` (gateway for kit primary types;
   no producer-side mirror interfaces in app; consumer-defined deps), `../rubric/api-design/receivers.md`
   (pointer vs value), and `../rubric/api-design/signatures.md` (option structs, in-band errors,
   needless generics). Flag over-abstraction and speculative generality.
1b. **Surface coherence — read the WHOLE exported set as a consumer's mental model**, not line by
   line: scan `../rubric/api-design/surface.md` for vocabulary consistency (a loader named like a
   getter), symmetry/completeness (Add without Remove; whole-collection getter with no single-item
   one), least-surprise / temporal coupling (must-call-X-before-Y), **encapsulation** (returning
   or adopting references to internal mutable maps/slices), and **package independence** for a kit
   (no kit→kit import for mere convenience — a method returning a sibling package's type the consumer
   could assemble itself is the violation).
2. **Names:** scan `../rubric/naming/checklist.md` (incl. MixedCaps, initialism case, receiver names).
3. **Errors:** scan `../rubric/errors/checklist.md` (`%w` inside / `%v` at boundaries, sentinels/types, naming, no log-and-return).
4. **Responsibility:** scan `../rubric/responsibility/checklist.md` (one thing, knowledge with its expert, no mutable globals, consumer wires).
5. **Concurrency:** scan `../rubric/concurrency/checklist.md` (goroutine exit paths, safety documented, channels vs mutexes, `ctx` first).
6. **Idioms:** scan `../rubric/idioms/control-flow.md` and `../rubric/idioms/data-structures.md` (early return, comma-ok, nil-vs-empty slice, useful zero value).
7. **Docs & tests:** scan `../rubric/documentation/checklist.md` + `../rubric/testing/checklist.md`.
8. **Correctness & contracts:** error paths, nil/zero handling, backward compatibility for a kit
   (a published kit's exported surface: check the breaking-change table in `../reference/release.md`).
8b. **Modernity:** outdated idioms are findings — check against `../reference/modern-go.md`
   (`sort.Slice`→`slices.Sort`, `interface{}`→`any`, hand-rolled stdlib helpers, hand-rolled
   semaphores/pools, third-party routers where 1.22 `ServeMux` suffices). If triage flagged a
   **domain leaf** (`../reference/cli.md`, `http.md`, `wails.md`, `files.md`, `logging.md`), scan
   the code against it — e.g. missing server timeouts, Viper env-binding gotchas, Wails
   version-mixing.
9. **Against recorded intent:** check the code against existing **decision zettels**
   (`docs/decisions/`, `../rubric/decisions.md`). Code that contradicts a recorded decision — or
   re-introduces something a zettel deliberately removed — is a finding (cite the zettel).

For each finding record: **{location · problem · which rubric rule · suggested fix · severity}**.
Be specific; a finding the author can't act on is noise.

## Produces
A prioritised **findings list** (no code changed).

## Next
- Deliver the findings. **Terminal.** If the user asks you to apply them → `triage.md` (→ refactor / fix).
