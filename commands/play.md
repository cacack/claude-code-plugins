---
description: Review a GitHub/GitLab issue, plan the work, and present for approval before implementation
argument-hint: <issue-number>
allowed-tools: [Read, Grep, Glob, Bash(gh issue:*), Bash(gh pr:*), Bash(glab issue:*), Bash(git status:*), Bash(git branch:*), Bash(git log:*), WebFetch, Task, AskUserQuestion, TodoWrite, EnterPlanMode]
---

<objective>
Review issue #$ARGUMENTS, understand requirements, explore the codebase, create an implementation plan, and present it for your approval before starting work.

This ensures alignment on approach before investing effort in implementation.
</objective>

<context>
Repository info: ! `git remote -v | head -1`
Current branch: ! `git branch --show-current`
Recent commits: ! `git log --oneline -5`
</context>

<process>
1. **Fetch the issue**:
   - Try GitHub first: `gh issue view $ARGUMENTS`
   - If that fails, try GitLab: `glab issue view $ARGUMENTS`
   - If URL is provided instead of number, fetch directly

2. **Understand the issue**:
   - Parse title, description, labels, and comments
   - Identify acceptance criteria (explicit or implied)
   - Note any constraints, dependencies, or related issues

3. **Explore the codebase**:
   - Identify relevant files and areas affected
   - Understand existing patterns and conventions
   - Check for related code, tests, and documentation

4. **Create implementation plan**:
   - Break down into discrete, ordered steps
   - Identify files to create/modify
   - Consider edge cases and error handling
   - Note any testing requirements

5. **Present the plan**:
   - Summarize the issue understanding
   - Present step-by-step implementation plan
   - Highlight any decisions or trade-offs
   - Ask for approval, adjustments, or clarification
</process>

<output_format>

## Issue Summary

**Issue #$ARGUMENTS**: [Title]
**Labels**: [labels if any]
**Key Requirements**:
- [Requirement 1]
- [Requirement 2]

## Affected Areas

- `path/to/file.ext` - [what changes]
- `path/to/other.ext` - [what changes]

## Implementation Plan

1. **Step one** - [description]
   - Files: `file1.ext`, `file2.ext`
   - Details: [specifics]

2. **Step two** - [description]
   - Files: `file3.ext`
   - Details: [specifics]

[...additional steps...]

## Testing Plan

- [ ] [Test requirement 1]
- [ ] [Test requirement 2]

## Questions/Decisions

- [Any clarifications needed]
- [Trade-offs to consider]

---

**Ready to proceed?** Let me know if you'd like to:
- ✅ Proceed with this plan
- ✏️ Modify the approach
- ❓ Discuss specific aspects

</output_format>

<success_criteria>
- Issue successfully fetched from GitHub or GitLab
- Requirements clearly understood and summarized
- Relevant codebase areas identified
- Implementation plan is concrete and actionable
- Plan presented for user approval before any implementation
- User given clear options to proceed, modify, or discuss
</success_criteria>

<examples>

**Usage: GitHub issue number**
```bash
/play 42
```
Fetches issue #42 from the current repo and plans the work.

**Usage: Full URL**
```bash
/play https://github.com/owner/repo/issues/123
```
Fetches the issue from the specified URL.

</examples>
