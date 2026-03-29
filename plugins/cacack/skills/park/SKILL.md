---
name: park
description: Park current session context or capture cross-project ideas for later pickup
argument-hint: [path] [description]
allowed-tools:
  - Read
  - Write
  - Bash(ls:*)
  - Bash(mkdir:*)
  - Bash(date:*)
  - Glob
  - AskUserQuestion
---

<objective>
Park work for later pickup with `/whats-next`. Handles both current session handoffs and cross-project idea capture.
</objective>

<argument_parsing>
Parse `$ARGUMENTS` to determine mode:

1. **No arguments**: Interactive mode - ask what to park
2. **Description only** (no path): Quick idea capture for current project
3. **Path + description**: Cross-project idea capture

Detection logic:
- If first token starts with `~/`, `/`, or `.` → it's a path, rest is description
- Otherwise → entire argument is description for current project
- Empty → interactive mode
</argument_parsing>

<interactive_mode>
When invoked without arguments, ask the user:

```
What are you parking?

1. Current session work (continue later in this project)
2. An idea for this project (not the current session work)
3. An idea for another project

Pick (1-3): _
```

Based on selection:
- **Option 1**: Proceed to session handoff
- **Option 2**: Ask for brief description, then proceed to quick idea
- **Option 3**: Ask for project path and description, then proceed to cross-project
</interactive_mode>

<mode_session_handoff>
**Mode 1: Session Handoff (no arguments)**

Create comprehensive handoff capturing all session context. Use filename: `HANDOFF-session-{brief-slug}.md`

Generate detailed handoff with these sections:

```markdown
# Handoff: {Brief Title}

**From**: {project name} session ({date})
**Status**: {Ready for pickup / In progress / Blocked}

## Original Task
[What was initially requested - be precise about scope]

## Work Completed
[Everything accomplished in detail:
- Artifacts created/modified (with file paths)
- Specific changes made
- Commands run, actions taken
- Decisions made and reasoning]

## Work Remaining
[What still needs to be done:
- Specific tasks with file paths/locations
- Dependencies and ordering
- Validation steps needed]

## Attempted Approaches
[What was tried, including failures:
- Approaches that didn't work and why
- Errors or blockers encountered
- Dead ends to avoid]

## Critical Context
[Essential knowledge for continuing:
- Key decisions and trade-offs
- Constraints and requirements
- Important discoveries or gotchas
- Environment/setup details]

## Current State
[Exact state of work:
- What's committed vs uncommitted
- Temporary changes or workarounds
- Open questions]
```

After creating, confirm: `Parked session context to HANDOFF-session-{slug}.md`
</mode_session_handoff>

<mode_quick_idea>
**Mode 2: Quick Idea Capture (description only)**

Create lightweight handoff for an idea. Use filename: `HANDOFF-{slug-from-description}.md`

```markdown
# Handoff: {Description}

**From**: {current project} ({date})
**Status**: Idea captured

## The Idea
{Expand on the description with any relevant context from current session}

## Context
[Why this came up, any relevant background]

## Next Steps
[Suggested approach or starting points]
```

Confirm: `Parked idea to HANDOFF-{slug}.md`
</mode_quick_idea>

<mode_cross_project>
**Mode 3: Cross-Project Capture (path + description)**

Create handoff in the target project directory.

1. Validate path exists: `ls -d {path}`
2. Create `HANDOFF-{slug}.md` in that directory using quick idea format
3. Include cross-reference: `**From**: {current project} session`

Confirm: `Parked cross-project idea to {path}/HANDOFF-{slug}.md`
</mode_cross_project>

<slug_generation>
Generate kebab-case slug from description:
- Take first 3-5 meaningful words
- Lowercase, replace spaces with hyphens
- Remove special characters
- Example: "enhance the /do command workflow" → `do-command-workflow`
</slug_generation>

<examples>
```bash
# Interactive mode - asks what you're parking
/park
→ "What are you parking? (1) Session work, (2) Idea for this project, (3) Cross-project idea"
→ Based on choice, guides through the appropriate flow

# Quick idea for current project (skip interactive)
/park "add retry logic to API client"
→ Creates HANDOFF-add-retry-logic.md

# Cross-project idea (skip interactive)
/park ~/other-project "integrate with this API pattern"
→ Creates ~/other-project/HANDOFF-integrate-api-pattern.md
```
</examples>

<success_criteria>
- Handoff file created in correct location
- Appropriate detail level for mode (full vs quick)
- Clear confirmation message with file path
- File can be picked up by `/whats-next`
</success_criteria>
