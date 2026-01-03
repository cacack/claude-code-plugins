# Design Guidelines

Principles derived from the [Handyman Principle](./handyman-principle.md) for creating plugin resources.

## Context Economy

Context is scarce. Every token spent on noise is a token not available for useful work.

### Do

- Load only relevant instructions for the current task
- Use progressive disclosure: core info upfront, details on demand
- Reference files instead of inlining content when possible

### Don't

- Create monolithic prompts that try to cover every case
- Repeat information available elsewhere
- Include "just in case" instructions

## Specialization Over Generalization

### Agents

Create **focused agents** with narrow, deep expertise:

```markdown
# GOOD: Focused agent
Security review agent that knows OWASP, checks specific vulnerability patterns

# BAD: Generalist agent
Code review agent that handles security, performance, style, architecture...
```

### Commands

Each command should do **one thing well**:

```markdown
# GOOD: Single purpose
/debug - Apply debugging methodology
/ship - Commit and push with checks

# BAD: Multi-purpose
/code - Debug, refactor, test, document, or deploy
```

## Skills as Programs

Skills are **programs, not prompts**. They should:

1. **Invoke real tools** - validators, linters, scripts
2. **Produce verifiable output** - files, commits, test results
3. **Orchestrate deterministically** - clear workflow, not open-ended exploration

### Scripts Directory

When a skill needs deterministic operations:

```
skill/
├── SKILL.md
├── scripts/
│   └── validate.py     # Real validation logic
└── references/
    └── patterns.md     # Domain knowledge
```

### Verification Criteria

Every workflow should define **how to verify success**:

```markdown
## Verification
- [ ] Tests pass
- [ ] No new linting errors
- [ ] Documentation updated
```

## External Memory

Don't trust context persistence. Externalize state.

### Handoffs

When work spans sessions, create handoff files:

```markdown
# CONTINUE-HERE.md
## Current State
- Phase 2 complete, phase 3 pending

## Next Steps
1. Implement authentication middleware
2. Add tests for edge cases

## Context
- Using JWT, not sessions (decision in docs/auth.md)
```

### Progress Tracking

Use files for progress, not memory:

- `TODO.md` - outstanding work
- `prompts/*.md` - pending prompts to execute
- `handoffs/*.md` - session continuations

### Checkpoint Patterns

After significant milestones:

```bash
git add . && git commit -m "checkpoint: phase N complete"
```

## Anti-Patterns

### Context Pollution

Loading irrelevant knowledge "just in case":

```markdown
# BAD: Skill loads everything
<references>
security-patterns.md
performance-tips.md
testing-strategies.md
api-design.md
database-patterns.md
</references>

# GOOD: Skill loads what's needed
<references>
{{if security_task}}security-patterns.md{{/if}}
</references>
```

### Memory Assumptions

Assuming the AI remembers prior context:

```markdown
# BAD: Relies on memory
"Continue with the approach we discussed"

# GOOD: Externalized state
"See CONTINUE-HERE.md for current state and decisions"
```

### Prompt Sprawl

Instructions that grow unbounded:

```markdown
# BAD: Sprawling prompt
...and also check for X, and don't forget Y, and make sure Z...

# GOOD: Structured, scannable
## Required
- X

## Optional
- Y (when applicable)
```

## Checklist

When creating resources, verify:

- [ ] Does this do one thing well?
- [ ] Is the context minimal but complete?
- [ ] Are there real tools/scripts where appropriate?
- [ ] Is state externalized to files?
- [ ] Are verification criteria defined?
- [ ] Would a fresh session understand this without prior context?
