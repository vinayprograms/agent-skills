# refactor.propose — propose before you touch the code

Refactoring someone's code unilaterally is rude and risky. Present the plan; get agreement; then
act. (Skipped only for *trivial* refactors, which come straight from `investigate.refactor`.)

## Steps
1. Show the user the **smell→fix list**: what's wrong and what each change will be.
2. State what's **preserved** (observable behavior, error semantics, concurrency) vs what's
   **intentionally changing** (any exported rename / signature change). Call out **breaking changes**
   to a public API explicitly — these need the user's nod, not just a mention.
3. State the **impact set**: every call-site/consumer affected by the intended changes.
4. For any rename, note you'll resolve it via `../rubric/naming/gauntlet.md`.
5. Get agreement, or adjust the plan to their steer. Conform to the codebase's existing conventions.

## Produces
An **agreed refactor plan** (a strawman the user has poked and approved).

## Next
- Agreed → `implement.md`
- User wants a different scope/approach → revise here, or back to `investigate.refactor.md`
- User declines → stop.
