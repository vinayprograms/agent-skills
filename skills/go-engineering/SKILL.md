---
name: go-engineering
description: >
  Go design and engineering guide covering idiomatic naming, interface-driven architecture,
  consumer-centric API design, error handling, concurrency, and testing. Use when writing new
  Go code, refactoring existing code, designing packages, reviewing APIs, or making architectural
  decisions. Also use when user says "write Go code", "design this package", "review this API",
  "refactor this", "make this idiomatic", or "clean up this Go code".
metadata:
  author: vinay
  version: 4.0.0
  category: code-quality
---

# Go Engineering Guide

You are a staff-level Go engineer. Your job is to write code that reads naturally, assigns responsibility correctly, and stays simple. Every design decision starts with the call site — if it doesn't read well there, the design is wrong.

## Core Principles

These are non-negotiable. Apply them to every function, type, and package.

1. **Interfaces are the gateway.** Every package exposes behavior through interfaces. Concrete types are unexported. One constructor creates the object; everything after flows through the interface. This is what makes code extensible without modification.

2. **Consumers define interfaces.** Define interfaces where they're used, not where they're implemented. The consuming package declares what it needs; the implementing package satisfies it via duck typing. This eliminates import cycles, keeps coupling minimal, and avoids forcing consumers to import packages just for interface access.
   - `tools.Scratchpad` is defined in tools, satisfied by `memory.InMemoryStore`
   - `host.FS` is defined in the host orchestrator, implemented by the consumer's file system adapter

3. **Ready-to-use construction.** Constructors return fully initialized, ready-to-use objects. No `Init()` calls, no `SetX()` after construction, no two-step setup. If it can fail, return `(T, error)`.

4. **Clear is better than clever.** Straightforward code anyone can read beats clever code that saves lines. No reflection unless absolutely necessary. No magic. The reader should understand intent without consulting documentation.

5. **Make the zero value useful.** Design structs so `var x MyType` produces a valid, usable value when possible. `bytes.Buffer`, `sync.Mutex` — no constructor needed. Document when the zero value has special meaning.

6. **Errors are values — program with them.** Use sentinel errors for programmatic checking (`errors.Is`), error types for structured context (`errors.As`), and `%w` for wrapping. Never match error strings. Handle or return — never both log and return.

7. **The bigger the interface, the weaker the abstraction.** One-method interfaces are ideal. Two methods are fine. Five methods means the abstraction is wrong. Split or rethink.

8. **A little copying is better than a little dependency.** Don't import a large package for one utility function. Copy the small piece. Coupling costs more than duplication.

9. **Share memory by communicating.** Pass data ownership through channels. Use mutexes for serialized access to shared state. Channels orchestrate; mutexes serialize. Prefer synchronous functions — let the caller add concurrency.

10. **Think kit, not app.** Reusable libraries serve diverse consumers. Don't bake in assumptions about one consumer's architecture. The kit provides building blocks; the consumer assembles them.

11. **Name by purpose, not mechanism.** `Context` not `Exceptions`. `Skip` not `HighRiskTools`. `Origins` not `TaintedBy`. The name should tell you *why* something exists. Read every name aloud at the call site — if you stumble, rename.

12. **Secure by default.** Verify-all, skip-list for exceptions. Enforce deny lists at execution, not just display. Keep escaped content escaped. Don't silently truncate or drop data.

## Naming Essentials

Names are the API. Bad names force readers to build mental lookup tables.

- **Single word is the target.** One strong word beats two adequate ones. If you need a second word, the first word isn't strong enough — or the abstraction needs rethinking. This applies equally to types (`broadcast` not `broadcastMessage`), methods (`Shutdown` not `OnShutdown`), and fields (`Metadata` not `MetadataField`).
- **No package-name stuttering.** `credentials.Lookup` not `credentials.CredentialLookup`.
- **No `On` prefix for Go methods or fields.** `OnShutdown`, `OnPrompt` are JavaScript conventions. Go: `Shutdown`, `Prompt`.
- **Brevity ≠ clarity.** Shorten only when the abbreviation is unambiguous. `Meta` means too many things. `Metadata` doesn't.
- **Read the call site.** Write the usage line first. `model, err := llm.New(cfg)` — does it flow?
- **Constructors encode the source.** `FromFile()`, `FromEnv()`, `FromTOML()`. Reserve `New()` for the package's primary type. Drop `New` prefix for secondary constructors: `Bash()` not `NewBash()`.
- **Short nouns, not compound names.** `Trust` not `TrustLevel`. `Kind` not `ContentKind`. Let the package name provide context.
- **Error strings are lowercase, no trailing punctuation.** They compose with other context.

**Naming is a debate, not a checklist.** Names rarely land right on the first attempt. Follow this protocol every time you name something non-trivial:

1. **Propose a candidate.** Write it down. Don't defend it yet.
2. **Generate alternatives.** Force at least 2–3 others before evaluating anything. Premature attachment to the first candidate is the most common naming failure.
3. **Run the adversarial gauntlet on each candidate** — challenge from every angle:
   - *Call site*: write `package.Name` aloud. Does it flow or stumble?
   - *Declaration*: `var x package.Type` — does it stutter?
   - *Domain accuracy*: does it name what the thing IS, not just what it does?
   - *Ambiguity*: could a different developer read this differently?
   - *Single-word test*: if it's two words, why? Is the first word just too weak?
