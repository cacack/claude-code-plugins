# Agents Directory

This directory contains specialized Claude Code agents for delegated tasks.

## What are Agents?

Agents are specialized assistants that handle specific types of tasks autonomously. They're invoked via the Task tool and run in isolated contexts.

## Structure

Each agent is typically a single markdown file:

```
agents/
├── code-reviewer.md
├── security-auditor.md
└── refactoring-agent.md
```

## Creating an Agent

Create a `.md` file with:

```markdown
# Agent Name

Brief description of the agent's purpose.

## Capabilities

- Capability 1
- Capability 2
- Capability 3

## Tools Available

List the tools this agent has access to:
- Read
- Write
- Edit
- Bash
- Grep
- Glob

## Usage Pattern

Describe how users or Claude should invoke this agent:

\`\`\`
Task(
  subagent_type="agent-name",
  prompt="Description of task to delegate"
)
\`\`\`

## Examples

### Example 1: [Scenario]

Input:
\`\`\`
[Example input]
\`\`\`

Output:
\`\`\`
[Expected output/behavior]
\`\`\`

## Limitations

- Limitation 1
- Limitation 2
```

## Common Agent Types

- **Code Reviewers** - Analyze code quality and suggest improvements
- **Security Auditors** - Check for vulnerabilities and security issues
- **Refactoring Agents** - Restructure code for better design
- **Documentation Generators** - Create comprehensive docs
- **Test Writers** - Generate unit/integration tests
- **Debugging Agents** - Investigate and fix bugs

## See Also

- [Agent Documentation](https://code.claude.com/docs/en/agents)
- [CONTRIBUTING.md](../CONTRIBUTING.md)
