# rubric / naming / checklist — scan a diff for naming smells

Run down this table against the names in the change. Each row is a smell → the fix. For any name
that's genuinely contested after this scan, switch to `gauntlet.md`.

| Smell | Fix |
|---|---|
| `package.PackageThing` (stutter) | Drop the package prefix: `credentials.Lookup` |
| Two-word name (`deliverToSubscribers`, `broadcastToAll`) | One verb that owns the purpose: `broadcast`, `deliver` |
| `OnX` method/field (`OnShutdown`, `OnPrompt`) | Drop `On` — Go isn't JavaScript: `Shutdown`, `Prompt` |
| `WithX` prefix outside functional options (fields, methods, builders) | Drop `With` — the verb/noun alone. For **functional options** `With*` is the established convention (`WithTimeout(d)`); a strong bare name (`llm.SystemPrompt(...)`) is also fine — be consistent per package |
| Abbrev with >1 meaning (`Meta`, `Ctx`, `Cfg`) | Full unambiguous word: `Metadata`, `Context`, `Config` |
| `Store`/`Manager`/`Service`/`Provider`/`Factory` suffix | Name by behavior/identity: `Model`, `Lookup`, `Resolver` |
| `GetXxx` on a type already named `Xxx` | Just `Get` — receiver provides context |
| `LoadFile`/`Parse` as a constructor | Encode source: `FromFile`, `FromTOML` |
| `NewFoo()` in a multi-constructor package | Drop `New`: `Bash()` not `NewBash()` |
| Java-ish compounds (`TrustLevel`, `ContentKind`) | Short nouns: `Trust`, `Kind` |
| Mechanism name (`Exceptions`, `TaintedBy`) | Name by purpose: `Context`, `Origins` |
| Error string capitalised / trailing period | lowercase, no punctuation (composes mid-sentence) |
| Renamed a type but not its file/config/tests/comments | Follow every breadcrumb: type → config → fields → file → test → comments |
| `snake_case` / `ALL_CAPS` / `K`-prefix names | `MixedCaps` / `mixedCaps` always — incl. unexported (`maxLength`) and constants (named by role) |
| `Url`, `Id`, `Http`, `apiId` | Keep each initialism one case: `URL`, `ID`, `HTTP`, `ServeHTTP`, `appID` |
| Receiver `this`/`self`/`me`, or different letters per method | 1–2 letter abbrev of the type, **consistent across every method**; omit if unused |
| One-method interface not `-er` | Name it by the method: `Reader`, `Formatter`, `Limiter` |
| `ToString()` / `ToBytes()` | `String()` / conventional method names with matching signatures |
| Package `myUtil`, `Helpers`, `base64Encoding`, underscores/caps | short, all-lowercase, no underscores; the base name of its dir; avoid `util`/`common`/`api` |
| Long name in a tiny scope (`lineCount` for a loop local) | Scale name length to scope: short locals (`i`, `c`, `r`), descriptive globals |
| Variable name shadows a stdlib package (`url`, `path`) | Rename to avoid forcing client shadowing/renames |

Final gate: write the name at its **call site** and read it aloud (`model, err := llm.New(cfg)`). If
you stumble, it's wrong.