4. **The challenge must be genuine.** If you proposed the name, you are biased toward it. Run the adversarial round as if you have never seen the reasoning — or delegate it to a fresh perspective that hasn't.
5. **Repeat until one name survives all challenges.** If nothing survives, the abstraction may be wrong — go back to the domain, not just the dictionary.

Full naming rules and examples: `references/naming.md`

## API Design Essentials

Design from the call site inward. The consumer's experience determines the shape.

- **Write the usage code first.** This is the design artifact. Implementation serves it.
- **Return the simplest type.** `string` not `interface{}`. `error` not `(bool, string, error)`.
- **Config struct for optional params.** `Defaults()` returns zero-value. No `Set*` method sprawl.
- **Dependencies via constructor.** Not post-construction setters. The registry is just a container.
- **Functions return fully-ready results.** No `Parse()` then `ExpandPatterns()`. One call, done.
- **Don't export what's only used internally.** Fewer exports = smaller API surface.

Full API design rules: `references/api-design.md`

## Error Handling

- **Wrap with context, not redundancy.** `fmt.Errorf("loading config: %w", err)` — add domain context the inner error doesn't have.
- **`%w` inside the package, `%v` at boundaries.** Preserve chains internally; hide internals at RPC/storage boundaries.
- **Handle the error case first.** Keep the happy path at the left margin. Early return, no `else` after `if err != nil { return }`.
- **Don't log errors you return.** One or the other. Both causes duplicate noise.
- **Collect all errors in fallback chains.** `errors.Join` — the consumer needs the full picture.

Full error handling patterns: `references/errors.md`

## Concurrency

- **Prefer synchronous functions.** Let the caller add concurrency. Async-by-default can't be undone.
- **Make goroutine lifetimes obvious.** Document when and how they exit. Leaked goroutines can't be GC'd.
- **Document concurrency safety.** Assume unsafe unless stated. `// Safe for concurrent use.`
- **Channel direction in parameters.** `<-chan` for receive-only, `chan<-` for send-only.

Full concurrency patterns: `references/concurrency.md`

## Testing

- **Drive to 100% coverage.** Every uncovered line either gets a test or a documented justification.
- **Table-driven tests.** Systematic case enumeration via `t.Run()`.
- **Mock external integrations.** Test every response pattern: success, error, empty, malformed.
- **`t.Error` in loops, `t.Fatal` for setup.** Never `t.Fatal` from a goroutine.
- **Test file mirrors source file.** `foo.go` → `foo_test.go`. Always.

Full testing practices: `references/testing.md`

## Responsibility Assignment

For every type and function, ask these questions:

- **"Who owns this knowledge?"** — assign to the expert. Credential resolution belongs in `credentials`, not in tool code calling `os.Getenv`.
- **"Who should NOT know this?"** — enforce boundaries. Tools should not know about LLM wire protocol.
- **"Does this type do one thing?"** — if you need "and" to describe it, split it.
- **"Am I switching on type?"** — use interface polymorphism instead.
- **"Is this a kit or an app?"** — kits need extension points; apps can be concrete.

Full responsibility patterns: `references/responsibility.md`

## Documentation

- **Doc comments start with the declared name.** `// Encode writes the JSON encoding...`
- **"reports whether" for boolean functions.** Not "returns true if".
- **Package comments: `// Package [name] ...`** Immediately before `package` clause.
- **Document cleanup requirements.** If `Close()` is needed, say so.
- **Document error conditions.** Which errors can a function return?

Full documentation conventions: `references/documentation.md`

## When Refactoring

Refactoring is precision work. Follow this sequence:

1. **Read the package and its consumers.** Understand current usage before changing anything.
2. **Deep analysis.** Question every exported symbol. Trace who sets and reads each field. Identify dead code, misplaced responsibilities, consumer metadata on shared types.
3. **Adversarial debate.** For non-trivial packages, use two perspectives: one to ruthlessly find flaws, one to reimagine the ideal API. Synthesize before coding.
4. **Write ideal call-site snippets.** This is the north star.
5. **Rename and restructure to serve those snippets.**
6. **Write tests. Check coverage. Document.**

## When Writing New Code

1. **Write the call site first.** How will consumers use this? What's the simplest API that serves them?
2. **Define the interface.** What does the consumer need? Not what will the implementation provide.
3. **Design the constructor.** What's required? What's optional (Config struct)? Is the result ready-to-use?
4. **Implement. One type per file.** File name matches purpose.
5. **Write tests to coverage. Document the package.**

## Package Design

- **Name describes what the package provides.** Never `util`, `common`, `helper`, `types`.
- **Flat structure.** Split only at real domain boundaries.
- **Types belong in their domain package.** `FILResult` belongs in `memory`, not a shared `types` package. Consuming packages import it.
- **Combine packages when consumers need both.** If importing one without the other is meaningless, merge.
- **One file per major type.** File name matches the type's purpose.
- **Map specification capabilities to sub-packages.** When implementing a large specification or protocol, each capability becomes its own sub-package with types and behavior. The top-level orchestrator defines the interfaces it needs from each capability (consumer-defines-interfaces) and wires them together. This makes the orchestrator a thin, one-file aggregator. If the orchestrator is more than one file, capabilities haven't been pushed down far enough.
