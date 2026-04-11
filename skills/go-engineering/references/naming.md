# Naming Rules

## Rules

1. **No package-name stuttering.** `credentials.Lookup` not `credentials.CredentialLookup`. At the call site, the package already provides context.

2. **Single word is the target.** One strong word beats two adequate ones. `broadcast` not `broadcastToSubscribers`. `dispatch` not `dispatchToQueueGroup`. `Metadata` not `MetadataField`. If you're reaching for a second word, the first word isn't strong enough yet — or the abstraction needs rethinking.

3. **Brevity is not clarity.** Shorten only when the abbreviated form has exactly one meaning in context. `Meta` means Facebook, meta-programming, and metadata. `Metadata` is unambiguous. Never shorten to save characters; shorten only when the short form is as precise as the long one.

4. **No `On` prefix for Go methods or fields.** `OnShutdown`, `OnPrompt`, `OnError` are JavaScript event listener conventions. Go has no such idiom. Use the verb directly: `Shutdown`, `Prompt`, `Error`. The receiver already provides the subject.

5. **Interfaces describe behavior or identity.** Avoid `Store`, `Manager`, `Service`, `Provider`, `Factory`. Prefer names that answer "what can I do with this?" — `Model`, `Lookup`, `Resolver`.

6. **Method names assume the receiver as subject.** `store.Get("openai")` — drop redundant context. `GetCredential` on a credentials type is stuttering.

7. **Constructor names encode the source.** `FromFile()`, `FromEnv()`, `FromTOML()`. `New()` is for the package's primary type. Drop `New` for secondary constructors: `Bash()`, `Read()`, `Pwd()`.

8. **Test the name at the call site.** Write the usage line. Read it aloud. If you stumble, rename.
   ```go
   model, err := llm.New(llm.Config{Service: "anthropic", Model: "claude-sonnet-4-20250514"})
   resp, err := model.Chat(ctx, llm.Prompt("summarize this"))
   ```

9. **Rename the config fields too.** `Provider: "anthropic"` → `Service: "anthropic"` when the type is renamed from Provider to Model. Follow every breadcrumb: type → config → fields → file → test file → comments.

10. **Option functions don't need `With` prefix.** `llm.SystemPrompt("...")` not `llm.WithSystemPrompt("...")`.

11. **Short nouns over compound names.** `Trust` not `TrustLevel`. `Kind` not `ContentKind`. Let the package provide context.

12. **Error strings are lowercase, no trailing punctuation.** They compose mid-sentence: `fmt.Errorf("loading config: %w", err)`.

13. **Use `%q` for strings in errors/logs.** Handles empty strings clearly and escapes special characters.

## Naming Protocol

Names rarely land right on the first attempt. Good names emerge from adversarial debate, not inspection. Follow this sequence every time you name something non-trivial.

### Step 1 — Propose, don't commit

Write down a candidate. Resist the urge to justify it. Justification creates attachment; attachment kills objectivity.

### Step 2 — Generate alternatives before evaluating anything

Force at least 2–3 alternatives. This is non-negotiable. The most common naming failure is anchoring on the first plausible option and arguing it into acceptability rather than finding the best one.

### Step 3 — Run the adversarial gauntlet on every candidate

For each name, challenge it from all five angles. A name must survive all five to be acceptable:

| Challenge | Question to ask |
|---|---|
| **Call site** | Write `package.Name` aloud. Does it flow, or does it make you pause? |
| **Declaration** | Write `var x package.Type`. Does it stutter? |
| **Domain accuracy** | Does it name what the thing IS? Or what it does, or how it works? |
| **Ambiguity** | Could a developer unfamiliar with this codebase read it differently? |
| **Single-word test** | If it's two words, is the first word strong enough on its own? If not, it's weak, not compound. |

### Step 4 — The challenge must be genuine

If you proposed the name, you are biased toward it. The adversarial round is compromised if the proposer also runs it. Either:
- Explicitly adopt an adversarial mindset with no access to your reasoning, or
- Delegate the challenge to a fresh perspective that hasn't seen why the name was chosen.

### Step 5 — Repeat until a name survives

One round is rarely enough. After a finalist emerges, run the gauntlet again as if seeing it for the first time. If it still holds, accept it. If nothing survives multiple rounds, the abstraction may be wrong — go back to the domain, not just the dictionary.

### Examples from practice

| Candidate | Challenge that broke it | Resolution |
|---|---|---|
| `ShutdownCoordinator` | Call site: `shutdown.ShutdownCoordinator` — stutters badly | → `Sequence` |
| `Coordinator` | Domain accuracy: too generic; could coordinate anything | → debated `Group`, `Plan`, `Sequence` → `Sequence` survived |
| `distribute` | Domain accuracy: implies spreading to many; we select exactly one | → `dispatch` |
| `queue` (function) | Domain accuracy: "queue" means add to a queue, not select from one | → `dispatch` |
| `Meta` | Ambiguity: means Facebook, meta-programming, and metadata | → `Metadata` kept |
| `deliverToSubscribers` | Single-word test: two words, first word too weak alone | → `broadcast` |
| `OnShutdown` | Call site: `OnX` is JavaScript; Go has no "On" convention | → `Shutdown` |

## Anti-Patterns

| Smell | Fix |
|---|---|
| `package.PackageThing` (stuttering) | Drop the package prefix from the type name |
| Two-word function name (`deliverToSubscribers`, `broadcastToAll`) | One verb that owns the purpose: `broadcast`, `deliver` |
| `OnX` method or field (`OnShutdown`, `OnPrompt`) | Drop `On`: `Shutdown`, `Prompt` — Go is not JavaScript |
| Abbreviated name with multiple meanings (`Meta`, `Ctx`, `Cfg`) | Use the full unambiguous word: `Metadata`, `Context`, `Config` |
| `Store`, `Manager`, `Service`, `Provider`, `Factory` suffix | Name by behavior or identity |
| `GetXxx` on a type that is already `Xxx` | Just `Get` — receiver provides context |
| `LoadFile`, `Parse` as constructor names | `FromFile`, `FromTOML` — encode source, not action |
| `NewFoo()` in a multi-constructor package | Drop `New`: `Bash()` not `NewBash()` |
| `WithFoo` option prefix | Drop `With`: `llm.SystemPrompt()` |
| Java-ish compounds (`TrustLevel`, `ContentKind`) | Short nouns: `Trust`, `Kind` |
| Renaming a type but not the file/tests/comments | Follow every breadcrumb |
| `Exceptions` for context data | Name by purpose: `Context` |
