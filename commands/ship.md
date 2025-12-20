---
description: Intelligently commit and ship changes using basic or advanced workflow
argument-hint: [optional commit message]
allowed-tools:
  - Read
  - Bash(git *)
  - Bash(gh *)
  - Bash(glab *)
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

Analyze the current repository state and changes, then intelligently choose between:

**Basic workflow** (for personal repos or simple changes):
1. Stage all changes
2. Create commit with conventional commit message
3. Push to current branch

**Advanced workflow** (for collaborative repos or complex changes):
1. Create a feature branch (if not already on one)
2. Stage all changes
3. Create commit with conventional commit message
4. Push branch with upstream tracking
5. Create PR (GitHub) or MR (GitLab)

## Decision Criteria

Use **basic workflow** when:
- Current branch is NOT main/master (already on feature branch)
- Repository appears to be personal (user owns the repo)
- Changes are simple (1-2 files, small diff)

Use **advanced workflow** when:
- Currently on main/master branch
- Repository is organizational/collaborative
- Changes are complex (3+ files or significant modifications)
- User explicitly wants a PR/MR

## Workflow Steps

1. **Analyze repository context:**
   - Run `git remote -v` to identify hosting platform (GitHub/GitLab)
   - Run `git status` to see current branch and changes
   - Run `git diff --stat` to assess change complexity
   - Check if current user owns the repository
   - Check CLAUDE.md for project-specific requirements (versioning, tagging, etc.)

2. **Determine workflow:**
   - Apply decision criteria above
   - Inform user which workflow will be used and why

3. **Execute chosen workflow:**

   **Basic workflow:**
   - Stage changes: `git add .`
   - Create commit with message following conventional commits
   - Push: `git push`

   **Advanced workflow:**
   - Create branch if needed: `git checkout -b feature/descriptive-name`
   - Stage changes: `git add .`
   - Create commit with message following conventional commits
   - Push with tracking: `git push -u origin branch-name`
   - Create PR/MR:
     - GitHub: `gh pr create --title "..." --body "..."`
     - GitLab: `glab mr create --title "..." --description "..."`

4. **Commit message guidelines:**
   - If user provided argument, use it as commit message
   - Otherwise, analyze changes and create conventional commit message
   - Format: `type(scope): description`
   - Include co-authored-by footer for Claude Code
   - Add link to Claude Code in commit body

5. **Error handling:**
   - Check for uncommitted changes
   - Verify git repository exists
   - Handle authentication issues
   - Check if `gh` or `glab` CLI is available for PR/MR creation

## Version Bump (Generic)

Before committing, check if the project uses semantic versioning and bump if needed.

### Version File Detection

Search for version files in priority order:
1. `.claude-plugin/plugin.json` - Claude Code plugins
2. `package.json` - Node.js/npm projects
3. `pyproject.toml` - Python projects (PEP 621 or Poetry)
4. `Cargo.toml` - Rust projects
5. `VERSION` or `VERSION.txt` - Plain text version
6. `setup.py` - Legacy Python (extract from `version=`)

Use the first one found. If no version file exists, skip version bumping.

### Bump Rules (Semver)

Determine bump type from the commit type being created:

| Commit Type | Bump | Example |
|-------------|------|---------|
| `feat:` | minor | 1.2.3 → 1.3.0 |
| `fix:`, `perf:` | patch | 1.2.3 → 1.2.4 |
| `BREAKING CHANGE` | major | 1.2.3 → 2.0.0 |
| `docs:`, `style:`, `refactor:`, `test:`, `chore:`, `ci:` | patch | 1.2.3 → 1.2.4 |

### Bump Workflow

1. **Detect version file** using priority list above
2. **Read current version** from the file
3. **Determine commit type** from changes or user-provided message
4. **Calculate new version** using semver rules
5. **Update version file** with new version
6. **Commit changes** in this order:
   - First: The actual code changes with conventional commit message
   - Second: Version bump as `chore: bump version to X.Y.Z`
7. **Create git tag** (if project conventions require it): `git tag -a vX.Y.Z -m "Release vX.Y.Z"`

### Version File Formats

**JSON files** (package.json, plugin.json):
```json
{ "version": "1.2.3" }
```

**TOML files** (pyproject.toml, Cargo.toml):
```toml
[project]  # or [package] for Cargo
version = "1.2.3"
```

**Plain text** (VERSION):
```
1.2.3
```

### Skip Conditions

Skip version bumping when:
- No version file detected
- Changes are only to ignored files (README, docs, etc.)
- User explicitly passes `--no-bump` argument
- Already on a version bump commit

## Important Notes

- NEVER skip pre-commit hooks
- NEVER force push to main/master
- Always verify changes with `git status` and `git diff` before committing
- Ask user for clarification if workflow choice is ambiguous
- Respect conventional commit format unless project overrides exist
- Check CLAUDE.md for project-specific version/tag requirements
