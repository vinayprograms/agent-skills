# rubric / api-design / receivers — pointer vs value

Pick one rule and apply it consistently — **never mix pointer and value receivers on the same type.**

## Use a POINTER receiver when
- the method **mutates** the receiver;
- the type holds a `sync.Mutex` / other non-copyable field (copying it breaks it);
- the struct is **large** (copy cost) or contains pointers to mutable state;
- *when in doubt* — pointer is the safer default for structs.

## Use a VALUE receiver when
- the type is a small, plain, immutable value (basic types, small fieldless structs, `time.Time`-like);
- the type is a map, func, or channel (reference-like already);
- you specifically want copy semantics.

## Notes
- A type with any pointer-receiver method should be **handed around as a pointer** (don't copy it).
- `var _ Iface = (*T)(nil)` asserts at compile time that `*T` satisfies an interface.
- Don't pass a pointer **just to save bytes** — pass values for small fixed-size types; never `*string`
  / `*io.Reader`. Pointers are for mutation or genuinely large/growing structs.
