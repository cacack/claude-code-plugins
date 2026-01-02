---
description: Review a GitHub/GitLab issue, plan the work, and present for approval before implementation
argument-hint: <issue-number|issue-url>
allowed-tools:
  - Read
  - Write  # For prompt generation only - no implementation before approval
  - Grep
  - Glob
  - Bash(gh issue:*)
  - Bash(glab issue:*)
  - Bash(git status:*)
  - Bash(git branch:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - WebFetch
  - Task
  - AskUserQuestion
  - TodoWrite
---

<objective>
Review issue #$ARGUMENTS, understand requirements, explore the codebase, create an implementation plan, and present it for your approval before starting work.

This ensures alignment on approach before investing effort in implementation.
</objective>

<context>
Repository info: ! `git remote -v | head -1`
Current branch: ! `git branch --show-current`
Working directory: ! `git status --short`
Recent commits: ! `git log --oneline -5`
GitHub CLI: ! `which gh >/dev/null 2>&1 && echo "available" || echo "NOT INSTALLED"`
GitLab CLI: ! `which glab >/dev/null 2>&1 && echo "available" || echo "NOT INSTALLED"`
</context>

<process>
1. **Validate and fetch the issue**:
   - If `$ARGUMENTS` is empty, ask user for issue number or URL
   - If GitHub CLI not available (check context), inform user and suggest installing with `brew install gh`
   - Parse input: number (`42`), hash-number (`#42`), or full URL
   - Try GitHub first: `gh issue view $ARGUMENTS`
   - If that fails, try GitLab: `glab issue view $ARGUMENTS`
   - If URL is provided instead of number, fetch directly
   - On fetch failure (invalid number, auth error, network): present error and ask for valid input

2. **Understand the issue**:
   - Parse title, description, labels, and comments
   - Identify acceptance criteria (explicit or implied)
   - Note any constraints, dependencies, or related issues

3. **Explore the codebase**:
   - Identify relevant files and areas affected
   - Understand existing patterns and conventions
   - Check for related code, tests, and documentation

4. **Create implementation plan**:
   - **Build vs Reuse check**: Before designing implementation, ask "What existing stdlib or library functionality can be leveraged? What is truly domain-specific and must be built?" Document findings in the Build vs Reuse output section.
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

## Build vs Reuse

**Leveraging existing functionality:**
- [stdlib/library feature] - [what it handles]

**Must be built (domain-specific):**
- [custom component] - [why it can't be reused]

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

## Documentation Impact

Check which documentation may need updates:
- [ ] README.md - [update if major user-facing feature]
- [ ] FEATURES.md - [document new capability if file exists]
- [ ] IDEAS.md - [remove item if implementing from ideas backlog]
- [ ] CHANGELOG.md - [add entry if file exists]

---

**Ready to proceed?** Let me know if you'd like to:
- ✅ Proceed manually - I'll implement step by step in this session
- 🚀 Generate prompts - Create execution prompts for delegation via /cacack:run-prompt
- ✏️ Modify the approach
- ❓ Discuss specific aspects

</output_format>

<success_criteria>
- Issue successfully fetched from GitHub or GitLab
- Requirements clearly understood and summarized
- Relevant codebase areas identified
- Implementation plan is concrete and actionable
- Plan presented for user approval before any implementation
- User given clear options to proceed, modify, discuss, or generate prompts
- If prompt generation selected: prompts saved with all required XML tags (objective, context, requirements, implementation, output, verification, success_criteria) and execution options presented
</success_criteria>

<prompt_generation>
When user selects "🚀 Generate prompts", create execution-ready prompts from the implementation plan.

**Pre-generation steps:**
1. Use Glob on `.prompts/*.md` to find existing prompts and determine next sequence number (create `.prompts/` if missing, start with 001)
2. Analyze implementation plan steps for dependencies
3. Determine execution strategy:
   - **Parallel**: Independent steps, no shared file modifications
   - **Sequential**: Steps with dependencies (one must complete before next)

**Prompt structure** - Use XML tags for clarity:

```xml
<objective>
[Clear statement from the implementation step]
[Why this matters in context of issue #$ARGUMENTS]
</objective>

<context>
Issue: #$ARGUMENTS - [title]
[Relevant background from issue analysis]
@[files identified during exploration]
</context>

<requirements>
[Specific requirements from the implementation plan]
[Acceptance criteria mapped from the issue]
</requirements>

<implementation>
[Approach identified during planning]
[Patterns to follow from codebase exploration]
[What to avoid based on existing code]
</implementation>

<output>
Files to create/modify:
- `./path/to/file.ext` - [what changes]
</output>

<verification>
Before completing:
- [Specific check from testing plan]
- [How to confirm success]
</verification>

<success_criteria>
[Measurable criteria mapped from issue requirements]
</success_criteria>
```

**File naming**: `.prompts/[NNN]-[issue-number]-[step-name].md`
- Example: `.prompts/001-42-setup-database.md`, `.prompts/002-42-create-api.md`

**After saving prompts, present:**

```
✓ Generated prompts from issue #$ARGUMENTS implementation plan:
  - .prompts/NNN-$ARGUMENTS-[step1].md
  - .prompts/NNN-$ARGUMENTS-[step2].md
  [...]

Execution strategy: [PARALLEL/SEQUENTIAL] - [brief reason]

What's next?
1. Run all prompts now
2. Run first prompt only
3. Review/edit prompts first
4. Return to planning

Choose (1-4): _
```

**Execute user choice:**
- Option 1 (parallel): `/cacack:run-prompt NNN NNN+1 ... --parallel`
- Option 1 (sequential): `/cacack:run-prompt NNN NNN+1 ... --sequential`
- Option 2: `/cacack:run-prompt NNN`
- Option 3: List files for user to review
- Option 4: Return to plan presentation
</prompt_generation>

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
