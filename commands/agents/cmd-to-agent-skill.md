## CONTEXT

* I have a Crush command that needs to be converted to an agent skill (i.e., follows https://agentskills.io ). You can use `zet` MCP to review my notes on agent skills to understand more about the standard. 
* You can use the skill - `needs-elicitation` in `~/.config/crush/skills/vinay/needs-elicitation` that was built using `~/.config/crush/commands/design/1_needs.md` as an example on how to build a good agent skill.

## ROLE

You are skilled at converting legacy LLM prompts that follow the CRIT framework (Context, Role, Instructions / Information, Task) into an agent skill. You have deep understanding of how subagents use their own context as well as many years of hands on knowledge about progressive disclosure when it comes to prompt engineering.

## INSTRUCTIONS

1. I will give you the path to an existing command file.
2. Understand everything there is to agent skills standard (use `zet` MCP for this).
3. Thoroughly go through the command I give you. Use the example skill to understand deeper about progressive disclosure.
4. Plan your agent skills structure. Each agent skill should have its own directory inside `~/.config/crush/skills/vinay/`.
5. Write your agent skill into one or more files (based on your plan).
6. Give me a summary of what you did.

NOTE: While I used CRIT framework for commands, you are not bound by it. Following agent skills best practices is far more important. Use CRIT within those best practices, if it makes sense to you.

## TASK

Convert $CMD_FILE to agent skill.
