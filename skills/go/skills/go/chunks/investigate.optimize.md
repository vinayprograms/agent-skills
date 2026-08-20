# investigate.optimize — find the real hot path (measure, don't guess)

Goal-specific read for performance. **Never optimize blind** — the entry point is a measurement, not
a hunch. Behaviour must be preserved (optimize is refactor's cousin: faster, same results).

## Steps
1. **Measure first.** A profile (`pprof`) or a benchmark identifies the actual hot frame. Without a
   measurement you have no business changing anything for speed.
2. Build the **cost model on the hot path**: allocations / escapes, copies, interface boxing, defers
   in loops, lock contention, channel backpressure, syscalls.
3. **Attribute cost to specific frames** — a ranked top-N of what actually costs, with numbers.
4. Capture the **behaviour invariant** to preserve (the tests that pin correct results).

## Termination
Stop when measured cost is attributed to specific frames and you have a candidate top-N to attack.

## Produces
A **quantified hotpath model**: ranked cost by frame + the behaviour invariant.

## Next
- → `benchmark.md` (lock in a baseline before changing anything).
- Nothing is actually hot / it's fast enough → say so and stop (don't optimize for its own sake).
