# benchmark — prove the optimization (baseline → after)

An optimization without numbers is a guess. This chunk brackets the change with measurement and
guards correctness.

## Steps
1. **Baseline.** Write or locate a Go benchmark for the hot path; run it and record numbers:
   `go test -bench=. -benchmem -count=6` (use `benchstat` if available). Save the baseline.
2. Hand off to `implement.md` to make the optimization.
3. **After.** Re-run the same benchmark identically. Compare to baseline.
4. **Gate on a real win.** Require a meaningful, stable improvement (time and/or allocs) beyond noise.
   If there's no real gain, **revert** — complexity added for an imagined speedup is the anti-pattern.
5. **Correctness preserved.** `go test ./... -race` green — the optimization must not change results.

## Produces
Baseline + after numbers showing a real improvement, behaviour unchanged.

## Next
- Baseline recorded → `implement.md` (then return here to compare).
- Improvement confirmed + green → `simplify.md` (don't let the fast version be needlessly clever) → `document.md`.
- No real improvement → revert; back to `investigate.optimize.md` (wrong target) or stop.
