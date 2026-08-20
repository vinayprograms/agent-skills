# reference / modern-go — current-Go currency (through Go 1.25)

Training priors run years stale: they emit `sort.Slice`, `interface{}`, `x := x` captures, and
hand-rolled helpers the stdlib has since absorbed. **Always check stdlib first**, and check
`go.mod` for the version in play before using a feature. Outdated idioms are complexity —
`simplify` and `critique` treat them as smells.

## Syntax

- `any`, not `interface{}` (1.18).
- **Per-iteration loop variables** (1.22): never emit the old `x := x` capture line.
- Range over int (1.22): `for i := range 10 { … }` replaces `for i := 0; i < 10; i++`.
- Build constraints: `//go:build linux || darwin` — never the deprecated `// +build` form.
- Tool dependencies (1.24): `go get -tool golang.org/x/tools/cmd/stringer` + `go tool stringer …`.
  Never generate a `tools.go` with blank imports.
- Generic type aliases are fully supported (1.24).

## `slices` (1.21; iterator bridging 1.23)

```go
slices.Contains(s, v) · slices.Index(s, v) · slices.ContainsFunc(s, f)
slices.Sort(s) · slices.SortFunc(s, func(a, b T) int { return cmp.Compare(a.Name, b.Name) }) · slices.IsSorted(s)
slices.Reverse(s) · slices.Compact(s) · slices.Delete(s, i, j) · slices.Clone(s) · slices.Concat(s1, s2)
slices.Collect(it) · slices.Sorted(it) · slices.Values(s)   // iterator ↔ slice
```

Never write `sort.Slice(s, func(i, j int) bool { … })` when `slices.Sort`/`slices.SortFunc` exists.

## `maps` (1.21; iterators 1.23)

```go
maps.Keys(m) · maps.Values(m)        // iterators — collect with slices.Collect / slices.Sorted
maps.Clone(m) · maps.Copy(dst, src) · maps.DeleteFunc(m, pred) · maps.Equal(m1, m2)
keys := slices.Sorted(maps.Keys(m))  // the sorted-keys idiom, one line
```

## `cmp` + builtins (1.21)

```go
cmp.Compare(a, b)   // -1/0/1 for any cmp.Ordered
min(a, b) · max(a, b) · clear(m)     // builtins
cfg.Timeout = cmp.Or(cfg.Timeout, 30*time.Second)  // first non-zero — the default-value idiom
```

## `errors.Join` (1.20)

`errors.Join(err1, err2, err3)` — works with `errors.Is`/`errors.As`. Use it instead of
`fmt.Errorf("%w; %w", …)` chains or any `multierr` package.

## Iterators: `iter` and range-over-func (1.23)

The standard way to expose a sequence without allocating a slice — return `iter.Seq[T]` /
`iter.Seq2[K, V]`; callers use plain `range`:

```go
func (idx *Index) All() iter.Seq[*Person] {
	return func(yield func(*Person) bool) {
		for _, p := range idx.people {
			if !yield(p) {
				return
			}
		}
	}
}
for p := range idx.All() { … }
```

Prefer iterators over slices for large or lazily-produced sequences. Never invent a custom
`Next()/HasNext()` iterator type — that's Java.

## `math/rand/v2` (1.22)

Always import `math/rand/v2`, never old `math/rand`. Auto-seeded: `rand.IntN(100)` (capital N),
`rand.N(10 * time.Second)` (generic, any integer type). `crypto/rand` for anything
security-sensitive — tokens, keys, nonces.

## `encoding/json`: `omitzero` (1.24)

`omitzero` omits any zero value — including `time.Time{}` and zero structs, which `omitempty`
never handled: `` StartedAt time.Time `json:"started_at,omitzero"` ``.

## Typed atomics (1.19)

`var count atomic.Int64; count.Add(1); count.Load()` — not the function-based
`atomic.AddInt64(&count, 1)` API. Also `atomic.Bool`, `atomic.Pointer[T]`, `atomic.Uint64`.

## `context.WithoutCancel` (1.21)

Detach cancellation but keep values, for background work that outlives a request:
`bgCtx := context.WithoutCancel(requestCtx)`.

## Bounded concurrency (see also `../rubric/concurrency/checklist.md`)

- `errgroup.WithContext(ctx)` + `g.SetLimit(n)` — never hand-roll a semaphore channel or a static
  worker pool.
- `sync.WaitGroup.Go` (1.25) removes Add/Done boilerplate when errors don't propagate:
  `wg.Go(func() { process(url) })`.

## Testing additions (1.24–1.25; see also `../rubric/testing/checklist.md`)

- `t.Context()` — test-scoped context, canceled when the test ends; use instead of
  `context.Background()`.
- `b.Loop()` replaces the classic `b.N` loop — more accurate, defeats dead-code elimination.
- `t.Chdir(dir)` — changes working directory for the test, restores after.
- `testing/synctest` (1.25) — deterministic goroutine/timeout tests with a fake clock. Never
  `time.Sleep(100*time.Millisecond)` to "wait for a goroutine".

## Generics (1.18+) — algorithms, not hierarchies

Generics eliminate duplicated **algorithms**; they do not create type hierarchies. Thinking about
generics as inheritance or polymorphism = writing Java.

```go
// Good: one algorithm over many concrete types
func Map[S, T any](s []S, f func(S) T) []T { … }
func Min[T cmp.Ordered](a, b T) T { … }

// Bad: generic interface for polymorphism — this is Java
type Repository[T any] interface { Find(id string) (T, error); Save(T) error }
// Good: a concrete interface for what you actually need
type UserStore interface { FindUser(id string) (*User, error); SaveUser(*User) error }
```

- No generic base types, generic services, generic repositories.
- `any` as a constraint meaning "I don't know the type yet" is a design smell.
- `comparable` for map keys/equality; `cmp.Ordered` for `<`/`>`.
- Start concrete; generify only when the same logic repeats across 3+ types.
