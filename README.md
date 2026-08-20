# claude-config

Personal Claude Code configuration: custom slash commands and skills.

## Structure

```
commands/           # Slash commands (invoked via /command-name)
├── code.md         # /code — guided coding
├── commit.md       # /commit — structured commits
├── crit.md         # /crit — critical review
├── agents/
│   └── cmd-to-agent-skill.md   # Convert commands to agent skills
├── design/
│   ├── design.md               # /design:design — system design
│   ├── needs-elicitation.md    # /design:needs-elicitation
│   ├── prj-mgmt.md             # /design:prj-mgmt — project management
│   ├── requirements.md         # /design:requirements
│   └── tech-requirements.md    # /design:tech-requirements
├── docs/
│   ├── research.md             # /docs:research
│   └── zet-diagram.md          # /docs:zet-diagram — zettel with diagrams
│                               # (zet/zet-fullsite consolidated into skills/zettelkasten)
├── init/
│   ├── go.md                   # /init:go — scaffold a Go project
│   └── python.md               # /init:python — scaffold a Python project
└── tests/
    └── qa.md                   # /tests:qa — QA test planning

skills/             # Agent skills (specialized behaviors)
├── brainstorm/     # Balanced-mind reasoning
├── go/             # Go plugin: routed, gated Go engineering workflow + correctness hooks
│   ├── hooks/      # gofmt on write; Stop hook enforcing vet/build/test -race
│   └── skills/go/  # The skill: SKILL.md router → chunks/ (workflow) →
│                   # rubric/ (judgment) → reference/ (domain knowledge, incl.
│                   # material distilled from spf13/go-skills: Cobra/Viper,
│                   # releases, Wails, safe file ops, modern-Go currency)
├── grill-me/       # Interview the user relentlessly about a plan until shared understanding
├── to-prd/         # Turn conversation context into a PRD, filed as a GitHub issue
├── to-tasks/       # Break a plan/spec into tracer-bullet vertical-slice tasks
└── zettelkasten/   # Convert blogs & doc sites into zettels (via the zet MCP)
```

## License

See [LICENSE](LICENSE).
