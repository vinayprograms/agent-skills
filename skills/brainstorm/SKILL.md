---
name: brainstorm
description: Balanced reasoning via parallel creative and critical analysis. Spawns both perspectives independently,
then synthesizes.
allowed-tools: Task
user-invocable: true
---

# Balanced-Mind Reasoning

When given a problem, execute this process:

## Step 1: Prepare the context

Read the discussion till now from `shared-reasoning.md` if it exists. Use that to identify arguments that have already been agreed upon as well as points of contention that need further exploration. Additionally, user may have provided their perspective on this discussion that will help you continue the analysis further.

## Step 1: Parallel Analysis

Spawn BOTH agents simultaneously with parallel calls:
- `creatives` agent with the EXACT original problem
- `devils-advocate` agent with the EXACT original problem

CRITICAL: Pass the original problem verbatim to both. Do NOT summarize, interpret, or add context. Each agent must see identical input.

## Step 2: Wait for Both

Do not proceed until both agents have returned their complete analysis.

## Step 3: Synthesize (Neutral Stance)

Present findings in this structure:
```
## Creative Perspective
[Summarize creative-mind's output]

## Critical Perspective
[Summarize critical-mind's output]

### Convergence (High Confidence)
Where both perspectives agree or complement each other.

### Divergence (Needs Resolution)
Where they conflict. Present both sides without picking a winner.

### Blind Spots
What neither perspective addressed.

### Recommendation
Your synthesis. Acknowledge which perspective you're weighting more heavily
and why. Be explicit about uncertainty.
```

## Step 4: Record Keeping

Write all your output to `shared-reasoning__<topic>.md` where `<topic>` is the topic of debate. It should be written into the directory that currently contains files related to the topic being discussed.
- This is required when I repeateadly invoke this skill to refine the problem over multiple iterations.
- You also have to write user's feedback into this file so that future iterations can take that into account.
