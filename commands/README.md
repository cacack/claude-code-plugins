# Commands Directory

This directory contains slash commands - user-invoked commands that start with `/`.

## Structure

Each command is a markdown file with optional frontmatter:

```
commands/
├── ship.md
├── review.md
├── security-review.md
└── create-prompt.md
```

## Command Format

```markdown
---
description: Brief description (max 80 chars)
argument-hint: [optional] --flag value
model: claude-sonnet-4-5-20250929
allowed-tools: Tool1, Tool2
---

# Command Name

Detailed description of what the command does.

## Usage

\`\`\`bash
/command-name [arguments]
\`\`\`

## Arguments

- `arg1` - Description
- `--flag` - Flag description

## Features

- Feature 1
- Feature 2

## Examples

\`\`\`
User: /command-name arg1 --flag value
Claude: [Expected behavior]
\`\`\`

## Requirements

- Requirement 1
- Requirement 2
```

## Frontmatter Fields

### Required
- `description` - Brief command description (shown in `/help`)

### Optional
- `argument-hint` - Hint shown to users about arguments
- `model` - Specific Claude model to use
- `allowed-tools` - Restrict to specific tools
- `temperature` - Model temperature setting
- `max-tokens` - Maximum response tokens

## Using Arguments

### All Arguments
```markdown
Process these arguments: $ARGUMENTS
```

### Positional Parameters
```markdown
First argument: $1
Second argument: $2
All arguments: $@
```

### Special Prefixes

#### Bash Commands
```markdown
!git status
!npm install
```

#### File Contents
```markdown
@README.md
@src/main.ts
```

## Example Commands

### Simple Command

```markdown
---
description: Show project stats
---

# Project Stats

Show statistics about the current project.

!find . -name "*.ts" | wc -l
!git log --oneline | wc -l
```

### Command with Arguments

```markdown
---
description: Create new component
argument-hint: <component-name>
---

# Create Component

Create a new React component: $1

!mkdir -p src/components/$1
!touch src/components/$1/$1.tsx
!touch src/components/$1/$1.test.tsx
```

### Command with File Context

```markdown
---
description: Explain file
argument-hint: <file-path>
---

# Explain File

Read and explain this file:

@$1

Provide a detailed explanation of what this code does.
```

## Best Practices

1. **Clear descriptions** - Keep under 80 characters
2. **Document arguments** - Explain all parameters
3. **Provide examples** - Show typical usage
4. **Handle errors** - Include error scenarios
5. **List requirements** - Document dependencies
6. **Test thoroughly** - Verify on different systems

## Testing Commands

Test locally before submitting:

```bash
# Install marketplace locally
/plugin install /path/to/claude-code-powers

# Test your command
/your-command arg1 arg2

# Check it appears in help
/help
```

## Common Patterns

### Git Workflows
```markdown
!git status
!git add .
!git commit -m "message"
!git push
```

### Code Analysis
```markdown
@$1
Analyze this code for issues.
```

### Multi-step Operations
```markdown
1. !npm test
2. !npm run build
3. !glab mr create
```

## See Also

- [Slash Commands Guide](https://code.claude.com/docs/en/slash-commands)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
- [CONTRIBUTING.md](../CONTRIBUTING.md)
