# spec-review — review a design doc BEFORE implementation (read-only)

A spec/design doc/RFC/PRD for Go work is cheapest to fix before code exists. Verify it is
complete, consistent, and idiomatic — through the lens of someone who rejects unnecessary
abstraction and expects the simplest design that works. Read-only: findings, not edits.

## Steps
1. **Understand the codebase context first.** Map the package structure (flat/domain vs legacy
   layer packages — the spec should match the better of the two, and may reasonably propose
   migrating off a legacy layout; `../reference/packages.md`). Note the Go version in `go.mod` —
   flag pre-modern idioms the toolchain has obsoleted (`../reference/modern-go.md`). Identify
   existing patterns (HTTP clients, error types, config structs, interfaces) the spec should
   reuse, and read any **decision zettels** (`docs/decisions/`) touching the spec's area — a spec
   contradicting a recorded decision is a finding (`../rubric/decisions.md`).
2. **Go philosophy check** — for each concern, look for:
   - *Simplicity*: unnecessary layers; abstractions with one implementation; over-engineering.
   - *Dependencies*: every third-party dep justified against a stdlib alternative
     (`../reference/modern-go.md`, `../reference/http.md`)?
   - *Interfaces*: consumer-defined, small (1–3 methods), used where polymorphism is real
     (`../rubric/api-design/interfaces.md`)?
   - *Errors*: returned explicitly, wrapped with `%w`, not swallowed; sentinels named where
     callers must branch?
   - *Context*: `ctx` threaded through I/O and long-running calls? Timeouts specified?
   - *Concurrency*: goroutines with clear ownership **and a stated shutdown path**; bounded
     fan-out (`../rubric/concurrency/checklist.md`)?
   - *Packages*: one clear domain responsibility each; new packages justified; no
     `utils/`/`common/` proposals?
   - *Naming*: no stutter, no `Get` prefixes (`../rubric/naming/checklist.md`)?
   - *Testing*: does the spec say how? Fakes at I/O boundaries, table-driven core logic,
     in-memory CLI execution?
   - *YAGNI*: everything driven by stated requirements, not anticipated ones?
3. **CLI check** (skip if not a CLI; load `../reference/cli.md`): factory-built commands, `RunE`
   not `Run`, persistent-vs-local flags, `cobra.Args` validators, Viper keys/env bindings explicit
   with defaults for every config-struct key, business logic receives typed config (never Viper),
   output via `cmd.OutOrStdout()`, registration point of new subcommands in the spec's file list,
   `--input`/`--output` same-path guard. If the codebase uses legacy package-level command `var`s:
   the spec must not add more globals, and new flag variable names must be unique across `cmd/`.
4. **Completeness check**: TODOs/TBDs/missing error paths; internal contradictions; requirements
   ambiguous enough that two implementors would build different things; scope focused enough for
   one implementation plan; clear data flow; migration/deprecation story for behavior changes
   (`../reference/release.md` for a published library); untrusted values sanitized before use in
   shell commands, file paths (`../reference/files.md`), or external calls.
5. **Calibrate.** Only flag issues that would cause real problems during implementation. Ambiguity
   that doesn't block a sound design is a *Question*, not an Issue. Approve unless gaps would lead
   to a flawed or incomplete implementation.

## Produces
A review, delivered as:

```
## Go Spec Review
**Status:** Approved | Approved with Questions | Issues Found
**Issues (block implementation):**    — [section]: issue — why it matters
**Questions for Author:**             — [section]: the ambiguity — the readings an implementor could take
**Recommendations (advisory):**       — improvements to correctness, idiomaticity, clarity
```

## Next
- Deliver the review. **Terminal.** If the user then wants the spec implemented → `triage.md`
  (→ design.new / implement paths, which inherit the review's findings).
