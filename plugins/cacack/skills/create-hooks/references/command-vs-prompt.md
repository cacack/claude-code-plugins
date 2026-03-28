# Hook Execution Types

Decision guide for choosing between command, http, prompt, and agent hook types.

## Decision Tree

```
Need to execute a hook?
│
├─ Simple yes/no validation?
│  └─ Use COMMAND (faster, cheaper)
│
├─ Need natural language understanding?
│  └─ Use PROMPT (single LLM evaluation)
│
├─ Need multi-step reasoning with tool access?
│  └─ Use AGENT (multi-turn sub-agent)
│
├─ External service notification/audit?
│  └─ Use HTTP (POST event JSON to URL)
│
├─ External tool interaction?
│  └─ Use COMMAND (formatters, linters, git)
│
├─ Complex decision logic?
│  └─ Use PROMPT or AGENT (reasoning required)
│
└─ Logging/notification only?
   └─ Use COMMAND or HTTP (no decision needed)
```

---

## Command Hooks

### Characteristics

- **Execution**: Shell command
- **Input**: JSON via stdin
- **Output**: JSON via stdout (optional)
- **Speed**: Fast (no LLM call)
- **Cost**: Free (no API usage)
- **Complexity**: Limited to shell scripting logic

### When to use

✅ **Use command hooks for**:
- File operations (read, write, check existence)
- Running tools (prettier, eslint, git)
- Simple pattern matching (grep, regex)
- Logging to files
- Desktop notifications
- Fast validation (file size, permissions)

❌ **Don't use command hooks for**:
- Natural language analysis
- Complex decision logic
- Context-aware validation
- Semantic understanding

### Examples

**1. Log bash commands**
```json
{
  "type": "command",
  "command": "jq -r '\"\\(.tool_input.command) - \\(.tool_input.description // \\\"No description\\\")\"' >> ~/.claude/bash-log.txt"
}
```

**2. Block if file doesn't exist**
```bash
#!/bin/bash
# check-file-exists.sh

input=$(cat)
file=$(echo "$input" | jq -r '.tool_input.file_path')

if [ ! -f "$file" ]; then
  echo '{"decision": "block", "reason": "File does not exist"}'
  exit 0
fi

echo '{"decision": "approve", "reason": "File exists"}'
```

**3. Run prettier after edits**
```json
{
  "type": "command",
  "command": "prettier --write \"$(echo {} | jq -r '.tool_input.file_path')\"",
  "timeout": 10000
}
```

**4. Desktop notification**
```json
{
  "type": "command",
  "command": "osascript -e 'display notification \"Claude needs input\" with title \"Claude Code\"'"
}
```

### Parsing input in commands

Command hooks receive JSON via stdin. Use `jq` to parse:

```bash
#!/bin/bash
input=$(cat)  # Read stdin

# Extract fields
tool_name=$(echo "$input" | jq -r '.tool_name')
command=$(echo "$input" | jq -r '.tool_input.command')
session_id=$(echo "$input" | jq -r '.session_id')

# Your logic here
if [[ "$command" == *"rm -rf"* ]]; then
  echo '{"decision": "block", "reason": "Dangerous command"}'
else
  echo '{"decision": "approve", "reason": "Safe"}'
fi
```

---

## Prompt Hooks

### Characteristics

- **Execution**: LLM evaluates prompt
- **Input**: Prompt string with `$ARGUMENTS` placeholder
- **Output**: LLM generates JSON response
- **Speed**: Slower (~1-3s per evaluation)
- **Cost**: Uses API credits
- **Complexity**: Can reason, understand context, analyze semantics

### When to use

✅ **Use prompt hooks for**:
- Natural language validation
- Semantic analysis (intent, safety, appropriateness)
- Complex decision trees
- Context-aware checks
- Reasoning about code quality
- Understanding user intent

❌ **Don't use prompt hooks for**:
- Simple pattern matching (use regex/grep)
- File operations (use command hooks)
- High-frequency events (too slow/expensive)
- Non-decision tasks (logging, notifications)

### Examples

**1. Validate commit messages**
```json
{
  "type": "prompt",
  "prompt": "Evaluate this git commit message: $ARGUMENTS\n\nCheck if it:\n1. Starts with conventional commit type (feat|fix|docs|refactor|test|chore)\n2. Is descriptive and clear\n3. Under 72 characters\n\nReturn: {\"decision\": \"approve\" or \"block\", \"reason\": \"specific feedback\"}"
}
```

**2. Check if Stop is appropriate**
```json
{
  "type": "prompt",
  "prompt": "Review the conversation transcript: $ARGUMENTS\n\nDetermine if Claude should stop:\n1. All user tasks completed?\n2. Any errors that need fixing?\n3. Tests passing?\n4. Documentation updated?\n\nIf incomplete: {\"decision\": \"block\", \"reason\": \"what's missing\"}\nIf complete: {\"decision\": \"approve\", \"reason\": \"all done\"}"
}
```

