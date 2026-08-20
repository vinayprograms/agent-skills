# rubric / api-design / signatures — parameters, returns, options, generics

| Smell | Fix |
|---|---|
| Designing the implementation before the call site | **Write the usage line first** — it's the design; the impl serves it |
| Returning `interface{}` / `(bool, string, error)` grab-bags | Return the **simplest** concrete type that serves the caller |
| In-band error via `-1` / `""` / `nil` | Return an extra final value: `Lookup(key) (value string, ok bool)` or `(T, error)` |
| Long parameter list (esp. with bools) | Collect into an **option struct** passed last (callers omit defaults; it grows non-breakingly) |
| Many callers need zero config, a few need lots | **Functional options**: `New(req, WithTimeout(d))`; last value wins; never put `context` in options |
| Options pattern picked by taste | **Config struct is the default** for a primary constructor — serializable (JSON/mapstructure tags), a `Validate()` method, inspectable. **Functional options** only for small optional-knob surfaces where most calls pass none (`errors.New(code, msg, opts...)`) |
| `context.Context` not first / stored in a struct | First parameter, named `ctx`; never stored |
| Generics for a type-agnostic "framework" or to mimic a DSL | Avoid needless generics; use them only to remove **real** duplication. Prefer `any` over `interface{}` |
| `type T1 = T2` alias for a new type | Aliases are for **migration** only; define new types with `type T struct{…}` |
| Two-step construction (`New` then `Init`/`SetX`) | Constructor returns a **ready-to-use** value; `(T, error)` if it can fail |
| Exporting things only used internally | Keep the surface minimal; export only what consumers need |

## Handler fields on a Config: interface vs function field

- **Core behavior, always stateful** (connections, caches, registries) → an **interface** field;
  the consumer implements it on a struct.
- **Optional callback, often a one-liner** (`OnProgress`, `Validate`) → a **function field**;
  method references still cover the stateful case.
- **Multiple related methods** (Read/Write/Delete) → an interface — they group into one
  implementation struct.

The test: if implementing it always needs a struct with state → interface. If a one-line lambda is
a legitimate implementation → function field.
