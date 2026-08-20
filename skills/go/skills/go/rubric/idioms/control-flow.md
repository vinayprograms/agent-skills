# rubric / idioms / control-flow

| Smell | Fix |
|---|---|
| Deep nesting / `else` after a returning `if` | Handle the error first, `return` early; keep the happy path at the left margin (no `else`) |
| Repeated `if x != nil { … }` before use | Use `if`/`for`/`switch` **init statements**: `if err := f(); err != nil { … }` |
| `if constant == x` (Yoda) | Variable before constant: `if x == 0` |
| Long boolean condition inline | Extract operands into named booleans |
| if-else chain on one value | Expression-less `switch { case …: }` |
| Manual type checks | Type switch `switch v := x.(type)` (with `default`); type assert with comma-ok `v, ok := x.(T)` |
| Redundant trailing `break` in a switch case | Drop it (no fall-through in Go); comment an intentionally empty case |
| Can't break out of a loop from a switch | Labeled `break`/`continue` |
| Reading from a possibly-missing map key | Comma-ok: `v, ok := m[k]` |
| `range` value you don't use | Drop with `_`, or `for i := range xs` |
| Accidental shadow with `:=` in inner scope | Use `=` to reassign the outer var (classic `ctx` shadow bug) |
