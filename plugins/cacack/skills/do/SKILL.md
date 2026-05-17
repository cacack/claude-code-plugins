---
name: do
description: Execute the work stage of play → do → ship. Invoke after /play to dispatch the emitted prompt batch, or directly with a task description for trivial work. Triggers include "do it", "execute the plan", "run the batch", "run the prompts", "dispatch them", "do <task>", or "do <prompt-numbers>".
argument-hint: [prompt-numbers | task-description | empty for latest batch]
---

<objective>
Execute the work stage of the play → do → ship pipeline.

Three modes, auto-detected from `$ARGUMENTS`:
1. **Empty** → run the latest `.prompts/` batch from `/play` (most common case)
2. **Prompt numbers** (e.g. `001 002` or `001-003`) → run those specific prompts
3. **Free-text task** → execute directly in current context (skips `/play` for trivial work)
</objective>

<context>
Repository: !`git remote -v | head -1`
Branch: !`git branch --show-current`
Status: !`git status --short`
Latest batch: !`[ -f .prompts/.batch.json ] && echo "found" || echo "none"`
Pending prompts: !`ls -d .prompts/*/ 2>/dev/null | grep -v completed | wc -l | awk '{print $1}'`
</context>

<process>

<step_dispatch>
Classify `$ARGUMENTS` and route:

| Pattern | Mode |
|---|---|
| empty | **batch** — run latest `.prompts/.batch.json` |
| digits only or digits with spaces/dashes (e.g. `001`, `1 2 3`, `001-003`) | **prompts** — run those specific prompts |
| anything else (free text) | **direct** — execute task in current context |

If pattern is ambiguous (single word that could be a partial filename), prefer **prompts** mode and let `/run-prompt`'s name matching resolve it.
</step_dispatch>

<step_batch_or_prompts>
For **batch** and **prompts** modes, invoke `/cacack:run-prompt` via the Skill tool, passing `$ARGUMENTS` through.

`/run-prompt` handles DAG execution: parallel groups dispatch all `Agent` calls in a single message; sequential groups run in order; archives completed prompts to `.prompts/completed/`; updates `.batch.json` progress so interrupted runs can resume.

When the user's plan involves parallel prompts that may touch overlapping files, suggest the user re-run with `isolation: worktree` — or use it implicitly if the batch metadata flags conflicts.
</step_batch_or_prompts>

<step_direct>
For **direct** mode (free-text task), execute in current context:

1. Quick codebase scan to understand the area (use Glob/Grep, not full exploration)
2. Create a TodoWrite list with the major steps
3. Implement, marking todos complete as you go
4. Verify with whatever check the project supports (lint, tests, type-check)

This path skips planning because the task is small enough to not need it. If the task turns out to be larger than expected, stop and suggest the user re-run via `/play` for proper planning.
</step_direct>

<step_finish>
After all execution paths complete, offer `/ship`:

```
Work complete. Run `/cacack:ship` to commit and create a PR?
```

Do not invoke `/ship` automatically — the user should inspect changes first.
</step_finish>

</process>

<output>
- **batch / prompts mode**: per-prompt SUMMARY.md displayed inline; `.prompts/completed/` updated; `.batch.json` progress recorded
- **direct mode**: implementation complete; todos marked done; suggested verification run
- **all modes**: explicit offer to run `/cacack:ship`
</output>

<examples>

```bash
# After /play 42 created a batch
/do
→ Reads .prompts/.batch.json, dispatches subagents per DAG

# Run specific prompts
/do 001 002 003
→ Runs those prompts, respecting any batch metadata for ordering

# Trivial task, skip planning
/do "fix typo in README intro paragraph"
→ Executes directly, offers /ship

# From an issue, when /play is overkill
/do "bump dependency X to v2"
→ Direct execution
```

</examples>

<decision_help>

| Signal in task | Mode hint |
|---|---|
| Trivial, single-file, well-understood | **direct** (or just edit yourself) |
| Multi-step, multi-file, parallelizable | Run `/play` first, then `/do` (no args) |
| Issue with acceptance criteria | Run `/play <issue>` first |
| Quick refactor with clear shape | **direct** |
| Architectural / risky | Always `/play` first |

When in doubt, use `/play` — the planning cost is small and the DAG enables parallel execution.

</decision_help>

<success_criteria>
- Mode correctly inferred from `$ARGUMENTS`
- Batch/prompts mode delegates to `/run-prompt` (no duplicated execution logic)
- Direct mode produces implementation + verification, not just a plan
- `/ship` offered but not auto-invoked
- If task expands beyond the chosen mode's fit, redirect rather than push through
</success_criteria>