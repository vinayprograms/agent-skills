# advise — answer a Go question, no code change

The lightest route of all: the user wants an opinion or an explanation of a principle, not an edit
("is this idiomatic?", "channel or mutex here?", "should I export this?"). Answer; don't touch code.

## Steps
1. Answer the question directly, with a clear recommendation — not a survey of every option.
2. If it's an idiom/design question, ground the answer in the relevant rubric leaf
   (`../rubric/naming/`, `../rubric/api-design/interfaces.md`, …) so it's the skill's view, not just a
   vibe.
3. Give the **why** in one or two lines — the principle behind the answer.
4. If the question reveals real work (a refactor, a bug), say so and **offer** to route it — don't do
   it unasked.

## Produces
A direct answer + the reasoning. **Terminal.**

## Next
- Done. If the user wants the work done, return to `triage.md`.