**3. Validate code changes for security**
```json
{
  "type": "prompt",
  "prompt": "Analyze this code change for security issues: $ARGUMENTS\n\nCheck for:\n- SQL injection vulnerabilities\n- XSS attack vectors\n- Authentication bypasses\n- Sensitive data exposure\n\nIf issues found: {\"decision\": \"block\", \"reason\": \"specific vulnerabilities\"}\nIf safe: {\"decision\": \"approve\", \"reason\": \"no issues found\"}"
}
```

**4. Semantic prompt validation**
```json
{
  "type": "prompt",
  "prompt": "Evaluate user prompt: $ARGUMENTS\n\nIs this:\n1. Related to coding/development?\n2. Appropriate and professional?\n3. Clear and actionable?\n\nIf inappropriate: {\"decision\": \"block\", \"reason\": \"why\"}\nIf good: {\"decision\": \"approve\", \"reason\": \"ok\"}"
}
```

### Writing effective prompts

**Be specific about output format**:
```
Return JSON: {"decision": "approve" or "block", "reason": "explanation"}
```

**Provide clear criteria**:
```
Block if:
1. Command contains 'rm -rf /'
2. Force push to main branch
3. Credentials in plain text

Otherwise approve.
```

**Use $ARGUMENTS placeholder**:
```
Analyze this input: $ARGUMENTS

Check for...
```

The `$ARGUMENTS` placeholder is replaced with the actual hook input JSON.

---

## Performance Comparison

| Aspect | Command Hook | Prompt Hook |
|--------|--------------|-------------|
| **Speed** | <100ms | 1-3s |
| **Cost** | Free | ~$0.001-0.01 per call |
| **Complexity** | Shell scripting | Natural language |
| **Context awareness** | Limited | High |
| **Reasoning** | No | Yes |
| **Best for** | Operations, logging | Validation, analysis |

---

## Combining Both

You can use multiple hooks for the same event:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$input\" >> ~/bash-log.txt",
            "comment": "Log every command (fast)"
          },
          {
            "type": "prompt",
            "prompt": "Analyze this bash command for safety: $ARGUMENTS",
            "comment": "Validate with LLM (slower, smarter)"
          }
        ]
      }
    ]
  }
}
```

Hooks execute in order. If any hook blocks, execution stops.

---

---

## HTTP Hooks

### Characteristics

- **Execution**: POST event JSON to URL
- **Input**: Full event JSON sent as request body
- **Output**: Response JSON (optional)
- **Speed**: Depends on endpoint latency
- **Cost**: Free (no API usage)
- **Complexity**: External service integration

### When to use

Use http hooks for:
- Audit logging to external services
- Webhook integrations (Slack, PagerDuty)
- External validation services
- Centralized event tracking

Don't use http hooks for:
- Local operations (use command)
- Natural language analysis (use prompt)
- Fast-path validation (network latency)

### Example

```json
{
  "type": "http",
  "url": "https://hooks.example.com/claude-events",
  "timeout": 10
}
```

---

## Agent Hooks

### Characteristics

- **Execution**: Multi-turn sub-agent with tool access
- **Input**: Event context provided to agent
- **Output**: Agent returns `ok: true/false`
- **Speed**: Slowest (multiple LLM calls + tool use)
- **Cost**: Highest (multiple API calls)
- **Complexity**: Can reason, read files, run commands

### When to use

Use agent hooks for:
- Complex verification requiring file access
- Multi-step validation (check code, run tests, verify docs)
- Context-aware decisions that need to read project state
- Sophisticated quality gates

Don't use agent hooks for:
- Simple pattern matching (use command)
- Single-question decisions (use prompt)
- High-frequency events (too slow/expensive)
- Non-decision tasks (use command or http)

### Example

```json
{
  "type": "agent",
  "prompt": "Verify that all modified files have corresponding test coverage. Check each changed file and ensure tests exist.",
  "tools": ["Read", "Grep", "Glob", "Bash"],
  "model": "haiku"
}
```

---

## Common Hook Fields

All hook types support these additional fields:

| Field | Type | Description |
|-------|------|-------------|
| `timeout` | number | Seconds before timeout (default: 600) |
| `if` | string | Permission rule syntax to filter execution |
| `async` | boolean | Run in background (default: false) |

### The `if` field

Conditionally execute hooks based on permission rule syntax:
```json
{
  "type": "command",
  "command": "validate.sh",
  "if": "Bash(git *)"
}
```
Only runs when the tool call matches the `if` pattern.

### The `async` field

Run hooks in the background without blocking:
```json
{
  "type": "http",
  "url": "https://audit.example.com/events",
  "async": true
}
```

---

## Recommendations

**High-frequency events** (PreToolUse, PostToolUse):
- Prefer command hooks
- Use prompt/agent hooks sparingly
- Use async http for logging

**Low-frequency events** (Stop, UserPromptSubmit):
- Prompt or agent hooks are fine
- Cost/latency less critical

**External integrations**:
- Use http for webhooks and audit trails
- Use async to avoid blocking

**Balance**:
- Command hooks for simple checks
- HTTP hooks for external logging/webhooks
- Prompt hooks for single-question validation
- Agent hooks for complex multi-step verification
- Combine when appropriate
