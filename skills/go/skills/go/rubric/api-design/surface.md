# rubric / api-design / surface — read the exported surface as ONE coherent whole

Names and types are also judged individually (`naming/`, `interfaces.md`, `signatures.md`,
`receivers.md`). This leaf judges the exported surface as a **consumer's mental model** — the
coherence and DevEx that per-name checks miss. Read the whole exported set together, not line by line.

## Vocabulary coherence
- The method set must read as **one consistent vocabulary**. Pick one verb per concept and keep it:
  `load`/`read`/`list`/`get`/`fetch`/`set` are DIFFERENT jobs — a loader must not be named like a getter.
  - Classic smell: `Tools()` *reads* the collection while `ListTools()` *loads* it. "List" implies a
    read, so the consumer stumbles and the two collide. → distinct verbs: `Tools()` (read) +
    `Load(...)`/`Set(...)` (load).
- Two exported methods doing confusingly-overlapping things → collapse or rename so each has one job.

## Symmetry & completeness
- Paired operations come in **pairs**: `Add`↔`Remove`, `Open`↔`Close`, `Lock`↔`Unlock`,
  `Subscribe`↔`Unsubscribe`, `Set`↔`Get`, `Start`↔`Stop`, `Acquire`↔`Release`.
- An `Add` with no `Remove`, or a whole-collection `Tools()` with no single-item `Tool(name)` /
  `Delete(name)`, is an **asymmetry smell** — add the partner or consciously justify its absence.
- If you expose a way IN, expose the matching way OUT (and the cleanup: what you `Open`, you can `Close`).

## Least surprise / no temporal coupling
- A consumer should predict behaviour from the name **without reading the source**.
- A hidden ordering ("you must call `ListTools` before `Tools`/`AddTool` works") is a **brittleness
  smell**. Fix it structurally: make the object ready-to-use (init in the constructor / a useful zero
  value), or encode the ordering in the **type** (e.g. a builder whose `Load` returns the ready
  object) — not in a doc comment the caller is trusted to obey.

## Encapsulation — don't leak mutable internal state
- Returning an internal `map`/`slice`/pointer **by reference** lets callers mutate your private state
  (and race on it). → return a **copy**, an unmodifiable view, or accessor methods. (`Tools()` handing
  out the live `map` is the classic break.)
- **Adopting** a caller's `map`/`slice` by aliasing (`s.field = arg`) means the caller still holds —
  and can mutate — what you now treat as private. → copy it when you keep it, or document that you
  take ownership.

## Package independence — a kit is building blocks, not a framework
A kit's packages are **independent** building blocks; the *consumer* wires them together. Default
stance: **a kit package does not import a sibling kit package.** Before adding such an import, classify
it:
- **Consumed dependency** (the package genuinely needs that behaviour to do its job — e.g. a verifier
  that must *call* a model) — allowed, but prefer a **consumer-defined narrow interface** declared
  locally (see `interfaces.md` rule 3) over importing the sibling's concrete package, so you couple to
  a one-method contract, not the whole package.
- **Convenience coupling** (a method that *produces*, returns, or adopts a sibling package's type just
  so the consumer doesn't have to write the glue) — **this is the violation.** Delete it; inter-package
  conversion/wiring is the consumer's job. The classic break: `A.ToB()` returning `otherpkg.B` purely
  to save the caller three lines — it welds two building blocks together forever for no functional gain.
- Smell test: if removing the import would only cost the *consumer* a few lines of obvious glue (a
  struct literal, a convert loop), the import is convenience coupling — drop it. If removing it makes
  the package unable to perform its function, it's a consumed dependency — narrow it.
- Settled exceptions exist (couplings predating the kit's 1.0 where there was no other way). Don't
  re-litigate those; this lens governs **new** surface.
