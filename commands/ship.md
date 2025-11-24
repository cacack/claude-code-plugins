---
description: Intelligently commit and ship changes using basic or advanced workflow
argument-hint: [optional commit message]
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

## Important Notes

- NEVER skip pre-commit hooks
- NEVER force push to main/master
- Always verify changes with `git status` and `git diff` before committing
- Ask user for clarification if workflow choice is ambiguous
- Respect conventional commit format unless project overrides exist
