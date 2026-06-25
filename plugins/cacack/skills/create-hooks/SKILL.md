---
name: create-hooks
description: Expert guidance for creating, configuring, and using Claude Code hooks. Use when working with hooks, setting up event listeners, validating commands, automating workflows, adding notifications, or understanding hook types (PreToolUse, PostToolUse, Stop, SessionStart, UserPromptSubmit, etc).
---

<objective>
Hooks are event-driven automation for Claude Code that execute shell commands, LLM prompts, HTTP requests, or subagents in response to tool usage, session events, and user interactions. This skill teaches you how to create, configure, and debug hooks for validating commands, automating workflows, injecting context, and implementing custom completion criteria.

Hooks provide programmatic control over Claude's behavior without modifying core code, enabling project-specific automation, safety checks, and workflow customization.
</objective>

<context>
Hooks are handlers that execute in response to Claude Code events. They operate within an event hierarchy: events (PreToolUse, PostToolUse, Stop, etc.) trigger matchers (tool patterns) which fire hooks (commands, prompts, HTTP calls, or agents). Hooks can block actions, modify tool inputs, inject context, or simply observe and log Claude's operations.
</context>

<quick_start>
<workflow>
1. Create hooks config file:
   - Project: `.claude/hooks.json`
   - User: `~/.claude/hooks.json`
2. Choose hook event (when it fires)
3. Choose hook type (command, prompt, http, or agent)
4. Configure matcher (which tools trigger it)
5. Test with `claude --debug`
</workflow>

<example>
**Log all bash commands**:

`.claude/hooks.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '\"\\(.tool_input.command) - \\(.tool_input.description // \\\"No description\\\")\"' >> ~/.claude/bash-log.txt"
          }
        ]
      }
    ]
  }
}
```

This hook:
- Fires before (`PreToolUse`) every `Bash` tool use
- Executes a `command` (not an LLM prompt)
- Logs command + description to a file
</example>
</quick_start>

<hook_types>
Events are grouped by category below. Blocking hooks (Can block? = Yes) can return `"decision": "block"` to prevent the action.

### Session Events
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **SessionStart** | Session begins/resumes | No |
| **SessionEnd** | Session terminates | No |

### Tool Events
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **PreToolUse** | Before tool execution | Yes |
| **PostToolUse** | After tool succeeds | No |
| **PostToolUseFailure** | After tool fails | No |
| **PermissionRequest** | When the permission dialog appears | Yes |

### Agent / Task Events
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **Stop** | Claude attempts to stop | Yes |
| **StopFailure** | Turn ends due to an API error | No |
| **SubagentStart** | A subagent spawns | No |
| **SubagentStop** | A subagent attempts to stop | Yes |
| **TaskCreated** | A task is created via TaskCreate | No |
| **TaskCompleted** | A task is marked complete | No |
| **TeammateIdle** | An agent-team teammate is about to go idle | No |

### User Interaction Events
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **UserPromptSubmit** | User submits a prompt | Yes |
| **Notification** | Claude needs input | No |

### Context Events
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **PreCompact** | Before context compaction | Yes |
| **PostCompact** | After context compaction | No |
| **InstructionsLoaded** | CLAUDE.md / rules file loaded | No |
| **ConfigChange** | A configuration file changes | No |
| **CwdChanged** | Working directory changes | No |

### File Events
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **FileChanged** | A watched file changes | No |

### MCP Events
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **Elicitation** | An MCP server requests user input | Yes |
| **ElicitationResult** | User responds to an MCP elicitation | No |

### Worktree Events
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **WorktreeCreate** | A git worktree is created | No |
| **WorktreeRemove** | A worktree is cleaned up | No |

See [references/hook-types.md](references/hook-types.md) for detailed input/output schemas per event.
</hook_types>

<hook_anatomy>
<hook_type name="command">
**Type**: Executes a shell command

**Use when**:
- Simple validation (check file exists)
- Logging (append to file)
- External tools (formatters, linters)
- Desktop notifications

**Input**: JSON via stdin
**Output**: JSON via stdout (optional)

```json
{
  "type": "command",
  "command": "/path/to/script.sh",
  "timeout": 30000
}
```
</hook_type>

<hook_type name="prompt">
**Type**: LLM evaluates a prompt

**Use when**:
- Complex decision logic
- Natural language validation
- Context-aware checks
- Reasoning required

**Input**: Prompt with `$ARGUMENTS` placeholder
**Output**: JSON with `decision` and `reason`

```json
{
  "type": "prompt",
  "prompt": "Evaluate if this command is safe: $ARGUMENTS\n\nReturn JSON: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
}
```
</hook_type>

<hook_type name="http">
**Type**: POSTs the event JSON to a URL endpoint

**Use when**:
- External service validation
- Webhook integrations
- Centralized policy enforcement / audit logging

**Input**: JSON body via POST
**Output**: decision via HTTP status code + JSON response body (HTTP 200 = approve, non-200 = block; the body may include `decision`, `reason`, and other standard hook output fields)

```json
{
  "type": "http",
  "url": "https://hooks.example.com/validate",
  "timeout": 5000
}
```
</hook_type>

<hook_type name="agent">
**Type**: Spawns a subagent with tools that returns a hook decision

**Use when**:
- Complex multi-step verification
- Checks requiring file reads or API calls
- Dynamic analysis the other types can't express

