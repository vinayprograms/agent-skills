# rubric / documentation / checklist — doc comment smells → fixes

| Smell | Fix |
|---|---|
| **Exported symbol with NO doc comment** | Every exported top-level name (and non-trivial unexported one) gets a doc comment — absent is worse than malformed; check presence first |
| Doc comment doesn't start with the symbol name | `// Encode writes …`, `// A Request represents …` — full sentence, ends with a period |
| "returns true if …" on a bool func | "**reports whether** s begins with prefix" |
| Package comment missing / not adjacent | `// Package x …` immediately above `package`, no blank line; `main` → "The x command …" |
| Comment says *what* the code does | Document the **why** of non-obvious code; skip redundant restatement |
| `Close()`/`Stop()`/`Release()` needed but undocumented | State the cleanup the caller must do |
| Error conditions/types undocumented | Say which errors a func returns ("…it will be of type *PathError") |
| Concurrency safety unstated | Read-only assumed safe; document mutating ops as unsafe + who synchronizes |
| Deprecated symbol with no pointer | `// Deprecated: Use NewReader instead.` |
| Named results used just to enable naked return | Name results only to disambiguate same-typed returns for the reader |
| Every field/param commented | Document only the non-obvious / error-prone ones |
| New package with no runnable example | Add a Godoc `Example…` in `_test.go` (doubles as a usage doc + test) |

README (per kit package): lead with the ideal call-site snippet; document the interface, not the
implementation; show the config format if the package parses config; keep it to "what is this, how
do I use it"; update it on every rename — stale names are worse than no README.
