# investigate.review — set up a code/API review (read-only)

Goal-specific read to prepare a **critique**. Entry = the diff or the exported surface. Read-only.

## Steps
1. Scope it: the changed lines (a diff/PR) or the package's exported API (an API review).
2. Read the exported surface and the contracts it claims (doc comments, interfaces, error semantics).
3. Gather the **blast radius**: consumers that depend on what you're reviewing (a contract change
   ripples to them).
4. Note the **mode** (app vs kit) — the rubric's strictness differs (e.g. the gateway rule applies to
   kits).

## Produces
**Review context**: what to check + against which consumers + the mode.

## Next
- → `critique.md` (apply the rubric as findings, no edits).
