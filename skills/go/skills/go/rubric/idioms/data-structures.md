# rubric / idioms / data-structures

| Smell | Fix |
|---|---|
| Constructor needed just to make a type usable | **Make the zero value useful** (`bytes.Buffer`, `sync.Mutex` work at zero) — document when zero has meaning |
| `t := []string{}` for a local | Prefer `var t []string` (nil slice); a nil slice appends/ranges fine |
| API that distinguishes nil from empty slice | Don't — check `len()`; (rare exception: JSON `null` semantics) |
| `new(T)` where you need an initialized slice/map/chan | `make` initializes; `new` only gives a zeroed `*T` |
| Writing to a nil map | Initialize first (`make`/literal); reading a nil map is safe (zero value) |
| Set modeled with a struct | `map[K]bool` (or `map[K]struct{}`) for membership |
| Preallocating capacity "to be fast" | Only after measuring; never beyond actual need |
| Returning a slice after `append` without reassigning | `x = append(x, …)` — append may reallocate the backing array |
| Copying a struct that has pointer/mutex methods | Hand it around as `*T`; beware aliasing the backing array of a sub-slice |
| `switch`/cast to format a type | Implement `String() string` (convert receiver to a basic type inside to avoid infinite recursion) |
| `math/rand` for tokens/keys | `crypto/rand` for anything security-sensitive |
