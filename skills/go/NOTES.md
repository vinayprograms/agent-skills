# Build context for this skill lives in the `go-skill` note project

This `go` skill is a deliberate redesign of `go-engineering`. All design decisions,
constraints, and source material (agentkit chat transcripts + commit history) are
captured as notes — do NOT start building without reading them.

**Start here:** note MCP project `go-skill`, note titled
"★ START HERE — go-skill project index & reading order".

- List the notes: `note` MCP → `list_notes(project="go-skill")`
- On disk: `~/Documents/projects/go-skill/notes/`
- Refactor source (old skill): `../go-engineering/` (superseded; kept as source material)

Working agreement: do NOT one-shot this. Build incrementally, one pressure-tested
piece at a time.

## v2.0.0 (2026-08-19) — merge

`go-engineering` (v4 rulebook) and github.com/spf13/go-skills (all six skills, MIT) were
merged into this skill. New `reference/` tier holds domain/currency knowledge (modern-go,
http, logging, packages, debugging, cli, release, wails, files); a `spec-review` chunk was
added; the rubric absorbed the deltas (errgroup over hand-rolled pools, softened coverage,
config-struct-default options rule informed by agentkit, `With*` allowed on functional
options). `go-engineering` remains in the repo as superseded source material.

Also added in v2.0.0: `reference/delve.md` (scriptable live runtime inspection) wired into
`investigate.debug` step 3 as a graduated escalation and into `verify` step 6 as a graduated
post-implement runtime-verification walk for design-heavy routes — a stronger feedback loop
than tests alone, with the test remaining the durable proof.
