# investigate.migrate — diagnose a dependency migration

Goal-specific read for re-pointing a consumer onto a **changed dependency** (a new major version, a
reorganized kit, a renamed/removed API). Unlike `refactor`, the baseline is **RED by definition** and
the work re-points imports/call-sites rather than improving code.

## Steps
1. **Pin the change & take the red baseline.** What dependency changed, from what to what? Set the
   `replace`/version, run `go build ./...` — **the error list IS the work-list.** Record the baseline
   **error count**; the migration's job is to drive it to zero.
2. **Map old → new, classify every removed/renamed symbol** (read the dependency's source + READMEs):
   - **re-point** — same capability, new path/name/shape → update the consumer.
   - **in-source / vendor** — capability was **removed** from the dependency; the consumer must absorb
     it (copy the old code in, or reimplement). This is **neither extract nor decompose** — don't
     mis-route it there.
   - **dropped** — genuinely gone and not needed → delete the consumer's usage.
3. **Identify affected CONSUMER PACKAGES.** The unit of a migration is the **consumer package**, not a
   symbol — a dependency type changing shape ripples across a whole package at once.
4. **Capture the behaviour invariant** — the tests that must pass again once the module is green.

## Produces
A **migration map**: { dependency old→new, per-symbol classification (re-point / in-source / dropped),
affected consumer packages, **red-baseline error count**, behaviour invariant }.

## Next
- More than one consumer package / context-exceeding → `migrate.plan.md`.
- Trivial (one consumer package, pure re-point) → re-point it, then `verify.md`.
- A removed capability needs a real **redesign** (not a verbatim in-source) → escalate: `triage.md`
  (→ new / extract).
