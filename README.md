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
│   ├── zet.md                  # /docs:zet — create a zettel
│   ├── zet-diagram.md          # /docs:zet-diagram — zettel with diagrams
│   └── zet-fullsite.md         # /docs:zet-fullsite — full-site zettel generation
├── init/
│   ├── go.md                   # /init:go — scaffold a Go project
│   └── python.md               # /init:python — scaffold a Python project
└── tests/
    └── qa.md                   # /tests:qa — QA test planning

skills/             # Agent skills (specialized behaviors)
├── brainstorm/     # Balanced-mind reasoning skill
└── go-engineering/ # Go design and engineering guide
    ├── SKILL.md
    └── references/ # Reference material for Go conventions
```

## License

See [LICENSE](LICENSE).
