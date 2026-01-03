# Hooks Directory

This directory contains Claude Code hooks - event-driven automation triggered by lifecycle events.

## What are Hooks?

Hooks are shell commands that execute automatically in response to specific events during Claude Code operation.

## Structure

Hooks are defined in `hooks.json`:

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "command": "validate-changes",
      "description": "Validate code before tool execution"
    },
    {
      "event": "PostToolUse",
      "command": "notify-team",
      "description": "Send notification after tool completes"
    }
  ]
}
```

## Available Events

- **PreToolUse** - Before any tool is used
- **PostToolUse** - After any tool completes
- **PermissionRequest** - When permission is needed for an action
- **UserPromptSubmit** - When user submits a prompt
- **SessionStart** - At the beginning of a session
- **SessionEnd** - At the end of a session

## Hook Commands

Hook commands can be:
- Shell scripts in your PATH
- Relative paths to scripts: `./scripts/my-hook.sh`
- Inline shell commands: `echo "Hook triggered"`

## Creating a Hook

1. Define your hook in `hooks.json`:

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "command": "./scripts/lint-code.sh",
      "description": "Run linter before tool execution"
    }
  ]
}
```

2. Create the hook script if needed:

```bash
#!/bin/bash
# scripts/lint-code.sh

echo "Running linter..."
npm run lint

if [ $? -ne 0 ]; then
  echo "Linting failed! Please fix errors before continuing."
  exit 1
fi
```

3. Make it executable:

```bash
chmod +x scripts/lint-code.sh
```

## Common Use Cases

### Code Quality Enforcement

```json
{
  "event": "PreToolUse",
  "command": "npm run lint && npm run type-check",
  "description": "Enforce code quality before operations"
}
```

### Automatic Testing

```json
{
  "event": "PostToolUse",
  "command": "./scripts/run-tests.sh",
  "description": "Run tests after code changes"
}
```

### Notifications

```json
{
  "event": "SessionEnd",
  "command": "notify-send 'Claude Code' 'Session completed'",
  "description": "Desktop notification on session end"
}
```

### Logging

```json
{
  "event": "UserPromptSubmit",
  "command": "echo \"$(date): $USER_PROMPT\" >> ~/claude-log.txt",
  "description": "Log all user prompts"
}
```

### Security Validation

```json
{
  "event": "PreToolUse",
  "command": "./scripts/check-secrets.sh",
  "description": "Prevent committing secrets"
}
```

## Environment Variables

Hooks have access to environment variables including:
- `$TOOL_NAME` - Name of the tool being used
- `$USER_PROMPT` - The user's prompt (for UserPromptSubmit)
- Standard environment variables (PATH, HOME, etc.)

## Security Considerations

**IMPORTANT**: Hooks execute with your system credentials and permissions.

- Always audit hook commands before enabling
- Use absolute paths for critical scripts
- Validate inputs in hook scripts
- Be cautious with hooks from untrusted sources
- Test hooks in isolated environments first

## Debugging Hooks

Enable hook debugging:

```bash
export CLAUDE_DEBUG_HOOKS=1
```

Test individual hooks:

```bash
./scripts/my-hook.sh
echo $?  # Check exit code
```

## Best Practices

1. **Keep hooks fast** - They run synchronously and can block operations
2. **Provide clear error messages** - Help users understand failures
3. **Document dependencies** - List required tools/packages
4. **Test thoroughly** - Hooks affect all operations
5. **Use exit codes** - 0 for success, non-zero for failure
6. **Be careful with PreToolUse** - Can block legitimate operations

## See Also

- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [CONTRIBUTING.md](../CONTRIBUTING.md)
