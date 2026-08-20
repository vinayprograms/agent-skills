# decompose.wire-app — wire the thinned app onto the extracted kit (final node)

The DAG's last node is the **app / residual**, not a kit package — it has no exported API. Its job is
to *consume* the now-extracted kit. **Pragmatic mode** (concrete types, no kit discipline). Runs
**attended** in the main thread — it's the final integration and cheap to review with the user.

## Steps
1. Replace the monolith's in-place logic with calls into the extracted packages (the call-sites the
   kit was designed for).
2. Make `main` a thin aggregator/wiring layer. If it holds real logic, push that down into a package.
3. Inject the concrete implementations that satisfy the kit's consumer-declared interfaces (the
   `Logger`, `Cache`, … the kit packages declared).
4. Verify the **whole module**: `go build ./...` + `go test ./... -race` green.

## Produces
The thinned app consuming the kit; the whole module green.

## Next
- Green → `document.md` (final pass: package docs across the new kit)
