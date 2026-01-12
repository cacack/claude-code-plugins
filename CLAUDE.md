# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal Claude Code plugin marketplace following the official multi-plugin pattern.

## Design Principles

Resources follow the [Handyman Principle](./plugins/cacack/docs/handyman-principle.md): context is scarce.

Key guidelines (see [design-guidelines.md](./plugins/cacack/docs/design-guidelines.md)):
- **Specialization over generalization** - focused agents/commands that do one thing well
- **Skills as programs** - invoke real tools, produce verifiable output
- **External memory** - externalize state to files, don't assume context persists

## Repository Structure (Canonical - Do Not Deviate)

This structure follows Claude Code's official plugin marketplace standards (matching `anthropics/claude-plugins-official`):

```
repo-root/
├── .claude-plugin/
│   └── marketplace.json   # Marketplace catalog only
├── plugins/
│   └── cacack/            # Plugin in subdirectory
│       ├── .claude-plugin/
│       │   └── plugin.json    # Plugin metadata
│       ├── agents/            # Agent definitions (*.md)
│       ├── commands/          # Slash commands (*.md)
│       ├── docs/              # Design principles and guidelines
│       ├── hooks/             # Hook configurations (hooks.json)
│       └── skills/            # Autonomous workflows (SKILL.md dirs)
└── README.md
```

### Structure Rules

1. **marketplace.json** lives at `.claude-plugin/marketplace.json` (marketplace root)
2. **plugin.json** lives at `plugins/cacack/.claude-plugin/plugin.json` (each plugin has its own)
3. **source** in marketplace.json points to plugin directory: `"./plugins/cacack"`
4. **Resource directories** (commands/, agents/, skills/, hooks/) are inside the plugin directory
5. **Paths in plugin.json** are relative to **plugin root** (`plugins/cacack/`)

### Path Resolution

```
marketplace.json location: .claude-plugin/marketplace.json
source: "./plugins/cacack" → plugin root = plugins/cacack/
plugin.json location:      → plugins/cacack/.claude-plugin/plugin.json
hooks (auto-loaded):       → plugins/cacack/hooks/hooks.json
```

## Resource Types

### Commands
Slash commands in `plugins/cacack/commands/` directory as `.md` files with frontmatter:
```yaml
---
description: Brief description
argument-hint: [optional]
allowed-tools: [optional]
---
```

### Agents
Agent definitions in `plugins/cacack/agents/` directory as `.md` files.

### Skills
Autonomous workflows in `plugins/cacack/skills/` directory. Each skill is a directory with `SKILL.md`.

### Hooks
Hook configurations in `plugins/cacack/hooks/hooks.json`. The standard `hooks/hooks.json` is auto-loaded by Claude Code 2.1.4+; do NOT reference it in plugin.json (causes duplicate error).

## Claude Code 2.1+ Features

Features available in Claude Code 2.1.0 and later:

### Skill Frontmatter Options
```yaml
---
name: skill-name
description: What this skill does
user-invocable: false    # Hide from slash command menu (for internal/support skills)
context: fork            # Run in isolated sub-agent context
agent: explore           # Specify agent type for execution
---
```

### Hooks in Frontmatter
Skills and commands can define hooks directly in frontmatter instead of hooks.json:
```yaml
---
description: ...
hooks:
  PreToolUse:
    - type: command
      command: "echo $TOOL_NAME"
      once: true         # Run only once per session
---
```

### Hook Types
- `PreToolUse` / `PostToolUse` - Tool execution events
- `Stop` - Main conversation stop
- `SubagentStop` - Sub-agent completion (separate from Stop since v2.0.41)
- `SessionStart` - Session initialization
- `UserPromptSubmit` - User input events

### Auto-Loading Behavior
- `hooks/hooks.json` is auto-loaded from plugin directory (don't reference in plugin.json)
- Skills hot-reload without session restart
- MCP servers support dynamic tool/resource updates via `list_changed` notifications

## Adding Resources

- Commands: Add `.md` files to `plugins/cacack/commands/`
- Agents: Add `.md` files to `plugins/cacack/agents/`
- Skills: Create directory in `plugins/cacack/skills/` with `SKILL.md`
- Hooks: Add to `plugins/cacack/hooks/hooks.json`
- Update README.md after adding resources

Use kebab-case for all file and directory names.

## Version Management

Plugin version must be maintained in BOTH files and kept in sync:
- `plugins/cacack/.claude-plugin/plugin.json` - canonical source
- `.claude-plugin/marketplace.json` - in the plugin entry's `version` field

### marketplace.json Plugin Entry

Each plugin entry in marketplace.json MUST include these fields (matching official marketplace pattern):
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "...", "email": "..." },
  "source": "./plugins/plugin-name",
  "strict": true
}
```

### When to Bump Versions

**Always bump version before using /ship.** Follow semver:

- **Major (x.0.0)**: Breaking changes
- **Minor (0.x.0)**: New features (`feat:`)
- **Patch (0.0.x)**: Bug fixes (`fix:`), docs, chores

### Commit and Tag Format

After bumping version in BOTH `plugins/cacack/.claude-plugin/plugin.json` AND `.claude-plugin/marketplace.json`:

1. Commit: `chore: bump version to X.Y.Z`
2. Tag: `git tag -a vX.Y.Z -m "Release version X.Y.Z"`
3. Push: `git push origin vX.Y.Z`

**Versions and tags are immutable.** Never force-push tags.

## Testing

### Before Committing
Always validate the plugin structure:
```bash
claude plugin validate ./plugins/cacack
```

### Local Testing (before pushing)
Test installation locally to catch issues before pushing:
```bash
# Remove remote marketplace and add local
claude plugin marketplace remove cacack
claude plugin marketplace add ./

# Install and verify
claude plugin install cacack@cacack

# After testing, switch back to remote
claude plugin marketplace remove cacack
claude plugin marketplace add https://github.com/cacack/claude-code-plugins
```

### CI Validation
The GitHub Actions workflow automatically:
1. Validates plugin structure on every push/PR
2. Checks version sync between marketplace.json and plugin.json
3. Requires version bump when resources change

## Distribution

```
/plugin marketplace add https://github.com/cacack/claude-code-plugins
```
