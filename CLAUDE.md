# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal Claude Code plugin marketplace following the official multi-plugin pattern.

## Design Principles

Resources follow the [Handyman Principle](./plugins/cacack/docs/handyman-principle.md): context is scarce.

Key guidelines (see [design-guidelines.md](./plugins/cacack/docs/design-guidelines.md)):
- **Specialization over generalization** - focused agents/skills that do one thing well
- **Skills as programs** - invoke real tools, produce verifiable output
- **External memory** - externalize state to files, don't assume context persists

## Worktree Workflow

The `play → do → panel → ship` cycle (and `deliver-milestone`) runs inside a dedicated git worktree under `.claude/worktrees/` so simultaneous parallel cycles never pollute each other's working tree.

- **`/play`** creates/enters the worktree (auto, silent) — it is the cycle entry point. **`/do`** does the same in its direct (free-text) mode, since that path skips `/play`.
- **`/do` (batch/prompts mode), `/panel-review`, `/ship`** inherit the worktree via the session working directory — no action needed; they must not create a nested one.
- The worktree **persists after `/ship`** (PR open) for inspection. Remove it **after the PR merges**: `deliver-milestone` does this automatically; for a standalone cycle, use `ExitWorktree` with `action: remove`.
- `deliver-milestone` gives **each issue its own worktree**, torn down after that issue merges.

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
│       ├── docs/              # Design principles and guidelines
│       ├── hooks/             # Hook configurations (hooks.json)
│       └── skills/            # Skills (SKILL.md dirs) - primary resource type
└── README.md
```

### Structure Rules

1. **marketplace.json** lives at `.claude-plugin/marketplace.json` (marketplace root)
2. **plugin.json** lives at `plugins/cacack/.claude-plugin/plugin.json` (each plugin has its own)
3. **source** in marketplace.json points to plugin directory: `"./plugins/cacack"`
4. **Resource directories** (agents/, skills/, hooks/) are inside the plugin directory
5. **Paths in plugin.json** are relative to **plugin root** (`plugins/cacack/`)
6. **Do NOT put** resource directories inside `.claude-plugin/` - only `plugin.json` goes there

### Path Resolution

```
marketplace.json location: .claude-plugin/marketplace.json
source: "./plugins/cacack" → plugin root = plugins/cacack/
plugin.json location:      → plugins/cacack/.claude-plugin/plugin.json
hooks (auto-loaded):       → plugins/cacack/hooks/hooks.json
```

## Resource Types

### Skills (Primary)

Skills are the primary resource type. Each skill is a directory with `SKILL.md` in `plugins/cacack/skills/`. Commands and skills are unified - both create slash commands.

Skill frontmatter:
```yaml
---
name: skill-name                     # Optional; defaults to directory name
description: What this does          # Recommended - Claude uses for auto-invocation
allowed-tools: Read, Grep            # Restrict tool access
argument-hint: <args>                # Show in slash command menu
disable-model-invocation: true       # Manual /slash only, prevent auto-invocation
user-invocable: false                # Hide from menu (Claude-only, background knowledge)
model: sonnet                        # Override model (sonnet, opus, haiku, inherit)
effort: medium                       # Effort level (low, medium, high, max)
context: fork                        # Run in isolated sub-agent context
agent: explore                       # Sub-agent type for fork context
paths: "src/**,tests/**"             # Glob patterns for auto-activation
shell: bash                          # Shell for !`cmd` blocks (bash, powershell)
hooks:                               # Scoped to this skill's lifecycle
  PreToolUse:
    - type: command
      command: "echo $TOOL_NAME"
---
```

String substitutions: `$ARGUMENTS`, `$0`/`$1`/`$2` (positional), `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`

Dynamic context: `` !`shell-command` `` runs as preprocessing before skill content is sent.

### Agents

Agent definitions in `plugins/cacack/agents/` directory as `.md` files.

Agent frontmatter:
```yaml
---
name: agent-name
description: What this agent does and when to use it
tools: Read, Glob, Grep              # Tool allowlist
disallowedTools: Write, Edit         # Tool denylist
model: sonnet                        # sonnet, opus, haiku, inherit
effort: medium                       # Effort level (low, medium, high, max)
permissionMode: default              # default, acceptEdits, dontAsk, bypassPermissions, plan
maxTurns: 20                         # Limit agentic iterations
skills:                              # Preload full skill content at startup
  - skill-name
mcpServers:                          # MCP servers scoped to this agent
  slack: slack
