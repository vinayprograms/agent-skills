# reference / packages — organization: flat by default, domains over layers

Load for package-layout questions or when a design decision touches project structure. The
enemy: Java/Spring structure rebranded as "Go best practices" (`golang-standards/project-layout`,
deep `internal/` trees, `service/`/`repository/`/`controller/` layers, a `pkg/` junk drawer).
Those actively fight Go's design and cause circular imports.

## The single-package default

Start flat. A microservice or simple tool puts everything in the root (alongside `main.go`).
Create a new package only when you truly need a new namespace, or a strictly independent domain:

```
myproject/
├── main.go           # entry point (if application)
├── server.go         # core logic
├── config.go
├── parser.go
├── parser_test.go
└── go.mod
```

## Domain packages for service applications

When an application has genuinely distinct, independently-testable domains, each gets its own
top-level package — still **one level deep**:

```
myservice/
├── main.go        # wires everything together; no business logic
├── config/        # Config struct, env loading
├── auth/          # identity verification, session middleware
├── db/            # data store client + all queries
├── billing/       # payment provider + credit ledger
├── jobs/          # job lifecycle + queue dispatch + worker (one domain, one package)
└── web/           # HTTP handlers + templates + static assets (coupled by design)
```

Rules:
- The signal to create a package: describable in one sentence, no knowledge of the other packages.
- Name after what it **does**, not what layer it is (`jobs/`, not `service/`).
- Packages do not import each other sideways — cycles mean wrong boundaries; `main` is the wiring point.
- Sub-concerns that always travel together stay in one package.
- Never `utils/`, `helpers/`, `common/`, `types/` — symptoms of unclear ownership.
- **Reject** Clean Architecture / DDD layer packages (`service/`, `repository/`, `controller/`,
  `domain/`) — circular imports, interface proliferation, zero clarity in Go.

## `internal/`

Compiler-enforced: other modules can't import it. Use it deliberately, not by default:
- **Applications**: nobody can import your binary's code anyway — `internal/` usually just adds
  path depth.
- **Libraries**: sparingly, for subsystems that must share exported types between your own
  packages while forbidding end-user reliance.

## Placement rules (any mode)

- Name describes what the package **provides**, never `util`/`common`/`helper`/`types`.
- Types live in their domain package (`FILResult` in `memory`, not a shared `types` package);
  consumers import them — duck typing avoids cycles.
- Combine packages when importing one without the other is meaningless.
- One file per major type; file name matches the type's purpose.
- **Map specification capabilities to sub-packages.** Implementing a large spec/protocol: each
  capability becomes its own sub-package with types and behavior; the top-level orchestrator
  declares the interfaces it needs (consumer-defined) and wires them — a thin, one-file
  aggregator. More than one file of orchestrator = capabilities not pushed down enough.
  Inside each capability sub-package, name wire types by **role**, not capability:
  `prompt.Params`, `prompt.Result` — never `PromptParams` in a flat package (the package carries
  the noun; protobuf/OpenAPI habits of flat `VerbRequest`/`VerbResponse` are the anti-pattern).
- Sub-packages also absorb compound-name prefixes shared by 3+ types
  (`protocol.EventHandler` → `event.Handler`) — see `../rubric/naming/gauntlet.md`.

## Library entry point: domain object, not global state

A library wrapping a stateful resource (a vault, a DB connection, a config store) makes that
resource struct the primary object; methods return domain-typed sub-objects:

```go
v, err := vault.Open(path)         // primary resource opened once
idx, err := v.People()             // *people.Index — domain types live in sub-packages
note, err := v.Daily(time.Now())   // stateless calls (reload fresh) — no cache invalidation
p, err := idx.FindOne("Steve")     // callers use := — rarely need to import sub-packages
```

Avoid: passing a config/resource struct as the first arg to every package-level function, and
package-level global state (pflag's default FlagSet style) in library code. A global instance is
acceptable only in CLI-only tools where there is truly ever one instance.
