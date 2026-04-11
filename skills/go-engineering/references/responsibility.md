# Responsibility Assignment

## Core Questions

Apply these to every type, function, and field:

1. **"Who owns this knowledge?"** Assign responsibility to the type that has the data. Credential resolution belongs in `credentials`, not in tool code calling `os.Getenv`. Entropy calculation belongs with the encoding detector, not in a separate file.

2. **"Who should NOT know this?"** Enforce boundaries. Tools should not know about LLM wire protocol. Policy holds rules; enforcement packages apply them. The kit doesn't know the consumer's agent architecture.

3. **"Does this type do one thing?"** If describing it requires "and", split it. `BashChecker` that parses commands AND checks policy AND calls LLM is three types.

4. **"Am I switching on type?"** Replace with interface polymorphism. `switch backend { case "brave": ... case "tavily": ... }` → `SearchEngine` interface with implementations.

5. **"Is this a kit or an app?"** Kits serve diverse consumers — need extension points (interfaces, pluggable implementations). Apps can be concrete. A kit called `shellguard` MUST support multiple shells.

6. **"Can I delete this?"** If nobody uses it, or if a simpler design eliminates the need, remove it. Dead code is a design signal.

## Principles

### Data vs Enforcement
A policy struct holds rules. An engine enforces them. Don't put enforcement in the data package.
- Bad: `BashChecker` in `policy`
- Good: `shellguard.Gate` imports `policy.Lookup`

### Consumer metadata doesn't belong on kit types
Fields like `AgentContext`, `CreatedAtSeq`, `SessionID` are consumer bookkeeping. The kit type should only hold what the kit needs for its own decisions.

### Types belong in their domain package
`FILResult` belongs in `memory`, not a shared `types` package. `ObservationItem` belongs in `memory`. The consuming package imports them; duck typing avoids cycles.

### Separate extraction from storage
`Extractor` returns data. `Store` persists it. The consumer wires them together. Don't bundle extraction + storage + tool interface into one type.

### The consumer wires things together
The kit provides building blocks. The consumer assembles them. The kit doesn't know which guard goes on which tool, which store is ephemeral vs persistent, or which MCP servers exist.

## Anti-Patterns

| Smell | Fix |
|---|---|
| Consumer metadata on shared types | Keep consumer fields out of kit types |
| `switch` on backend type | Interface polymorphism |
| Enforcement logic in data package | Separate enforcement package |
| `os.Getenv` in tool code | Credentials package handles env resolution |
| Aspirational features with zero consumers | Delete; build when needed |
| Extraction + storage bundled | Extractor returns data; consumer stores |
| `interface{}` params to match consumer's interface | Concrete types; consumer adapts at their boundary |
| Dead interfaces with zero callers | Delete immediately |
| Generic transport with one consumer | Each protocol owns its communication |
