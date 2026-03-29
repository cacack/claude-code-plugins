---
name: ship
description: Intelligently commit and ship changes with preflight checks, issue compliance, and documentation review
argument-hint: [commit message] [--quick] [--no-bump]
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - Task
  - AskUserQuestion
  - TodoWrite
  - Bash(make:*)
  - Bash(git add:*)
  - Bash(git commit:*)
  - Bash(git push -u:*)
  - Bash(git push origin:*)
  - Bash(git checkout:*)
  - Bash(git branch:*)
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git remote:*)
  - Bash(git tag:*)
  - Bash(git log:*)
  - Bash(gh pr:*)
  - Bash(gh issue:*)
  - Bash(glab mr:*)
  - Bash(glab issue:*)
---

<objective>
Ship code changes with appropriate rigor. By default, runs preflight checks, verifies issue compliance, and reviews documentation needs. Use `--quick` for simple direct shipping when rigor isn't needed.
</objective>

<context>
Git status: ! `git status --short`
Current branch: ! `git branch --show-current`
Remote: ! `git remote get-url origin 2>/dev/null | head -1`
Changes: ! `git diff --stat HEAD 2>/dev/null | tail -5`
Recent commits: ! `git log --oneline -3 2>/dev/null`
Make targets: ! `make -qp 2>/dev/null | awk -F: '/^[a-z][a-z0-9_-]*:/ && !/^\./ {print $1}' | grep -E '^(lint|test|check|security|audit)' | tr '\n' ' ' || echo "none"`
</context>

<routing>
Parse `$ARGUMENTS` for flags and commit message:

**Flags:**
- `--quick` - Skip all checks, direct commit/push (10-20% of cases)
- `--no-bump` - Skip version bumping

**Commit message:** Free text, optionally in quotes

<decision>
```
IF --quick flag present:
  → Execute QUICK WORKFLOW (direct, minimal)
ELSE:
  → Execute RIGOROUS WORKFLOW (default, full checks)
```
</decision>
</routing>

<quick_workflow>
Fast path for trivial changes. No preflight, no compliance, no docs review.

**When to use:**
- Typo fixes
- Comment updates
- Trivial config changes
- When you're confident and in a hurry

**Process:**

1. Stage all changes:
   ```bash
   git add .
   ```

2. Generate or use provided commit message:
   - Format: `type(scope): description`
   - Include footer:
     ```
     🤖 Generated with [Claude Code](https://claude.com/claude-code)

     Co-Authored-By: Claude <noreply@anthropic.com>
     ```

3. Commit and push:
   ```bash
   git commit -m "..."
   git push
   ```

4. Report completion:
   ```
   ✓ Shipped (quick mode)
     Commit: abc1234
     Branch: main
   ```
</quick_workflow>

<rigorous_workflow>
Default path with full discipline. Runs preflight, checks compliance, reviews docs.

**Phases:**

<phase name="0_version_requirements">
**CRITICAL: Check project versioning requirements before proceeding.**

1. Read the project's `CLAUDE.md` file (if it exists)
2. Look for versioning/release sections that specify:
   - Version file locations
   - Version bump rules
   - Tagging requirements
   - Any files that must be kept in sync (e.g., plugin.json + marketplace.json)

3. If versioning requirements found:
   - Note the version file(s) and current version
   - Determine appropriate bump based on commit type
   - Ensure `--no-bump` wasn't accidentally used when bump is required

**Gate:** If CLAUDE.md specifies mandatory versioning but `--no-bump` flag was used with a `feat:` or `fix:` commit, warn user and confirm intent.

**Skip if:** No CLAUDE.md or no versioning requirements specified.
</phase>

<phase name="1_preflight">
Run project-defined code quality checks.

```bash
# Detect and run available targets
make lint 2>&1 || true
make test 2>&1 || true
make security 2>&1 || true
```

**Gate:** If any check fails, stop and report. User must fix or explicitly bypass.

**Report format:**
```
Preflight
─────────
✓ make lint     : passed
✓ make test     : 47/47 passed
- make security : not configured
```
</phase>

<phase name="2_issue_compliance">
If issue reference detected, verify changes satisfy requirements.

**Detection:**
```bash
# From branch
git branch --show-current | grep -oE '([0-9]+|[A-Z]+-[0-9]+)'

# From commits
git log --oneline $(git merge-base HEAD main 2>/dev/null || echo HEAD~10)..HEAD | grep -oE '#[0-9]+'
```

