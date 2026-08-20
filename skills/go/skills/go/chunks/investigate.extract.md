# investigate.extract — understand the code for carving out a kit

Goal-specific deep read for **moving a boundary**: pulling a reusable package out of an app. The entry point is the **seam**, and the work is consumer-driven.

## Steps
1. **Find the seam.** What slice of code would become the new package's exported API?
2. **Separate domain logic from app glue.** The kit keeps the reusable domain logic; app-specific wiring stays in the app.
3. **Inventory the consumer call-sites.** Every place the app uses the candidate. The *minimal* API is derived from these real call-sites — not from what the implementation happens to expose. (Consumer-driven design.)
4. **Trace dependency direction.** Find the acyclic cut: what the new package may import vs. what must be **injected / inverted**. Where the app currently reaches inward, invert it — the consumer declares the narrow interface it needs; the kit satisfies it (consumer-defines-interfaces).
5. **Mark the graduation.** The carved-out core graduates to **kit discipline**; the remaining app stays pragmatic. Note where the rubric strictness flips.

## Termination
Stop when the proposed package **"compiles in your head"**: closed API, acyclic dependencies, no app-specific imports, every consumer reachable through the new surface.

## Produces
A **responsibility map + proposed package boundary**: candidate exported API, dependency cut list, inversion points.

## Next
- Boundary proposed → `design.kit-boundary.md`
- Turns out it's really MANY packages, not one → escalate up: `decompose.md`
- Turns out boundaries don't actually need to move (it's just in-place cleanup) → escalate back: `triage.md` (re-route to refactor)
- Candidate can't be cleanly cut (irreducible cycles / too tangled) → `design.kit-boundary.md` to resolve via inversion, or discuss the cost with the user
