# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal Claude Code plugin collection organized as a single-plugin marketplace. Resources are organized in top-level directories following the taches-cc-resources pattern.

## Repository Structure

```
├── .claude-plugin/
│   └── marketplace.json       # Points to root with "source": "./"
├── agents/                    # Agent definitions (*.md)
├── commands/                  # Slash commands (*.md)
└── skills/                    # Autonomous workflows (directories with SKILL.md)
```

The marketplace.json references the root directory as a single plugin, making all resources available together.

### Marketplace Format

```json
{
  "name": "chris-personal-plugins",
  "owner": {...},
  "plugins": [{
    "name": "chris-personal-plugins",
    "source": "./",
    "version": "1.0.0",
    "strict": true
  }]
}
```

## Resource Types

### Commands
Slash commands in `commands/` directory. Commands are `.md` files with frontmatter:
```yaml
---
description: Brief description of what the command does
argument-hint: [optional argument description]
allowed-tools: Optional tool restrictions
---
```

### Agents
Agent definitions in `agents/` directory. Agents are `.md` files with markdown content describing agent behavior and capabilities.

### Skills
Autonomous workflows in `skills/` directory. Each skill is a directory containing:
- `SKILL.md` - Main skill definition with frontmatter
- `references/` - Supporting documentation and patterns (optional)

Skills use frontmatter:
```yaml
---
name: skill-name
description: Detailed description of skill purpose and use cases
---
```

## Adding Resources

- Commands: Add `.md` files to `commands/` with appropriate frontmatter
- Agents: Add `.md` files to `agents/` describing agent behavior
- Skills: Create directory in `skills/` with `SKILL.md` and any reference files
- After adding new resources, update README.md to list them

Use kebab-case for all file and directory names.

## Distribution

Users can add this marketplace to Claude Code using:
```
/plugin marketplace add https://github.com/cclonch/claude-code-plugins
```
