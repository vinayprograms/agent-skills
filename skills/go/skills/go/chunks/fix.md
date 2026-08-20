# fix — the smallest correct change for a small, local bug

The lightest path. Its whole reason to exist is **effort graduation**: a one-line fix must not drag
in orientation, design, naming debates, or the full adversarial back-gate. Do the minimum, prove it,
stop. If the bug turns out NOT to be small, bail upward — don't quietly grow this into a redesign.

## Steps
1. **Sanity-check the size.** Is this genuinely small and local — a wrong condition, an off-by-one, a
   missed `err` check, a bad default? If fixing it properly means touching a boundary, many files, or
   a responsibility is misplaced, it's not a `fix` — escalate (see Next).
2. **Locate narrowly.** Read just the failing spot and its immediate neighbours. Do NOT orient the
   whole module; that's for the heavier routes.
3. **Lock the bug with a test first.** Add a regression test that **fails** on the current code
   (proves you found the real fault). If the area is genuinely untestable in a small way, say so and
   proceed — don't chase coverage for its own sake.
4. **Make the smallest change that passes it.** No neighbouring refactors, no new abstraction, no
   rename sweeps. Conform to the surrounding style. (A **sentinel error var** is an abstraction —
   reach for an inline `errors.New`/`fmt.Errorf` here; introduce a sentinel only when a caller
   actually needs `errors.Is`, which is a `refactor`/design call, not a `fix`.)
5. **Verify.** gofmt/vet/build/`go test ./... -race` green. (The plugin's Stop hook also enforces
   this — but run it yourself.)

## Produces
The minimal fix + a regression test, module green.

## Next
- Fixed and green → done. Summarise the one-line *what* and *why*. (No document phase for a small
  fix unless you changed a documented contract — then update that doc comment.)
- It's not actually small (touches design, spans files, exposes a misplaced responsibility) →
  escalate: `triage.md` (it will re-route to refactor / debug / extract). Tell the user why.
- You can't reproduce or locate the fault — it's diagnosis, not a known fix → escalate: `triage.md`
  (re-route to debug).
