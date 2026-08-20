# rubric — the knowledge the gates check against (thin index)

The `simplify` (back-gate) and `critique` (review) chunks consult these. Load only the leaf relevant
to what you're judging — never read the whole rubric.

- **`principles.md`** — the five core principles (clarity > simplicity > concision > maintainability >
  consistency) + least-mechanism + use-modern-Go. The foundation; everything below serves it.
- **`naming/`** — `checklist.md` (scan), `gauntlet.md` (resolve one contested name).
- **`api-design/`** — `interfaces.md` (gateway/consumer-defined/ifacefix), `receivers.md` (pointer vs
  value), `signatures.md` (params, returns, option structs, generics).
- **`errors/checklist.md`** — `%w`/`%v`, sentinels & types, naming, no log-and-return.
- **`concurrency/checklist.md`** — goroutine lifetimes, channels vs mutexes, `ctx` first, copy safety.
- **`responsibility/checklist.md`** — ownership, one-thing, no mutable globals, consumer wires.
- **`idioms/`** — `control-flow.md`, `data-structures.md`.
- **`documentation/checklist.md`** · **`testing/checklist.md`**.

Domain and currency knowledge (HTTP, CLI, Wails, files, releases, modern-Go catalog) lives in
`../reference/` — see its README. The rubric judges; the reference informs.

These are knowledge chunks, not process steps. Sources distilled: Effective Go, Go Code Review
Comments, Google Go Style Guide, spf13/go-skills (MIT), plus the project's own consumer-driven /
gateway conventions.
