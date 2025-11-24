# Skills Directory

This directory contains Claude Code skills - capabilities that Claude can autonomously invoke based on the context of your request.

## What are Skills?

Skills are different from slash commands:
- **Slash commands**: User explicitly invokes them (e.g., `/ship`)
- **Skills**: Claude decides when to use them based on your needs

## Structure

Each skill should be in its own directory:

```
skills/
└── my-skill/
    ├── SKILL.md          # Main skill description
    ├── examples.md       # Usage examples (optional)
    └── resources/        # Supporting files (optional)
```

## Creating a Skill

1. Create a new directory with your skill name
2. Add a `SKILL.md` file describing:
   - What the skill does
   - When Claude should use it
   - Tools and context available
   - Examples

Example `SKILL.md`:

```markdown
# Code Optimization Skill

This skill helps optimize code for performance and efficiency.

## When to Use

Claude should use this skill when:
- User mentions performance issues
- Code has obvious inefficiencies
- Optimization is requested

## Context

Available tools:
- Read/Write files
- Bash for benchmarking
- Grep for pattern analysis

## Examples

[Provide 2-3 examples of the skill in action]
```

## See Also

- [Skills Guide](https://code.claude.com/docs/en/skills)
- [CONTRIBUTING.md](../CONTRIBUTING.md)
