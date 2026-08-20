# reference — domain & currency knowledge (thin index)

Knowledge leaves, loaded **only when the task touches that domain**. Triage flags them; the chunk
that writes or judges the code loads them. Never read them all.

- **`modern-go.md`** — current-Go currency through 1.25: `slices`/`maps`/`cmp`, iterators,
  `errors.Join`, `rand/v2`, `omitzero`, typed atomics, syntax, generics judgment. The default
  leaf whenever code is written — stale training priors are the enemy.
- **`packages.md`** — organization: flat by default, domain packages over layers, `internal/`,
  library entry-point shape.
- **`http.md`** — production HTTP: 1.22 ServeMux routing, mandatory timeouts, graceful shutdown,
  middleware as plain functions.
- **`logging.md`** — `log/slog` patterns; logger as dependency, levels.
- **`debugging.md`** — the toolchain is not the problem; code-level explanations first.
- **`delve.md`** — live runtime inspection: scriptable `dlv test`/`exec`/`trace` + `--init`
  recipes; when a live look beats print-recompile loops, and the graduated post-implement
  runtime-verification walk.
- **`cli.md`** — Cobra/Viper CLI architecture: factories, RunE, binding hierarchy, env gotchas,
  in-memory testing.
- **`release.md`** — semver promises, breaking-change table, `gorelease`, deprecation, `retract`,
  go.mod hygiene, GoReleaser.
- **`wails.md`** — desktop apps: v2/v3 detection (incompatible APIs), per-version idioms,
  version-mixing tells.
- **`files.md`** — safe file operations: fileflow (cross-fs moves, conflict handling) +
  pathologize (cross-OS name safety, contained joins for untrusted input).

The four domain leaves `cli`/`release`/`wails`/`files` (and parts of the rest) are distilled from
[spf13/go-skills](https://github.com/spf13/go-skills) (MIT), by the author of Cobra/Viper/Hugo.
