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
├── hooks/                     # Hook configurations (hooks.json)
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

### Hooks
Hook configurations in `hooks/` directory. Hooks are defined in `hooks.json` and referenced from `plugin.json`. Hooks inject prompts or run commands on Claude Code events.

Supported hook types:
- `prompt`: Injects instructions into Claude's context
- `command`: Runs shell commands
- `agent`: Spawns subagents

## Adding Resources

- Commands: Add `.md` files to `commands/` with appropriate frontmatter
- Agents: Add `.md` files to `agents/` describing agent behavior
- Skills: Create directory in `skills/` with `SKILL.md` and any reference files
- Hooks: Add configurations to `hooks/hooks.json` and ensure `plugin.json` references it
- After adding new resources, update README.md to list them

Use kebab-case for all file and directory names.

## Version Management

Plugin version is maintained in `.claude-plugin/plugin.json` only. Claude Code reads the version from `plugin.json` when installing/caching plugins - `marketplace.json` version fields are ignored.

### When to Bump Versions

**Always bump version before using /ship.** Follow semantic versioning (semver) based on conventional commit types:

- **Major (x.0.0)**: Breaking changes to plugin structure, command signatures, or behavior (`BREAKING CHANGE:` footer)
- **Minor (0.x.0)**: New features (`feat:`), new commands/agents/skills, backwards compatible
- **Patch (0.0.x)**: Bug fixes (`fix:`), documentation (`docs:`), chores (`chore:`)

### Commit and Tag Format

After bumping version in `.claude-plugin/plugin.json`:

1. Commit version bumps separately with format: `chore: bump version to X.Y.Z`
2. Create an annotated git tag: `git tag -a vX.Y.Z -m "Release version X.Y.Z"`
3. Push the tag: `git push origin vX.Y.Z`

**Versions and tags are immutable.** Never force-push tags. If a version was tagged incorrectly (e.g., plugin.json wasn't updated), bump to the next patch version instead.

## Distribution

Users can add this marketplace to Claude Code using:
```
/plugin marketplace add https://github.com/cacack/claude-code-plugins
```
