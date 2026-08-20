# investigate.explain — explain existing code (read-only)

Goal-specific read to **answer a question about how/what code does**. Read-only — you produce
understanding, not edits. Build only as much model as the question needs.

## Steps
1. From the orientation, identify exactly what the user wants explained (a package, a flow, a type,
   "why does X happen").
2. Build the **situation model** (what it accomplishes, in domain terms) and, to the depth asked, the
   **program model** (how it executes — control/data flow, the key types and their contracts).
3. Trace the specific path the question is about; name the load-bearing types, interfaces, and
   invariants.
4. Explain in the user's terms: what it does, how it flows, where the important decisions live. Use a
   concrete call-site or example where it helps.

## Produces
A clear **explanation** answering the question. **Terminal** (read-only).

## Next
- Done — deliver the explanation. If the user then wants a change, return to `triage.md`.
