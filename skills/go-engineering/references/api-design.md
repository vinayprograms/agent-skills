# API Design

## Rules

1. **Write the usage code first.** Before touching internals, write how the package should be consumed. This is the design artifact. Implementation serves it.

2. **Return the simplest type the consumer needs.** `string` not `interface{}`. `error` not `(bool, string, error)`. `map[string]string` not `[]SearchResult` when the struct adds no value.

3. **Push specialization out of the package.** Domain-specific helpers belong in the consuming layer. `credentials.GetLLMKey()` is wrong — the consumer calls `creds.Get("openai")` and knows what to do.

4. **Don't leak implementation topology.** Consumers shouldn't know whether a credential came from env, file, or OAuth.

5. **Config struct for optional params.** `Defaults()` returns zero-value for the common case. No 5+ positional parameters.
   ```go
   guard, err := contentguard.New(stages, workflow, contentguard.Defaults())
   guard, err := contentguard.New(stages, workflow, contentguard.Config{
       Skip: []string{"read"},
   })
   ```

6. **Dependencies via constructor, not setters.** The registry is a container. 8 `Set*` methods means the design is wrong.

7. **Functions return fully-ready results.** No `Parse()` then `ExpandPatterns()`. `FromTOML(content, workspace, homeDir)` — one call, ready to use.

8. **Don't export functions only used internally.** Fewer exports = smaller API.

9. **Consumer registers explicitly.** No `registerBuiltins()` — the consumer knows what they need.

10. **Accept interfaces, return concrete types.** Unless concrete types are unexported and multiple implementations exist behind the interface.

11. **Functional options vs config structs.** Use config structs when most callers provide options. Use functional options when most use defaults and the set may grow.

12. **JSONSchema bridge for LLM integration.** `Definition.JSONSchema()` converts typed params to raw JSON schema. No import coupling between tool and LLM packages.

## Anti-Patterns

| Smell | Fix |
|---|---|
| `interface{}` / `any` return types | Return the actual type |
| `map[string]interface{}` for schemas | Define a typed struct (`Param`) |
| `New()` with 5+ positional params | Config struct + `Defaults()` |
| 8+ `Set*` methods | Dependencies via constructors |
| `registerBuiltins()` hardcoding | Consumer registers explicitly |
| `Subset()` to filter after bulk registration | Register only what you need |
| Exported result types for internal formatting | Unexport; each component formats its own output |
| `Initialize()` on interface | Move init into constructor — return ready-to-use objects |
| `Connect()` + `Add()` for same concept | One method: `Register` |
| Concrete type where consumer may want alternatives | Interface — let consumer swap implementations |
| Defining interface that mirrors another package's | Import and use the existing one |
| Shared `types` package for cross-package structs | Types belong in their domain package; duck typing avoids cycles |
| Type aliases for backward compat | Delete alias, move type to home package |
| Adapter wrapping identical calls | Delete — duck typing connects directly |
