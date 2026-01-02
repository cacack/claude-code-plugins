---
description: Interactive discovery and selection of pending work prioritized by readiness (handoffs, todos, issues, ideas)
argument-hint: "[handoff|todos|issues|ideas]"
allowed-tools:
  - Read
  - Glob
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
4. GitHub issues (use prioritized discovery below)
5. `Glob("IDEAS.md")` - ideas backlog

### GitHub Issue Priority Discovery

Issues with effort/value labels are prioritized first using a value/effort matrix. Issues without effort/value labels fall back to the priority ladder.

**Effort/Value Matrix** (best to worst):
1. `value:high` + `effort:low` - Quick wins, do first
2. `value:high` + `effort:medium` - High impact
3. `value:medium` + `effort:low` - Easy improvements
4. `value:high` + `effort:high` - Major projects
5. `value:medium` + `effort:medium` - Standard work
6. `value:low` + `effort:low` - Fill-in tasks
7. `value:medium` + `effort:high` - Consider carefully
8. `value:low` + `effort:medium` - Low priority
9. `value:low` + `effort:high` - Avoid if possible

**Priority Ladder** (fallback when no effort/value labels):
`priority:high` > `priority:medium` > `priority:low` > `priority:future` > unlabeled

**IMPORTANT**: Run these commands exactly as shown - do NOT add `2>/dev/null`, `|| echo "[]"`, or other error suppression. Let errors surface so issues can be diagnosed. If a command fails, report the error to the user.

1. **Assigned to you** (most actionable):
   `gh issue list --assignee @me --limit=5 --json number,title,labels`

2. **Value-labeled issues** (for matrix sorting):
   `gh issue list --label "value:high" --limit=5 --json number,title,labels`
   `gh issue list --label "value:medium" --limit=3 --json number,title,labels`
   `gh issue list --label "value:low" --limit=2 --json number,title,labels`

3. **Priority-labeled issues** (fallback):
   `gh issue list --label "priority:high" --limit=3 --json number,title,labels`
   `gh issue list --label "priority:medium" --limit=3 --json number,title,labels`
   `gh issue list --label "priority:low" --limit=2 --json number,title,labels`
   `gh issue list --label "priority:future" --limit=2 --json number,title,labels`

4. **Unlabeled/other** (fallback):
   `gh issue list --limit=5 --json number,title,labels`

Combine results, removing duplicates. Sort issues with effort/value labels using the matrix above, then append priority-labeled issues, then unlabeled. Present up to 5 unique issues.

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

1. Delegate to `/play` skill with issue selection, showing priority context:
   ```
   Found issues (prioritized):
   1. #42 - Add retry logic to API [assigned] [value:high] [effort:low]
   2. #38 - Fix auth token refresh [value:high] [effort:medium]
   3. #35 - Update documentation [priority:medium]

   Pick an issue (1-3): _
   ```

   Priority indicators (show all applicable):
   - `[assigned]` - Issues assigned to current user
   - `[value:high]` `[value:medium]` `[value:low]` - Value labels
   - `[effort:low]` `[effort:medium]` `[effort:high]` - Effort labels
   - `[priority:high]` `[priority:medium]` `[priority:low]` `[priority:future]` - Priority labels (fallback)
   - `[other]` - Issues without any of the above labels

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

<verification>
Before completing:
- If handoff deleted: verify file no longer exists with Glob
- If delegated to /play: verify issue context loaded successfully
- If delegated to creation skill: verify skill invocation completed
- If user selected "skip": confirm no action taken, return cleanly
</verification>
