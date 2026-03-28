# Hook Types and Events

Complete reference for all Claude Code hook events.

## PreToolUse

**When it fires**: Before any tool is executed

**Can block**: Yes

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm install",
    "description": "Install dependencies"
  }
}
```

**Output schema** (to control execution):
```json
{
  "decision": "approve" | "block",
  "reason": "Explanation",
  "permissionDecision": "allow" | "deny" | "ask",
  "permissionDecisionReason": "Why",
  "updatedInput": {
    "command": "npm install --save-exact"
  }
}
```

**Use cases**:
- Validate commands before execution
- Block dangerous operations
- Modify tool inputs
- Log command attempts
- Ask user for confirmation

**Example**: Block force pushes to main
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if this git command is safe: $ARGUMENTS\n\nBlock if: force push to main/master\n\nReturn: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
          }
        ]
      }
    ]
  }
}
```

---

## PostToolUse

**When it fires**: After a tool completes execution

**Can block**: No (tool already executed)

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.js",
    "content": "..."
  },
  "tool_output": "File created successfully"
}
```

**Output schema**:
```json
{
  "systemMessage": "Optional message to display",
  "suppressOutput": false
}
```

**Use cases**:
- Auto-format code after Write/Edit
- Run tests after code changes
- Update documentation
- Trigger CI builds
- Send notifications

**Example**: Auto-format after edits
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

---

## UserPromptSubmit

**When it fires**: User submits a prompt to Claude

**Can block**: Yes

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate factorial"
}
```

**Output schema**:
```json
{
  "decision": "approve" | "block",
  "reason": "Explanation",
  "systemMessage": "Message to user"
}
```

**Use cases**:
- Validate prompt format
- Block inappropriate requests
- Preprocess user input
- Add context to prompts
- Enforce prompt templates

**Example**: Require issue numbers in prompts
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if prompt mentions an issue number (e.g., #123 or PROJ-456): $ARGUMENTS\n\nIf no issue number: {\"decision\": \"block\", \"reason\": \"Please include issue number\"}\nOtherwise: {\"decision\": \"approve\", \"reason\": \"ok\"}"
          }
        ]
      }
    ]
  }
}
```

---

## Stop

**When it fires**: Claude attempts to stop working

**Can block**: Yes

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "stop_hook_active": false
}
```

**Output schema**:
```json
{
  "decision": "block" | undefined,
  "reason": "Why Claude should continue",
  "continue": true,
  "systemMessage": "Additional instructions"
}
```

**Use cases**:
- Verify all tasks completed
- Check for errors that need fixing
- Ensure tests pass before stopping
- Validate deliverables
- Custom completion criteria

**Example**: Verify tests pass before stopping
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npm test && echo '{\"decision\": \"approve\"}' || echo '{\"decision\": \"block\", \"reason\": \"Tests failing\"}'"
          }
        ]
      }
    ]
  }
}
```

**Important**: Check `stop_hook_active` to avoid infinite loops. If true, don't block again.

---

## SubagentStop

**When it fires**: A subagent attempts to stop

**Can block**: Yes

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false
}
```

**Output schema**: Same as Stop

**Use cases**:
- Verify subagent completed its task
- Check for errors in subagent output
- Validate subagent deliverables
- Ensure quality before accepting results

**Example**: Check if code-reviewer provided feedback
```json
{
  "hooks": {
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Review the subagent transcript: $ARGUMENTS\n\nDid the code-reviewer provide:\n1. Specific issues found\n2. Severity ratings\n3. Remediation steps\n\nIf missing: {\"decision\": \"block\", \"reason\": \"Incomplete review\"}\nOtherwise: {\"decision\": \"approve\", \"reason\": \"Complete\"}"
          }
        ]
      }
    ]
  }
}
```

---

## SessionStart

**When it fires**: At the beginning of a Claude session

**Can block**: No

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "SessionStart",
  "source": "startup"
}
```

**Output schema**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Context to inject into session"
  }
}
```

**Use cases**:
- Load project context
- Inject sprint information
- Set environment variables
- Initialize state
- Display welcome messages

