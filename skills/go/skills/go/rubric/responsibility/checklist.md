# rubric / responsibility / checklist — who owns what

Ask of every type, function, field:

| Question | If it fails → |
|---|---|
| **Who owns this knowledge?** | Move it to the expert. Credential resolution → `credentials`, not `os.Getenv` in tool code. |
| **Who should NOT know this?** | Enforce the boundary. Tools don't know LLM wire protocol; a kit doesn't know the consumer's app architecture. |
| **Does it do ONE thing?** | If describing it needs "and", split it (parse AND check AND call = three types). |
| **Am I switching on a type/string?** | Replace with interface polymorphism. |
| **Kit or app?** | Kits need extension points; apps can be concrete. |
| **Can I delete it?** | No callers / a simpler design removes the need → delete. Dead code is a design signal. Before a kit release, make this a **sweep**: grep every exported symbol for real callers — zero callers = speculative surface (see `../../reference/release.md`). |

| Smell | Fix |
|---|---|
| Consumer metadata (`SessionID`, `CreatedAtSeq`) on a kit type | Keep consumer bookkeeping out of kit types |
| Enforcement logic living in the data package | Data holds rules; a separate engine enforces them |
| Extraction + storage bundled in one type | `Extractor` returns data; consumer stores it |
| `FILResult` in a shared `types` package | Types live in their domain package; consumers import them |
| `interface{}` params to match a consumer's shape | Concrete types; the consumer adapts at their boundary |
| The kit decides which guard goes on which tool | The kit provides blocks; the **consumer wires** them |
| Domain-specific helper inside a general package (`credentials.GetLLMKey`) | Push specialization out — the consumer calls `creds.Get("openai")` and knows what to do |
| API leaks implementation topology (env vs file vs OAuth visible to callers) | Consumers see the capability, not where it came from |
| `registerBuiltins()` / bulk registration + `Subset()` filtering | The consumer registers explicitly, only what it needs |
| Unexpected input silently truncated, dropped, or unescaped | Fail closed: verify-all with an explicit skip-list; keep escaped content escaped |
| Mutable package-level state (global vars, shared client) | Inject dependencies via params/fields; each instance owns its own state |
| One multi-thousand-line file, or a swarm of tiny files | Split by semantic function; keep tightly-coupled details together |
| Global flags scattered | Put flags in their own `var` group after imports |
| Library code mixed with `main`/CLI | Separate library from command; `main` is thin wiring |
