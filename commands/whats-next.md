---
description: Interactive discovery and selection of pending work prioritized by readiness (handoffs, todos, issues, ideas)
argument-hint: "[source-type: handoff|todos|issues|ideas]"
allowed-tools:
  - Read
  - Glob
  - Bash(ls *)
  - Bash(rm HANDOFF-*)
  - Bash(gh issue list*)
  - AskUserQuestion
  - Skill
---

<objective>
Find work to pick up, prioritized from most-ready to least-defined.
Help discover the most actionable work available and smoothly hand off to appropriate handlers.
</objective>

<process>
## Discovery Phase

If an argument is provided, skip directly to that source type.

Use Glob and Bash to discover available work sources:
1. `Glob("HANDOFF-*.md")` - handoff files
2. `Glob("whats-next.md")` - legacy whats-next
3. `Glob("TO-DOS.md")` - local todos
4. `Bash(gh issue list --limit=5)` - GitHub issues
5. `Glob("IDEAS.md")` - ideas backlog

## Presentation

Present discovered sources in priority order:

```
What's next? Found these work sources:

1. HANDOFF-do-command-enhancement.md (handoff)
2. HANDOFF-session-auth-work.md (handoff)
3. TO-DOS.md (local todos)
4. GitHub: 3 open issues
5. IDEAS.md (ideas backlog)

Pick a source (1-5), or 0 to skip: _
```

If nothing found:
```
No pending work found. You're all caught up!

Options:
- Create a GitHub issue to track new work
- Start working on something and /park it when done
```

## Pickup Phase

Based on selection, read and present the work:

### For Handoff Files

1. Read the selected handoff file
2. Present summary:
   ```
   Picking up: HANDOFF-do-command-enhancement.md

   ## Summary
   {Extract key points from handoff}

   ## Work Remaining
   {List remaining tasks}

   Ready to continue this work?
   - Yes, let's go
   - Show full handoff details
   - Delete handoff (already done or not needed)
   - Back to source list
   ```

3. If continuing: Keep handoff context loaded, begin work
4. If deleting: `rm {handoff-file}` and return to discovery

### For TO-DOS.md

1. Read TO-DOS.md
2. Present items grouped by priority/section
3. Let user pick specific item to work on
4. Selected item becomes the focus

### For GitHub Issues

1. Delegate to `/play` skill with issue selection:
   ```
   Found issues:
   1. #42 - Add retry logic to API
   2. #38 - Fix auth token refresh
   3. #35 - Update documentation

   Pick an issue (1-3): _
   ```
2. Run `/play {issue-number}` for selected issue

### For IDEAS.md

1. Read IDEAS.md
2. Present ideas list
3. For selected idea, offer:
   - Create GitHub issue from it
   - Start working directly
   - Refine the idea first

## Plugin Feature Delegation

When picked-up work involves creating new plugin resources, delegate to the appropriate creation skill:

| Work involves...       | Delegate to              |
|------------------------|--------------------------|
| New slash command      | `/create-slash-command`  |
| New subagent           | `/create-subagent`       |
| New skill              | `/create-agent-skill`    |
| New hook               | `/create-hook`           |
| New prompt             | `/create-prompt`         |
| New meta-prompt        | `/create-meta-prompt`    |

These skills ensure best practices are followed and provide guided creation workflows.

## Priority Rationale

1. **Handoffs first**: Already-started work, has context, highest value to continue
2. **TO-DOS**: Committed local tasks, defined scope
3. **GitHub issues**: Tracked, possibly assigned, team-visible
4. **IDEAS last**: Vague concepts, need refinement before real work
</process>

<success_criteria>
- Quick discovery using Glob (graceful when files don't exist)
- Clear presentation of available work sources
- Smooth handoff to appropriate handler (/play for issues, /create-* for new features)
- Option to delete processed handoffs
- Graceful handling when no work found
- Direct source access when argument provided
</success_criteria>
