# Commit Message Module

Reusable logic for generating conventional commit messages.

## Format

```
type(scope): description

[optional body]

[optional footer]
```

## Types

| Type | Use When |
|------|----------|
| `feat` | Adding new functionality |
| `fix` | Fixing a bug |
| `docs` | Documentation only changes |
| `style` | Formatting, no code change |
| `refactor` | Code change that neither fixes bug nor adds feature |
| `perf` | Performance improvement |
| `test` | Adding/correcting tests |
| `chore` | Maintenance, deps, build |
| `ci` | CI/CD changes |

## Scope Detection

Derive scope from changed files:
- `commands/*` → `commands`
- `agents/*` → `agents`
- `skills/*` → `skills`
- `hooks/*` → `hooks`
- Single file → filename without extension
- Multiple unrelated → omit scope

## Description Guidelines

- Imperative mood ("add" not "added")
- Lowercase first letter
- No period at end
- Max 50 characters

## Body Guidelines

- Wrap at 72 characters
- Explain what and why, not how
- Reference issues: "Fixes #123"

## Claude Code Footer

Always append:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Examples

```
feat(commands): add /do rigor selector command

Provides three workflow options: vibe, delegate, or speckit.
Each maps to a different level of structure for task execution.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
fix(ship): handle missing version file gracefully

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```