**Example**: Load current sprint context
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat $CLAUDE_PROJECT_DIR/.sprint-context.txt | jq -Rs '{\"hookSpecificOutput\": {\"hookEventName\": \"SessionStart\", \"additionalContext\": .}}'"
          }
        ]
      }
    ]
  }
}
```

---

## SessionEnd

**When it fires**: When a Claude session ends

**Can block**: No (cannot prevent session end)

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "SessionEnd",
  "reason": "exit" | "error" | "timeout"
}
```

**Output schema**: None (hook output ignored)

**Use cases**:
- Save session state
- Cleanup temporary files
- Update logs
- Send analytics
- Archive transcripts

**Example**: Archive session transcript
```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cp $transcript_path $CLAUDE_PROJECT_DIR/.claude/archives/$(date +%Y%m%d-%H%M%S).jsonl"
          }
        ]
      }
    ]
  }
}
```

---

## PreCompact

**When it fires**: Before context window compaction

**Can block**: Yes

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PreCompact",
  "trigger": "manual" | "auto",
  "custom_instructions": "User's compaction instructions"
}
```

**Output schema**:
```json
{
  "decision": "approve" | "block",
  "reason": "Explanation"
}
```

**Use cases**:
- Validate state before compaction
- Save important context
- Custom compaction logic
- Prevent compaction at critical moments

---

## Notification

**When it fires**: Claude needs user input (awaiting response)

**Can block**: No

**Matcher values**: `permission_prompt`, `idle_prompt`, `auth_success`

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "Notification"
}
```

**Output schema**: None

**Use cases**:
- Desktop notifications
- Sound alerts
- Status bar updates
- External notifications (Slack, etc.)

**Example**: macOS notification
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

---

## InstructionsLoaded

**When it fires**: CLAUDE.md or rules files are loaded

**Can block**: Yes

**Matcher values**: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact`

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "InstructionsLoaded"
}
```

**Use cases**:
- Validate instruction files
- Inject additional context based on loaded rules
- Log which instructions were loaded

---

## TaskCreated

**When it fires**: A task is created via TaskCreate

**Can block**: Yes

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "TaskCreated"
}
```

**Use cases**:
- Validate task creation
- Log task assignments
- Inject additional context for new tasks

---

## StopFailure

**When it fires**: API error occurs at the end of a turn

**Can block**: No

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "StopFailure"
}
```

**Use cases**:
- Error logging and monitoring
- Send alerts on API failures
- Track error patterns

---

## ConfigChange

**When it fires**: A configuration file changes

**Can block**: Yes

**Matcher values**: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "ConfigChange"
}
```

**Use cases**:
- Validate configuration changes
- Auto-reload when skills are updated
- Log settings modifications

---

## CwdChanged

**When it fires**: The working directory changes

**Can block**: Yes

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/new/working/directory",
  "permission_mode": "default",
  "hook_event_name": "CwdChanged"
}
```

**Use cases**:
- Load project-specific context on directory change
- Validate directory permissions
- Update environment variables

---

## FileChanged

**When it fires**: A watched file changes on disk

**Can block**: Yes

**Matcher**: Filename basename (e.g., `.env`, `.envrc`, `package.json`)

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "FileChanged"
}
```

**Use cases**:
- React to .env file changes
- Auto-reload when config files update
- Trigger rebuilds on file changes

---

## WorktreeCreate / WorktreeRemove

**When they fire**: Git worktree is created or removed

**Can block**: WorktreeCreate: Yes, WorktreeRemove: No

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "WorktreeCreate"
}
```

**Use cases**:
- Initialize worktree environment
- Clean up worktree resources
- Log worktree lifecycle

---

## PostCompact

**When it fires**: After context window compaction completes

**Can block**: No

**Matcher values**: `manual`, `auto`

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PostCompact",
  "trigger": "manual"
}
```

**Use cases**:
- Re-inject critical context after compaction
- Log compaction events
- Restore state that may have been lost

---

## Elicitation / ElicitationResult

**When they fire**: MCP server requests user input / user responds

**Can block**: No

**Matcher**: MCP server name

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "Elicitation"
}
```

**Use cases**:
- Log MCP user interactions
- Track elicitation patterns
- Notify on MCP input requests