memory: user                         # Persistent cross-session memory (user, project, local)
background: false                    # Run as background task by default
initialPrompt: |                     # Auto-submitted first user turn
  Review recent commits
isolation: worktree                  # Run in isolated git worktree
hooks: {}                            # Scoped to this agent
---
```

### Hooks

Hook configurations in `plugins/cacack/hooks/hooks.json`. Auto-loaded by Claude Code 2.1.4+; do NOT reference in plugin.json.

Hook event types:
- `SessionStart` - Session begins/resumes (matcher: `startup`, `resume`, `clear`, `compact`)
- `InstructionsLoaded` - CLAUDE.md/rules loaded (matcher: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact`)
- `UserPromptSubmit` - User submits prompt
- `PreToolUse` - Before tool executes (can block; matcher: tool name regex)
- `PostToolUse` - After tool succeeds (matcher: tool name regex)
- `PostToolUseFailure` - After tool fails (matcher: tool name regex)
- `PermissionRequest` - Permission dialog appears (matcher: tool name regex)
- `Notification` - Notification sent (matcher: `permission_prompt`, `idle_prompt`, `auth_success`)
- `SubagentStart` / `SubagentStop` - Sub-agent lifecycle (matcher: agent type)
- `TaskCreated` - Task created via TaskCreate
- `TaskCompleted` - Task being marked complete
- `Stop` - Claude finishes responding
- `StopFailure` - API error at turn end
- `TeammateIdle` - Agent team teammate going idle
- `ConfigChange` - Config file changes (matcher: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`)
- `CwdChanged` - Working directory changes
- `FileChanged` - Watched file changes (matcher: filename basename)
- `WorktreeCreate` / `WorktreeRemove` - Git worktree lifecycle
- `PreCompact` - Before context compaction (matcher: `manual`, `auto`)
- `PostCompact` - After context compaction (matcher: `manual`, `auto`)
- `Elicitation` / `ElicitationResult` - MCP user input lifecycle (matcher: MCP server name)
- `SessionEnd` - Session terminates (matcher: `clear`, `resume`, `logout`, `other`)

Hook execution types:
- `type: "command"` - Run shell command (default)
- `type: "http"` - POST event JSON to URL (external services, audit logging)
- `type: "prompt"` - Single-turn LLM evaluation (returns `ok: true/false`)
- `type: "agent"` - Multi-turn sub-agent with tool access (returns `ok: true/false`)

Hook common fields: `timeout` (seconds), `if` (permission rule syntax filter), `async` (run in background)

### Auto-Loading Behavior
- `hooks/hooks.json` is auto-loaded from plugin directory (don't reference in plugin.json)
- Skills hot-reload without session restart
- MCP servers support dynamic tool/resource updates via `list_changed` notifications

## Adding Resources

- Skills: Create directory in `plugins/cacack/skills/<name>/` with `SKILL.md`
- Agents: Add `.md` files to `plugins/cacack/agents/`
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

## References

### Anthropic Documentation (Authoritative)
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Create plugins](https://code.claude.com/docs/en/plugins.md)
- [Skills](https://code.claude.com/docs/en/skills)
- [Subagents](https://code.claude.com/docs/en/sub-agents.md)
- [Hooks](https://code.claude.com/docs/en/hooks-guide.md)
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces.md)
- [Best practices](https://code.claude.com/docs/en/best-practices)
- [Context engineering guide](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- [Complete Guide to Building Skills (PDF)](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)

### Anthropic Official Plugins (Reference Implementations)
- [claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — skill-creator, plugin-dev, skill-development
- [anthropics/skills](https://github.com/anthropics/skills) — Public Agent Skills repository

### Community Resources
- [The Handyman Principle](https://vexjoy.com/posts/the-handyman-principle-why-your-ai-forgets-everything/) — context scarcity, agents/skills/plans model
- [Claude Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/) — triggering uses pure language understanding
- [Skills for Claude (blog.fsck.com)](https://blog.fsck.com/2025/10/16/skills-for-claude/) — separate "what" from "when"; hiding detail improves compliance

### Important Distinction
Our skill conventions (XML structure, required tags, verb-noun naming) go beyond Anthropic's requirements. Anthropic's own skills use plain markdown. Our conventions provide consistency and parseability benefits but are **our recommendations, not Anthropic requirements**. See `create-agent-skills/references/` for details.

Last audited: 2026-03-28 (v1.18.0)
