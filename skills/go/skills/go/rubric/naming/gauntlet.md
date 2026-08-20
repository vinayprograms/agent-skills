# rubric / naming / gauntlet — resolve ONE contested name

Good names emerge from adversarial debate, not inspection. Use this when a single name is non-trivial
or contested (the checklist flagged it, or it names a new exported API).

## Protocol
1. **Propose, don't commit.** Write a candidate. Don't justify it — justification breeds attachment.
2. **Generate 2–3 alternatives before evaluating any.** Non-negotiable. Anchoring on the first
   plausible name is the most common failure.
3. **Run the 5-angle gauntlet on each candidate.** A name must survive all five:
   - **Call site** — `package.Name` aloud: does it flow or make you pause?
   - **Declaration** — `var x package.Type`: does it stutter?
   - **Domain accuracy** — does it name what the thing IS, not what it does or how it works?
   - **Ambiguity** — could a stranger to this codebase read it differently?
   - **Single-word test** — if two words, is the first strong enough alone? If not, it's weak, not compound.
4. **Make the challenge genuine.** The proposer is biased. Adopt a fresh adversarial mindset with no
   access to your own reasoning — or delegate the challenge to a separate perspective.
5. **Repeat until one survives multiple rounds.** If nothing survives, the abstraction is wrong — go
   back to the domain, not the dictionary.

## Worked examples
| Candidate | Challenge that broke it | Resolution |
|---|---|---|
| `ShutdownCoordinator` | Call site `shutdown.ShutdownCoordinator` stutters | → `Sequence` |
| `Coordinator` | Domain: too generic, coordinates anything | → `Sequence` |
| `distribute` | Domain: implies many; we select exactly one | → `dispatch` |
| `Meta` | Ambiguity: Facebook / meta-programming / metadata | → `Metadata` |
| `deliverToSubscribers` | Single-word test: first word too weak | → `broadcast` |
| `OnShutdown` | Call site: `OnX` is JavaScript | → `Shutdown` |

## When two concepts force compound names
Absorb the prefix into a **sub-package** so the package name carries context: `protocol.EventHandler`
→ `event.Handler`, `registry.ServiceEntry` → `service.Entry`. Worth it when a prefix is shared by 3+
types/constants; not for a single type (import overhead).
