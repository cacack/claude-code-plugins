---
description: Interactive discovery and selection of pending work prioritized by readiness (prompts, handoffs, todos, issues, ideas)
argument-hint: "[prompts|handoff|todos|issues|ideas]"
allowed-tools:
  - Read
  - Glob
  - Bash(rm HANDOFF-*)
  - Bash(rm .prompts/.batch.json)
  - Bash(rm -rf .prompts/)
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

If an argument is provided (prompts, handoff, todos, issues, ideas), skip directly to that source type.

Use Glob and Bash to discover available work sources:
1. Pending prompts in `.prompts/` (use prompt discovery below)
2. `Glob("HANDOFF-*.md")` - handoff files
3. `Glob("whats-next.md")` - legacy whats-next
4. `Glob("TODO.md")` - local todos
5. GitHub issues (use prioritized discovery below)
6. `Glob("IDEAS.md")` - ideas backlog

### Prompt Discovery

Check for pending prompts that haven't been executed yet:

1. **Scan for pending prompts**:
   - `Glob(".prompts/*.md")` - flat prompts from `/create-prompt`
   - `Glob(".prompts/*/*.md")` - folder-based prompts from `/create-prompt-pipeline`
   - Exclude files in `completed/` subdirectories

2. **Read batch metadata** (if exists):
   - Check for `.prompts/.batch.json` which contains execution context
   - **Simple format** (all prompts share one strategy):
     ```json
     {
       "created": "2025-01-02T10:30:00Z",
       "strategy": "sequential",
       "source": "/do #42",
       "prompts": ["001-setup-database.md", "002-create-api.md", "003-add-tests.md"],
       "completed": ["001-setup-database.md"]
     }
     ```
   - **Execution groups format** (mixed strategies):
     ```json
     {
       "created": "2025-01-02T10:30:00Z",
       "source": "/do #42",
       "execution": [
         {"strategy": "parallel", "prompts": ["001-api-research.md", "002-db-research.md"]},
         {"strategy": "sequential", "prompts": ["003-architecture-plan.md"]},
         {"strategy": "parallel", "prompts": ["004-implement-api.md", "005-implement-db.md"]}
       ],
       "completed": ["001-api-research.md", "002-db-research.md"]
     }
     ```

3. **Determine pending state**:
   - If `.batch.json` exists with `execution` array: Parse groups, identify current layer and remaining prompts
   - If `.batch.json` exists with `strategy`: Use simple format
   - If no `.batch.json`: Treat all non-completed prompts as pending (default to sequential)

4. **Calculate progress** (if batch):
   - Total prompts in batch (sum across all groups if execution format)
   - Completed count (from `completed` array)
   - Current execution layer (for execution groups format)
   - Remaining count

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

1. .prompts/: 2 of 3 prompts remaining [sequential] (from /do #42)
2. HANDOFF-do-command-enhancement.md (handoff)
3. HANDOFF-session-auth-work.md (handoff)
4. TODO.md (local todos)
5. GitHub: 3 open issues
6. IDEAS.md (ideas backlog)

Pick a source (1-6), or 0 to skip: _
```

**Prompt source display variations:**
- Simple batch: `.prompts/: 2 of 3 prompts remaining [sequential] (from /do #42)`
- Execution groups: `.prompts/: 3 of 5 prompts remaining [layer 2/3: sequential] (from /do #42)`
- Without batch context: `.prompts/: 3 pending prompts`
- Single prompt: `.prompts/: 1 pending prompt (001-implement-feature.md)`

If nothing found:
```
No pending work found. You're all caught up!

Options:
- Create a GitHub issue to track new work
- Start working on something and /park it when done
```

## Pickup Phase

Based on selection, read and present the work:

### For Pending Prompts

1. Read batch metadata from `.prompts/.batch.json` (if exists)
2. List pending prompts with their status:

**Simple format display:**
```
Resuming prompt execution:

Source: /do #42
Strategy: sequential
Progress: 1/3 completed

Completed:
✓ 001-setup-database.md

Remaining:
→ 002-create-api.md (next)
  003-add-tests.md

Resume options:
1. Continue from where we left off (002-create-api.md)
2. Re-run all remaining prompts
3. View prompt details first
4. Discard batch and start fresh
5. Back to source list
```

**Execution groups format display:**
```
Resuming prompt execution:

Source: /do #42
Progress: 2/5 completed (layer 1 complete, on layer 2)

Layer 1 [parallel] ✓ complete
  ✓ 001-api-research.md
  ✓ 002-db-research.md

Layer 2 [sequential] ← current
  → 003-architecture-plan.md (next)

Layer 3 [parallel] pending
    004-implement-api.md
    005-implement-db.md

Resume options:
1. Continue from current layer (003-architecture-plan.md)
2. Re-run from layer 2
3. View prompt details first
4. Discard batch and start fresh
5. Back to source list
```

3. **If continuing** (option 1 or 2):
   - **Simple format**: Invoke `/run-prompt` with strategy flag:
     - Option 1 (continue): `/cacack:run-prompt 002 003 --sequential`
     - Option 2 (re-run all): `/cacack:run-prompt 001 002 003 --sequential`
   - **Execution groups**: Invoke `/run-prompt` which reads `.batch.json` for execution order:
     - `/run-prompt` will execute layer by layer, respecting each layer's strategy

4. **If viewing details** (option 3):
   - Read and display each pending prompt's objective section
   - Return to resume options after viewing

5. **If discarding** (option 4):
   - Delete `.prompts/.batch.json`
   - Optionally offer to delete all prompts in `.prompts/`
   - Return to discovery

**Without batch metadata:**
```
Found pending prompts (no batch context):

  001-implement-auth.md
  002-implement-api.md
  003-add-tests.md

No execution strategy recorded. How to proceed?
1. Run sequentially (recommended for dependent tasks)
2. Run in parallel (for independent tasks)
3. View prompt details first
4. Delete all and start fresh
5. Back to source list
```

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

### For TODO.md

1. Read TODO.md
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

1. **Prompts first**: Already-created execution prompts, ready to run, may be mid-batch
2. **Handoffs second**: Already-started work, has context, high value to continue
3. **TO-DOS**: Committed local tasks, defined scope
4. **GitHub issues**: Tracked, possibly assigned, team-visible
5. **IDEAS last**: Vague concepts, need refinement before real work
</process>

<success_criteria>
- Quick discovery using Glob (graceful when files don't exist)
- Clear presentation of available work sources
- Pending prompts shown first with batch context (strategy, progress, source)
- Smooth handoff to appropriate handler (/run-prompt for prompts, /play for issues, /create-* for new features)
- Option to delete processed handoffs or discard prompt batches
- Graceful handling when no work found
- Direct source access when argument provided
</success_criteria>

<verification>
Before completing:
- If prompts resumed: verify /run-prompt invoked with correct strategy flag
- If batch discarded: verify .prompts/.batch.json no longer exists
- If handoff deleted: verify file no longer exists with Glob
- If delegated to /play: verify issue context loaded successfully
- If delegated to creation skill: verify skill invocation completed
- If user selected "skip": confirm no action taken, return cleanly
</verification>
