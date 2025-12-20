---
description: Discover and pick up work from handoffs, todos, issues, or ideas - prioritized by readiness
allowed-tools:
  - Read
  - Glob
  - Bash
  - AskUserQuestion
  - Skill
---

Find work to pick up, prioritized from most-ready to least-defined.

## Discovery Phase

Run quick checks (existence only, no reads yet) in priority order:

1. **Handoff files**: `! ls HANDOFF-*.md 2>/dev/null | head -5`
2. **Legacy whats-next**: `! ls whats-next.md 2>/dev/null`
3. **TO-DOS.md**: `! ls TO-DOS.md 2>/dev/null`
4. **GitHub issues**: `! gh issue list --assignee=@me --limit=5 2>/dev/null || gh issue list --limit=5 2>/dev/null`
5. **IDEAS.md**: `! ls IDEAS.md 2>/dev/null`

## Presentation

Present discovered sources in priority order:

```
What's next? Found these work sources:

1. 📋 HANDOFF-do-command-enhancement.md (handoff)
2. 📋 HANDOFF-session-auth-work.md (handoff)
3. ✅ TO-DOS.md (local todos)
4. 🎫 GitHub: 3 open issues
5. 💡 IDEAS.md (ideas backlog)

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
   - ✅ Yes, let's go
   - 📋 Show full handoff details
   - 🗑️ Delete handoff (already done or not needed)
   - ⬅️ Back to source list
   ```

3. If continuing: Keep handoff context loaded, begin work
4. If deleting: `rm {handoff-file}` and return to discovery

### For TO-DOS.md

1. Read TO-DOS.md
2. Present items grouped by priority/section
3. Let user pick specific item to work on
4. Selected item becomes the focus

### For GitHub Issues

1. Run `/play` skill with issue selection:
   ```
   Found issues:
   1. #42 - Add retry logic to API
   2. #38 - Fix auth token refresh
   3. #35 - Update documentation

   Pick an issue (1-3): _
   ```
2. Delegate to `/play {issue-number}` for selected issue

### For IDEAS.md

1. Read IDEAS.md
2. Present ideas list
3. For selected idea, offer:
   - Create GitHub issue from it
   - Start working directly
   - Refine the idea first

## Priority Rationale

1. **Handoffs first**: Already-started work, has context, highest value to continue
2. **TO-DOS**: Committed local tasks, defined scope
3. **GitHub issues**: Tracked, possibly assigned, team-visible
4. **IDEAS last**: Vague concepts, need refinement before real work

## Success Criteria

- Quick discovery without reading file contents
- Clear presentation of available work sources
- Smooth handoff to appropriate handler (/play for issues)
- Option to delete processed handoffs
- Graceful handling when no work found