```json
{
  "type": "agent",
  "prompt": "Verify that all modified files have corresponding test files. Check the git diff and ensure coverage.",
  "tools": ["Bash", "Read", "Glob"]
}
```
</hook_type>

<common_fields>
All hook types support these additional fields:

| Field | Type | Description |
|-------|------|-------------|
| `timeout` | number | Timeout in ms (default: 60000) |
| `async` | boolean | Run in background without blocking (default: false) |
| `once` | boolean | Run once per session, skills only (default: false) |
| `statusMessage` | string | Custom spinner text shown during execution |
| `if` | string | Permission-rule-syntax filter that gates whether the hook runs |
</common_fields>
</hook_anatomy>

<matchers>
Matchers filter which tools trigger the hook:

```json
{
  "matcher": "Bash",           // Exact match
  "matcher": "Write|Edit",     // Multiple tools (regex OR)
  "matcher": "mcp__.*",        // All MCP tools
  "matcher": "mcp__memory__.*" // Specific MCP server
}
```

**No matcher**: Hook fires for all tools
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [...]  // No matcher - fires on every user prompt
      }
    ]
  }
}
```
</matchers>

<input_output>
Hooks receive JSON via stdin with session info, current directory, and event-specific data. Blocking hooks can return JSON to approve/block actions or modify inputs.

**Example output** (blocking hooks):
```json
{
  "decision": "approve" | "block",
  "reason": "Why this decision was made"
}
```

See [references/input-output-schemas.md](references/input-output-schemas.md) for complete schemas for each hook type.
</input_output>

<environment_variables>
Available in hook commands:

| Variable | Value |
|----------|-------|
| `$CLAUDE_PROJECT_DIR` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin directory (plugin hooks only) |
| `${CLAUDE_PLUGIN_DATA}` | Persistent plugin data directory (plugin hooks only) |
| `$ARGUMENTS` | Hook input JSON (prompt hooks only) |

**Example**:
```json
{
  "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/validate.sh"
}
```
</environment_variables>

<common_patterns>
**Desktop notification when input needed**:
```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude needs input\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

**Block destructive git commands**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if this command is destructive: $ARGUMENTS\n\nBlock if it contains: 'git push --force', 'rm -rf', 'git reset --hard'\n\nReturn: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
          }
        ]
      }
    ]
  }
}
```

**Auto-format code after edits**:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write $CLAUDE_PROJECT_DIR",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
```

**Add context at session start**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"SessionStart\", \"additionalContext\": \"Current sprint: Sprint 23. Focus: User authentication\"}}'"
          }
        ]
      }
    ]
  }
}
```
</common_patterns>

<debugging>
Always test hooks with the debug flag:
```bash
claude --debug
```

This shows which hooks matched, command execution, and output. See [references/troubleshooting.md](references/troubleshooting.md) for common issues and solutions.
</debugging>

<reference_guides>
**Hook types and events**: [references/hook-types.md](references/hook-types.md)
- Complete list of hook events
- When each event fires
- Input/output schemas for each
- Blocking vs non-blocking hooks

**Choosing a handler type**: [references/command-vs-prompt.md](references/command-vs-prompt.md)
- Decision tree: command vs prompt vs http vs agent
- Patterns and examples for each handler type
- Performance considerations

**Matchers and patterns**: [references/matchers.md](references/matchers.md)
- Regex patterns for tool matching
- MCP tool matching patterns
- Multiple tool matching
- Debugging matcher issues

**Input/Output schemas**: [references/input-output-schemas.md](references/input-output-schemas.md)
- Complete schema for each hook type
- Field descriptions and types
- Hook-specific output fields
- Example JSON for each event

**Working examples**: [references/examples.md](references/examples.md)
- Desktop notifications
- Command validation
- Auto-formatting workflows
- Logging and audit trails
- Stop logic patterns
- Session context injection

**Troubleshooting**: [references/troubleshooting.md](references/troubleshooting.md)
- Hooks not triggering
- Command execution failures
- Prompt hook issues
- Permission problems
- Timeout handling
- Debug workflow
</reference_guides>

<security_checklist>
**Critical safety requirements**:

- **Infinite loop prevention**: Check `stop_hook_active` flag in Stop hooks to prevent recursive triggering
- **Timeout configuration**: Set reasonable timeouts (default: 60s) to prevent hanging
- **Permission validation**: Ensure hook scripts have executable permissions (`chmod +x`)
- **Path safety**: Use absolute paths with `$CLAUDE_PROJECT_DIR` to avoid path injection
- **JSON validation**: Validate hook config with `jq` before use to catch syntax errors
- **Selective blocking**: Be conservative with blocking hooks to avoid workflow disruption

**Testing protocol**:
```bash
# Always test with debug flag first
claude --debug

# Validate JSON config
jq . .claude/hooks.json
```
</security_checklist>

<success_criteria>
A working hook configuration has:

- Valid JSON in `.claude/hooks.json` (validated with `jq`)
- Appropriate hook event selected for the use case
- Correct matcher pattern that matches target tools
- Command or prompt that executes without errors
- Proper output schema (decision/reason for blocking hooks)
- Tested with `--debug` flag showing expected behavior
- No infinite loops in Stop hooks (checks `stop_hook_active` flag)
- Reasonable timeout set (especially for external commands)
- Executable permissions on script files if using file paths
</success_criteria>
