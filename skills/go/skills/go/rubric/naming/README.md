# rubric / naming — index (thin; pointers only)

Names are the API. Bad names force readers to build mental lookup tables. Load only the leaf you need:

- **Scanning a diff / many names for smells** → `checklist.md` (compact smell→fix table).
- **Resolving ONE contested or non-trivial name** → `gauntlet.md` (the adversarial naming protocol).

Core targets (the one-liners the leaves expand):
- One strong word beats two adequate ones. A second word means the first is too weak.
- No package-name stutter (`credentials.Lookup`, not `credentials.CredentialLookup`).
- **Verbs for actions; nouns for accessors and value constructors** (getters drop `Get`;
  option funcs are nouns — `slog.String` precedent).
- No `On` prefix (JS idiom). `With` means **derivation** (`context.WithValue`, `logger.With`) —
  never a plain option constructor, unless the bare noun collides with an exported type.
- Constructors encode the source: `FromFile`, `FromEnv`; `New` only for the primary type.
- Name by purpose, not mechanism. Error strings: lowercase, no trailing punctuation.
