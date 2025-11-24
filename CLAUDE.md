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
  "name": "cacack",
  "owner": {...},
  "plugins": [{
    "name": "cacack",
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

## Version Management

This repository is configured as a **single-plugin marketplace** where all resources are distributed as one cohesive plugin. The version numbers should stay synchronized across all configuration files.

### When to Bump Versions

After creating commits, bump version numbers following semantic versioning (semver) based on conventional commit types:

- **Major (x.0.0)**: Breaking changes to plugin structure, command signatures, or behavior (`BREAKING CHANGE:` footer)
- **Minor (0.x.0)**: New features (`feat:`), new commands/agents/skills, backwards compatible
- **Patch (0.0.x)**: Bug fixes (`fix:`), documentation (`docs:`), chores (`chore:`)

### Version Fields to Update

Since this is a single-plugin marketplace, keep these three version fields synchronized:

1. **`marketplace.json`**:
   - `metadata.version` (marketplace distribution version)
   - `plugins[0].version` (the "cacack" plugin version)
2. **`plugin.json`**:
   - `version` (plugin definition version)

All three should have the same version number since they represent the same release unit.

### Commit Format

Always commit version bumps separately with format: `chore: bump version to X.Y.Z`

## Distribution

Users can add this marketplace to Claude Code using:
```
/plugin marketplace add https://github.com/cacack/claude-code-plugins
```
