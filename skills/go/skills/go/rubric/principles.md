# rubric / principles — the foundation everything else serves

Google's Go style states five core principles **in priority order**. When they conflict, the
higher-priority one wins. The rest of the rubric is these made concrete.

1. **Clarity** — code is read far more than written; optimize for the reader. Document the *why* of
   non-obvious code, not the *what*.
2. **Simplicity** — the code should read top-to-bottom without prior knowledge. Add complexity only
   deliberately (real perf need, multiple consumers) and document why.
3. **Concision** — high signal-to-noise: kill repetition (table tests), needless abstraction, and
   extraneous syntax.
4. **Maintainability** — design APIs to grow gracefully; minimize coupling and dependencies; delete
   unused features.
5. **Consistency** — match the surrounding file/package/codebase. Prefer codebase-wide consistency
   over local; never use local consistency to justify violating documented style.

**Least mechanism.** Reach for the simplest tool that works, in this order: core language → stdlib →
internal libs → a new external dependency. (Echoes "a little copying is better than a little
dependency.")

**Use modern Go.** This skill targets current Go (through 1.25). Prefer the modern idioms and don't
carry obsolete shims: per-iteration loop variables (1.22 — no `x := x`), generics where they remove
real duplication (1.18; prefer `any` over `interface{}`), `errors.Join` (1.20), `min`/`max`/`clear`
(1.21), `log/slog` (1.21), `slices`/`maps`/`cmp` (1.21), `range`-over-int (1.22), range-over-func
iterators (1.23), `omitzero` (1.24), `testing/synctest` and `WaitGroup.Go` (1.25). Check `go.mod`
for the version in play before using a feature. The full currency catalog — with the stale idioms
each one replaces — is `../reference/modern-go.md`.

**Secure by default.** Verify-all with a skip-list for exceptions, never opt-in verification.
Enforce deny lists at execution, not just display. Keep escaped content escaped. Never silently
truncate or drop data. `crypto/rand` for anything security-sensitive; untrusted input never decides
a file path (`../reference/files.md`) or a shell command.
