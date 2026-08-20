# triage — route the request

Your only job here: infer the user's intent and pick the **lightest** entry chunk. Do **not** write code, do **not** read code deeply. Routing authority lives only here.

## Steps
1. Read the user's request. Note cheap repo signals only: is there a `go.mod`? Is the target an app (`main` package / binary) or a library (imported package)? Note the **mode** — `app` (pragmatic, concrete) vs `kit` (reusable, full discipline). This mode rides along the whole path.
2. Classify intent from what the user *means*, not keywords (triggers in parentheses below are hints, not an exhaustive list).
3. **Flag domain leaves.** Note domain signals and carry the matching reference leaf forward — do NOT load it here; the chunk that writes or judges the code loads it: CLI / Cobra / Viper / flags → `../reference/cli.md` · HTTP server or client → `../reference/http.md` · desktop / Wails / webview → `../reference/wails.md` · moving/copying files, or paths built from untrusted input → `../reference/files.md` · logging setup → `../reference/logging.md` · package/project layout → `../reference/packages.md`.
4. **Bias to the lightest route.** A one-line fix must never trigger a design interrogation. When two routes of different weight both fit and depth is genuinely ambiguous, ask **exactly one** disambiguating question, then route. Tie-break toward the lighter route.
5. If the user explicitly names a phase ("just simplify this", "review it"), pass straight through to it.

## Produces
A routing decision held in mind: `{ intent, mode (app|kit|unknown), domain leaves }`. Carry it forward — downstream chunks branch on it.

## Next
- Quick question / "is this idiomatic?" / opinion, no code change → `advise.md`
- Write new code / package / feature from scratch → `design.new.md`
- Understand or explain existing code (read-only) → `orient.md` (intent: explain)
- Review / audit / critique existing code or an API (read-only) → `orient.md` (intent: review)
- Improve / clean up / make idiomatic, **boundaries stay put** → `orient.md` (intent: refactor)
- **Extract ONE reusable package / pull a single kit out of an app** → `orient.md` (intent: extract)
- **Split a whole monolith into MANY packages / modularize / break it apart** → `orient.md` (intent: decompose)
- **Migrate onto a CHANGED dependency / upgrade a dep / port onto a new API / incorporate the new X** (build broken by the dep change) → `orient.md` (intent: migrate)
- Fix a specific, small, local bug → `fix.md`
- Diagnose why something fails (panic / race / wrong output) → `orient.md` (intent: debug)
- Make it faster / optimize / profile → `orient.md` (intent: optimize)
- **Review a spec / design doc / RFC / PRD before implementation** ("is this spec ready?") → `spec-review.md`
- **Cut / plan / review a release** (version tags, semver, breaking-change check, deprecating API, go.mod for release, shipping binaries) → load `../reference/release.md` and follow it; route any resulting code change back through `fix.md` / `implement.md`
- Depth genuinely ambiguous → ask one question, then re-pick an edge above.
