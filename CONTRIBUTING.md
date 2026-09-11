## Repository Structure

```
├── .claude-plugin/
│   └── marketplace.json       # Marketplace configuration
├── agents/                    # Custom agent definitions
│   └── *.md
├── commands/                  # Custom slash commands
│   └── *.md
└── skills/                    # Autonomous workflows
    └── */
```

## Adding New Resources

1. Add command files to `commands/` directory
1. Add agent definitions to `agents/` directory
1. Add skills to `skills/` directory
1. Commit and push changes

## Before Committing

Verify the success criteria in [CONSTITUTION.md](CONSTITUTION.md):

```bash
make constitution-check
```

It validates every plugin, checks version sync between `plugin.json` and
`marketplace.json`, enforces plugin boundaries, and reports the criteria it
cannot settle mechanically rather than guessing at them. It exits non-zero on a
breach. A criterion that no longer reflects how the project works should be
changed in `CONSTITUTION.md`, with a note saying why it moved — not worked around
in the script.
