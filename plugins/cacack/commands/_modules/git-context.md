# Git Context Module

Reusable logic for gathering git repository context.

## Standard Context Gathering

Run these commands to understand repository state:

```bash
# Repository info
git remote -v | head -1

# Current branch
git branch --show-current

# Working tree status
git status --short

# Staged changes
git diff --cached --stat

# Unstaged changes
git diff --stat

# Recent commits (for style reference)
git log --oneline -5
```

## Platform Detection

Determine hosting platform from remote URL:

```bash
git remote get-url origin
```

- Contains `github.com` → GitHub (use `gh` CLI)
- Contains `gitlab.com` or self-hosted GitLab → GitLab (use `glab` CLI)
- Contains `bitbucket.org` → Bitbucket

## Branch Context

```bash
# Check if on main/master
git branch --show-current | grep -E '^(main|master)$'

# Check if branch tracks remote
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null

# Commits ahead/behind
git rev-list --left-right --count @{u}...HEAD 2>/dev/null
```

## Change Analysis

```bash
# Files changed (staged + unstaged)
git diff --name-only HEAD

# Detailed diff for commit message generation
git diff --cached
```
