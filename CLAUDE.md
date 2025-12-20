# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal Claude Code plugin collection organized as a single-plugin marketplace.

## Repository Structure (Canonical - Do Not Deviate)

This structure follows Claude Code's documented plugin marketplace standards:

```
repo-root/
├── .claude-plugin/
│   ├── marketplace.json   # Marketplace catalog (source: "./")
│   └── plugin.json        # Plugin metadata (version, hooks, etc.)
├── agents/                # Agent definitions (*.md)
├── commands/              # Slash commands (*.md)
├── hooks/                 # Hook configurations (hooks.json)
└── skills/                # Autonomous workflows (SKILL.md dirs)
```

### Structure Rules

1. **marketplace.json** lives at `.claude-plugin/marketplace.json`
2. **plugin.json** lives at `.claude-plugin/plugin.json`
3. **source: "./"** in marketplace.json points to plugin root (repo root)
4. **Resource directories** (commands/, agents/, skills/, hooks/) are at repo root
5. **Paths in plugin.json** are relative to **plugin root** (repo root), so hooks uses `./hooks/hooks.json`

### Path Resolution

```
marketplace.json location: .claude-plugin/marketplace.json
source: "./"             → plugin root = repo root
plugin.json location:    → .claude-plugin/plugin.json
hooks in plugin.json:    → ./hooks/hooks.json (relative to plugin root, NOT to plugin.json)
```

## Resource Types

### Commands
Slash commands in `commands/` directory as `.md` files with frontmatter:
```yaml
---
description: Brief description
argument-hint: [optional]
allowed-tools: [optional]
---
```

### Agents
Agent definitions in `agents/` directory as `.md` files.

### Skills
Autonomous workflows in `skills/` directory. Each skill is a directory with `SKILL.md`.

### Hooks
Hook configurations in `hooks/hooks.json`, referenced from plugin.json as `./hooks/hooks.json`.

## Adding Resources

- Commands: Add `.md` files to `commands/`
- Agents: Add `.md` files to `agents/`
- Skills: Create directory in `skills/` with `SKILL.md`
- Hooks: Add to `hooks/hooks.json`
- Update README.md after adding resources

Use kebab-case for all file and directory names.

## Version Management

Plugin version must be maintained in BOTH files and kept in sync:
- `.claude-plugin/plugin.json` - canonical source, also contains hooks
- `.claude-plugin/marketplace.json` - in the plugin entry's `version` field

### marketplace.json Plugin Entry

Each plugin entry in marketplace.json MUST include these fields (matching official marketplace pattern):
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "...", "email": "..." },
  "source": "./",
  "strict": true
}
```

### When to Bump Versions

**Always bump version before using /ship.** Follow semver:

- **Major (x.0.0)**: Breaking changes
- **Minor (0.x.0)**: New features (`feat:`)
- **Patch (0.0.x)**: Bug fixes (`fix:`), docs, chores

### Commit and Tag Format

After bumping version in BOTH `.claude-plugin/plugin.json` AND `.claude-plugin/marketplace.json`:

1. Commit: `chore: bump version to X.Y.Z`
2. Tag: `git tag -a vX.Y.Z -m "Release version X.Y.Z"`
3. Push: `git push origin vX.Y.Z`

**Versions and tags are immutable.** Never force-push tags.

## Distribution

```
/plugin marketplace add https://github.com/cacack/claude-code-plugins
```