**If issue found:**
1. Fetch issue: `gh issue view <N> --json title,body,labels`
2. Extract requirements from issue body
3. Compare staged diff against requirements
4. Score: COMPLETE, PARTIAL, MISSING for each

**Gate:** If PARTIAL or MISSING, present options:
```
Issue #42 compliance: 2/4 complete, 1/4 partial, 1/4 missing

Options:
1. Proceed anyway (PR references but doesn't close issue)
2. Review and address missing items
3. Mark as intentional partial implementation
```

**Skip if:** No issue detected (proceed to next phase)
</phase>

<phase name="3_documentation">
Analyze if documentation needs updates.

**Skip if:** Commit type is `docs:`, `test:`, `ci:`, `style:`

**Check:**
```bash
ls README.md FEATURES.md CHANGELOG.md IDEAS.md 2>/dev/null
```

**For feat: commits, analyze:**
- New exports → API docs needed?
- New features → README/FEATURES update?
- Implementing from IDEAS → Remove from backlog?

**Report specific suggestions:**
```
Documentation
─────────────
README.md (line 45): Add OAuth section
  Suggested: "## OAuth Login\n..."

FEATURES.md: Add entry
  Suggested: "- OAuth Login: ..."

Update now? (y/n/proceed): _
```
</phase>

<phase name="4_version_bump">
Handle version bumping if applicable.

**Skip if:** `--no-bump` flag or no version file detected

**Detection priority:**
1. `.claude-plugin/plugin.json` + `marketplace.json`
2. `package.json`
3. `pyproject.toml`
4. `Cargo.toml`

**Bump rules:**
| Type | Bump |
|------|------|
| `feat:` | minor |
| `fix:`, `perf:` | patch |
| `BREAKING CHANGE` | major |
| other | patch |
</phase>

<phase name="5_ship">
Execute the actual shipping.

**For feature branches:**
```bash
git add .
git commit -m "[message]"
git push -u origin [branch]
gh pr create --title "..." --body "..."
```

**For main branch:**
```bash
git add .
git commit -m "[message]"
git push
```

**Issue linking in PR:**
- 100% compliance → `Closes #N`
- Partial compliance → `Related to #N`
- User override → As specified

**Commit message format:**
```
type(scope): description

[Optional body with details]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```
</phase>
</rigorous_workflow>

<output_format>
<template name="shipping_report">
```
Shipping Report
═══════════════

Branch: [branch-name]
Commit: [type(scope): message]

Preflight
─────────
[✓/✗/-] lint     : [status]
[✓/✗/-] test     : [status]
[✓/✗/-] security : [status]

[If issue linked:]
Issue Compliance (#N)
─────────────────────
Coverage: N/N complete
Recommendation: [Closes/References]

[If docs needed:]
Documentation
─────────────
[Suggestions made and user response]

Result
──────
✓ Shipped successfully
  Commit: [hash]
  [PR: URL if created]
```
</template>
</output_format>

<safety>
- NEVER skip pre-commit hooks — hooks enforce project invariants (formatting, lint, tests) that prevent broken commits
- NEVER force push to main/master — overwrites shared history and can destroy teammates' work
- NEVER commit secrets (.env, credentials, API keys) — leaked secrets require rotation and can lead to breaches
- ALWAYS verify with `git status` before committing — catches unintended staged files and confirms expected changes
- ALWAYS respect hook failures — a failing hook means the commit violates a project rule; fix the issue rather than bypassing
</safety>

<examples>
```bash
# Full rigorous workflow (default)
/ship

# With commit message
/ship "feat: add OAuth login"

# Quick mode - skip all checks
/ship --quick "fix: typo in README"

# Skip version bump only
/ship --no-bump "refactor: reorganize utils"

# Quick with message
/ship --quick "chore: update dependencies"
```
</examples>

<success_criteria>
**Quick workflow:**
- Changes committed and pushed
- No pre-commit failures

**Rigorous workflow:**
- All preflight checks pass (or explicitly bypassed)
- Issue compliance verified (if issue linked)
- Documentation reviewed (updates made or deferred)
- Version bumped (if applicable)
- Commit created with conventional format
- PR/MR created (if feature branch)
- Clear report of all actions taken
</success_criteria>
