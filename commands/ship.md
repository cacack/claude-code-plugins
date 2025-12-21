---
description: Intelligently commit and ship changes with optional version bumping
argument-hint: [commit message] [--no-bump] [--no-docs-check]
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push:*)
  - Bash(git checkout:*)
  - Bash(git branch:*)
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git remote:*)
  - Bash(git tag:*)
  - Bash(git log:*)
  - Bash(gh pr:*)
  - Bash(glab mr:*)
---

<objective>
Analyze current repository state and intelligently commit and ship changes using basic or advanced workflow.
Handles version bumping, documentation checks, and PR/MR creation as appropriate.
</objective>

<context>
Git status: ! `git status`
Current branch: ! `git branch --show-current`
Remote info: ! `git remote -v | head -1`
Changes summary: ! `git diff --stat HEAD`
Staged changes: ! `git diff --cached --stat`
Recent commits: ! `git log --oneline -5`
Project conventions: @CLAUDE.md
</context>

<process>

## 1. Parse Arguments

From `$ARGUMENTS`, extract:
- **Commit message**: Free text (if provided)
- **Flags**:
  - `--no-bump` - Skip version bumping
  - `--no-docs-check` - Skip documentation check

## 2. Analyze Repository State

Using context above, determine:
- Current branch (main/master vs feature branch)
- Platform (GitHub vs GitLab from remote URL)
- Change complexity (file count, diff size)
- Repository ownership (personal vs organizational)

## 3. Select Workflow

**Basic workflow** when:
- Already on feature branch (not main/master)
- Personal repository
- Simple changes (1-2 files)

**Advanced workflow** when:
- On main/master branch
- Organizational/collaborative repo
- Complex changes (3+ files)
- User explicitly wants PR/MR

Inform user which workflow will be used and why.

## 4. Version Bump (if applicable)

Skip if `--no-bump` flag or conditions below.

### Detection Priority
1. `.claude-plugin/plugin.json` - Claude Code plugins
2. `package.json` - Node.js
3. `pyproject.toml` - Python
4. `Cargo.toml` - Rust
5. `VERSION` or `VERSION.txt` - Plain text

### Bump Rules
| Commit Type | Bump |
|-------------|------|
| `feat:` | minor (1.2.3 → 1.3.0) |
| `fix:`, `perf:` | patch (1.2.3 → 1.2.4) |
| `BREAKING CHANGE` | major (1.2.3 → 2.0.0) |
| `docs:`, `style:`, `refactor:`, `test:`, `chore:`, `ci:` | patch |

### Skip When
- No version file detected
- Only documentation changes
- Already on version bump commit

## 5. Documentation Check (if applicable)

Skip if `--no-docs-check` flag or commit type is `docs:`, `test:`, `ci:`, `style:`.

Check for: `README.md`, `FEATURES.md`, `CHANGELOG.md`, `IDEAS.md`

For `feat:` commits:
```
Documentation check for new feature:
- [ ] README.md - Update if major user-facing change
- [ ] FEATURES.md - Document new capability

Update docs? (y/n/skip): _
```

## 6. Execute Workflow

### Basic Workflow
```bash
git add .
git commit -m "[conventional commit message]"
git push
```

### Advanced Workflow
```bash
git checkout -b feature/descriptive-name  # if on main
git add .
git commit -m "[conventional commit message]"
git push -u origin [branch-name]
gh pr create --title "..." --body "..."  # or glab mr create
```

## 7. Commit Message

If user provided message, use it. Otherwise generate:
- Format: `type(scope): description`
- Scope from changed files/directories
- Include Claude Code footer:
  ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

</process>

<success_criteria>
**Basic workflow complete when:**
- All changes staged
- Commit created with conventional message
- Changes pushed to remote
- No pre-commit hook failures

**Advanced workflow complete when:**
- Feature branch created (if needed)
- All changes staged and committed
- Branch pushed with upstream tracking
- PR/MR created with clear title and description
- PR/MR URL returned to user

**Version bump complete when:**
- Version file updated
- Separate bump commit created
- Tag created (if project requires)

**All workflows:**
- User informed of actions taken
- No force pushes to main/master
- Pre-commit hooks respected
</success_criteria>

<safety>
- NEVER skip pre-commit hooks
- NEVER force push to main/master
- NEVER commit secrets (.env, credentials, keys)
- Always verify changes with `git status` before committing
- Ask user for clarification if workflow choice is ambiguous
</safety>

<examples>

```bash
# Auto-generate commit message, full workflow
/ship

# Use provided commit message
/ship "feat: add user authentication"

# Skip version bump
/ship --no-bump

# Skip docs check
/ship "fix: resolve null pointer" --no-docs-check

# Skip both
/ship --no-bump --no-docs-check
```

</examples>
