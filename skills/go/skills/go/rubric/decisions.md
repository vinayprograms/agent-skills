# rubric / decisions — capture & recall design rationale (zettel-style)

Design rationale is the skill's most perishable output — the *why* behind a boundary, an app-vs-kit
call, a rejected alternative, a headless assumption. It evaporates between sessions, Claude Code
instances, and weeks. Persist it as small, atomic, **committed decision zettels** so it survives and
the next reader (human or agent) inherits it.

## Where
- `docs/decisions/` — **one small file per cohesive decision**, slug-named: `0007-credentials-is-a-kit.md`.
  Atomic like a zettel — the *smallest logical set* of related decisions, no more. Many tiny files,
  never one growing `DECISIONS.md`.
- For a package-local decision, also leave a one-line pointer in the package's `doc.go`
  (`// Design: see docs/decisions/0007-...`) so godoc readers find it.
- **Commit them with the code** — they travel with the repo and are visible to humans and any future agent.

## When (GRADUATED — not every change)
Write one only for a **non-trivial design decision**: a front-gate outcome (call-site shape,
app-vs-kit, *what does NOT belong*), a boundary move (extract / decompose / migrate), a contested call
with **real rejected alternatives** (a hard gauntlet name; an abstraction deliberately kept or killed
in `simplify`), or a headless **assumption**. A one-line `fix` or a routine rename gets **none**.

## Format (keep it tiny)
```
# <id>: <the decision in one line>
scope: <package / "architecture">   status: accepted   date: <YYYY-MM-DD>   links: [[0003]] [[0005]]

## Context      — the forces / why (2–4 lines)
## Decision     — what we chose (1–3 lines)
## Rejected     — <alternative> — why not   ← the part that's always lost; never omit it
## Consequences — what this implies; what does NOT belong here
```
Link related zettels with `[[id]]` so the rationale forms a navigable graph, not a pile.

## Recall (the load-bearing half — capture without recall is write-only)
Before designing or changing an area, **read its existing decision zettels** (grep `docs/decisions/`
by scope/keyword + follow `doc.go` Design pointers). Inherit the rationale — do **not** re-litigate or
silently contradict a recorded decision. Reversing a decision **supersedes** it: write a new zettel
that `links` the old and flips its `status: superseded` — never erase the history.

## In practice (don't let the mechanism leak)
- **Hand zettels to sub-agents.** Any unattended sub-agent or different-lens **verifier** that audits a
  change MUST get the relevant decision zettels in its brief — otherwise it re-litigates a decision
  that's already recorded (a cold verifier will "helpfully" undo your gateway interface).
- **id = next free number** in `docs/decisions/` (check the current max). When sub-agents run in
  parallel, the **orchestrator** assigns ids and writes the files — sub-agents return rationale in
  their record, they don't create zettels (avoids id collisions).
- **Commit it with the change.** Unattended loops already commit per unit (ledger + zettels). On the
  attended path the skill doesn't auto-commit — so **surface the zettel with the change** for the user
  to commit together; an uncommitted zettel doesn't travel.

## Harvest (cross-project value)
If a decision encodes a **generalizable** rule (not project-specific) — like the gateway/`ifacefix`
resolution or surface-coherence — flag it for promotion into the rubric. That's how the skill itself
improves across projects.
