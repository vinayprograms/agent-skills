---
name: go
description: >
  Idiomatic Go design and engineering, run as a routed, gated workflow. Use for ANY Go work —
  writing new code, fixing bugs, refactoring, extracting/splitting packages, reviewing APIs or
  specs, debugging, optimizing, cutting releases, or answering "is this idiomatic?". Covers
  current Go (through 1.25), package design, errors, concurrency, testing, HTTP services,
  CLIs (Cobra/Viper), desktop apps (Wails), safe file operations, and release engineering.
  Also triggers on "write Go", "make this idiomatic", "design this package", "review this API",
  "refactor this", "split this", "clean up this Go code", and any mention of golang, go.mod,
  cobra, viper, or wails. Pushes simplicity and kills over-abstraction.
metadata:
  author: vinay
  version: 2.2.2
  category: code-quality
---

# Go

This skill is a **digraph of small files**, not a rulebook to read top-to-bottom. It merges the
routed workflow, the design rubric, and domain knowledge distilled from
[spf13/go-skills](https://github.com/spf13/go-skills) (MIT).

**The tree:**
- `chunks/` — the workflow: small process steps wired by `## Next` edges.
- `rubric/` — the judgment: what good Go looks like; the gates (`simplify`, `critique`) consult it.
- `reference/` — the knowledge: current-Go currency (`modern-go.md`) and domain leaves (HTTP, CLI,
  Wails, files, releases, logging, packages, debugging), loaded only when the task touches them.

**How to use it:**
1. Start at `chunks/triage.md`. Always.
2. Load **only the one file you need next** — never read the whole skill into context.
3. Each chunk ends with a `## Next` section listing `condition → file` edges. Do the chunk's work,
   then pick the edge that matches what actually happened (your decision, or the user's input) and
   load that file.
4. Triage also flags **domain leaves** (`reference/…`). Carry them forward; the chunk that writes
   or judges code loads them there, not at triage time.
5. The path is **not** decided upfront. It emerges, one edge at a time.

Do not skim all the files. Bulk dilutes focus; one small file applied *now* is what makes the
guidance bind.

**Portability — any model, any harness.** The skill assumes nothing beyond the ability to read
files and run shell commands. If your harness lacks a feature, use the fallback; never skip the step:
- **No sub-agents** → do the work single-threaded: `decompose` uses `chunks/decompose.checkpoint.md`;
  for refactor/migrate sweeps, run each unit yourself and re-orient from the ledger between units;
  for `simplify`'s high-stakes verifier, re-read your revised diff cold in a separate adversarial
  pass before finishing.
- **No hooks** → nothing changes: `chunks/verify.md` runs the full baseline manually; the hook is
  only a backstop.
- **Small context window** → hold at most SKILL.md + the current chunk + one rubric/reference leaf
  at a time. Ledger files (`.go-refactor/`, `.go-decompose/`, `.go-migrate/`) are the memory —
  re-read them, never trust the transcript.

→ Load `chunks/triage.md`.
