# Anthropic Best Practices for CLAUDE.md

## Sources

- [Memory and Instructions](https://code.claude.com/docs/en/memory) -- CLAUDE.md files, .claude/rules/, imports, hierarchy, auto memory
- [Best Practices](https://code.claude.com/docs/en/best-practices) -- General Claude Code best practices
- [The .claude Directory](https://code.claude.com/docs/en/claude-directory) -- .claude directory structure and contents
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide) -- Automate workflows with hooks
- [Hooks Reference](https://code.claude.com/docs/en/hooks) -- Hook types, configuration, examples
- [Plugins](https://code.claude.com/docs/en/plugins) -- Create plugins
- [Plugins Reference](https://code.claude.com/docs/en/plugins-reference) -- Plugin manifest schema, capabilities
- [Settings](https://code.claude.com/docs/en/settings) -- Claude Code settings configuration

Last reviewed: 2026-04-03

## File Size and Scope

- Target under 200 lines per CLAUDE.md file
- Shorter, focused files have better adherence rates
- CLAUDE.md is loaded into context at session start, consuming tokens every time
- If growing large, split using `@imports` or `.claude/rules/` files

## What to Include

- Bash commands Claude can't guess
- Code style rules that differ from defaults
- Testing instructions and preferred test runners
- Repository etiquette (branch naming, PR conventions)
- Architectural decisions specific to your project
- Developer environment quirks (required env vars)
- Common gotchas or non-obvious behaviors

## What NOT to Include

- Anything Claude can figure out by reading code
- Standard language conventions Claude already knows
- Detailed API documentation (link to docs instead)
- Information that changes frequently
- Long explanations or tutorials
- File-by-file descriptions of the codebase
- Self-evident practices like "write clean code"

## Decision Rule

For each line ask: "Would removing this cause Claude to make mistakes?"
If not, cut it.

## Writing for Adherence

### Specificity

- "Use 2-space indentation" not "Format code properly"
- "Run `npm test` before committing" not "Test your changes"
- "API handlers live in `src/api/handlers/`" not "Keep files organized"
- Concrete, verifiable instructions work best

### Structure

- Use markdown headers and bullets to group related instructions
- Claude scans structure the same way readers do
- Organized sections are easier to follow than dense paragraphs

### Emphasis

- Use "IMPORTANT" or "YOU MUST" for critical rules
- If Claude keeps breaking a rule, make the instruction more specific (not longer)
- If Claude asks questions answered in CLAUDE.md, the phrasing is ambiguous

## Anti-Patterns

### Over-specification

The most common failure. If CLAUDE.md is too long, Claude ignores half of it because important rules get lost in noise. Ruthlessly prune.

### Conflicting Instructions

Instructions across multiple CLAUDE.md files may conflict. Claude may pick one arbitrarily. Ensure consistency across the hierarchy.

### Vague Instructions

"Format code nicely" is not verifiable. "Use 2-space indentation" is. Every rule should be testable.

## Hierarchical Structure

### Scope Levels (lowest to highest priority)

1. **Organization-wide (Policy)**: `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS) or `/etc/claude-code/CLAUDE.md` (Linux) -- cannot be excluded
2. **User-level**: `~/.claude/CLAUDE.md` -- personal preferences for all projects
3. **Project root**: `./CLAUDE.md` or `./.claude/CLAUDE.md` -- team-shared via git
4. **Subdirectory**: `component/CLAUDE.md` -- loaded on demand when Claude reads files in that directory
5. **Project local**: `./CLAUDE.local.md` -- personal project-specific (add to .gitignore)
6. **Rules**: `.claude/rules/` -- can be path-scoped, loaded on demand

All discovered files are concatenated into context (not overridden). Later files have higher priority when instructions conflict.

## File Imports (@)

```markdown
See @README.md for project overview.

# Additional Instructions
- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

- Both relative and absolute paths work
- Maximum depth: 5 hops
- Requires user approval on first use
- Imported files expand and load at launch (not lazy-loaded)

## Rules Directory (.claude/rules/)

### Basic Rules (Always Loaded)

```markdown
# Security Rules
Never commit secrets to the repository.
```

### Path-Scoped Rules (Loaded on Demand)

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
All API endpoints must include input validation.
```

- Supports glob patterns and brace expansion
- Only loads when Claude reads matching files
- Reduces context overhead vs always-loaded rules
- Supports symlinks (circular symlinks detected gracefully)

### Symlinks for Sharing

```bash
ln -s ~/shared-claude-rules/security.md .claude/rules/security.md
ln -s ~/shared-claude-rules .claude/rules/shared
```

Symlinks are resolved and loaded normally.

## CLAUDE.md vs Hooks vs Skills

| Mechanism | Nature | Use When |
|-----------|--------|----------|
| CLAUDE.md / rules | Advisory guidance | Claude should follow but might not |
| Hooks | Deterministic actions | Must always happen (lint after edit, etc.) |
| Skills | On-demand domain knowledge | Large context needed only sometimes |

Move large domain knowledge to skills, not CLAUDE.md.
Use hooks for "must-happen" behaviors.

## Debugging

- `/memory` shows which CLAUDE.md files are loaded
- `InstructionsLoaded` hooks log exactly which files load and when
- Context window visualization shows CLAUDE.md's token cost
