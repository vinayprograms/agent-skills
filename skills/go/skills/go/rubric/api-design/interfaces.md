# rubric / api-design / interfaces — gateway vs concrete vs consumer-defined

> **Prior warning.** Your training prior says "a single-method, single-implementation interface is
> needless — delete it, return the concrete type." That is correct for **app** code and **wrong for a
> kit's primary type**. Check the mode *before* you touch any interface.

The three rules people think contradict each other don't — they're scoped differently:

## 1. Kit primary type → the interface IS the gateway
A reusable package exposes its primary behaviour through an **exported interface**:
- export the **interface**; keep the **concrete type unexported** (lowercase);
- the **constructor returns the interface**; everything after flows through it.

```go
// Notifier sends notifications.            <- exported gateway interface
type Notifier interface {
	Send(recipient, message string) error
	SentCount() int
}

type notifier struct{ prefix string; sent []string }   // unexported concrete

func New(prefix string) Notifier { return &notifier{prefix: prefix} }  // ctor returns the interface
```
Do **not** delete such an interface for being single-implementation — it's the extension/test seam and
the package's contract. If a kit's primary type has no interface yet, **add** the gateway. **No size
exemption:** once it's a shipped package, the gateway applies however small — raise any "too trivial to
be a package" objection at boundary time (`../../chunks/design.kit-boundary.md`), not here.

**Purely-functional kits have no primary type → stay plain.** A package that is just stateless
exported functions (no stateful object the caller holds) has nothing to front — keep the plain funcs,
add no interface. The gateway is for a *type*, not a function.

**Release note for a published kit:** an exported interface that *users implement* is frozen at v1 —
adding a method to it is a breaking change. Keep such interfaces tiny and stable, or add an
unexported method so only you can implement it (`../../reference/release.md`). The gateway pattern is
safe here because consumers *call* it, they don't implement it.

**Cross-cutting concerns decorate behind the gateway.** Tracing, retry, and caching wrap the
concrete type in an **unexported decorator** implementing the same interface, wired in by an
unexported constructor-time helper (`tracedModel` behind `llm.Model`, applied via `instrument()`).
The exported surface stays exactly one type — never export the decorator or a second constructor
for it.

## 2. App code → concrete
Apps use and return **concrete types**. "Accept interfaces, return concrete types" is the *app* rule.
Interfaces here are **discovered, not designed upfront**: write the concrete type first; add an
interface only when there's a **real second implementation** or a genuine **test seam**. Delete
producer-side single-impl interfaces here.

## 3. Dependencies (what a package CONSUMES) → consumer-defined, both modes
An interface for behaviour a package *needs from outside* belongs at the **call site**, declared as
**narrowly** as that site uses it (often one method). The consumer defines it; the provider satisfies
it by duck-typing. This never conflicts with the gateway (rule 1 is what you *provide*, rule 3 is what
you *need*). This applies to **any** consumed dependency — not only to break an import cycle (the
cycle-breaking in `../../chunks/decompose.md` step 3 is one *use* of this rule, not its only one).

## Anti-patterns
| Smell | Fix |
|---|---|
| Producer-side mirror interface in **app** code (one impl, no test seam) | Delete; return the concrete type |
| Interface added "just for mocking" | The *test* (consumer) declares the narrow interface it needs |
| Interface added "to future-proof" | Speculative — return concrete; you can change internals freely |
| Wide dependency interface (copies a whole concrete type) | Narrow it to the methods the call site actually calls |
| Kit primary type returned as a bare concrete struct | Front it with the gateway interface (rule 1) |
