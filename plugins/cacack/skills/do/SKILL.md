---
name: do
description: Execute the work stage of play → do → ship. Invoke after /play to dispatch the emitted prompt batch, or directly with a task description for trivial work. Triggers include "do it", "execute the plan", "run the batch", "run the prompts", "dispatch them", "do <task>", or "do <prompt-numbers>".
argument-hint: <prompt-numbers | "task description"> — empty runs the latest /play batch
---
<!-- No allowed-tools restriction: /do is an orchestration command. Batch/prompts mode delegates to /cacack:run-prompt (which uses Task internally to spawn subagents). Direct mode uses TodoWrite + the full file-edit surface (Read/Edit/Write/Glob/Grep/Bash). Tightening this would require auditing both code paths together. -->

<objective>
Execute the work stage of the play → do → ship pipeline.

Three modes, auto-detected from `$ARGUMENTS`:
1. **Empty** → run the latest `.prompts/` batch from `/play` (most common case)
2. **Prompt numbers** (e.g. `001 002` or `001-003`) → run those specific prompts
3. **Free-text task** → execute directly in current context (skips `/play` for trivial work)
</objective>

<context>
Repository: !`git remote get-url origin 2>/dev/null`
Branch: !`git branch --show-current`
Status: !`git status --short`
</context>

<!-- `.prompts/.batch.json` presence and pending-prompt counts are read in the body (step_dispatch)
via real Bash/Read calls, NOT in `<context>`: `!` preprocessing cannot prompt for permission or
tolerate a nonzero exit, so `[ -f ]`/`ls`/pipes would make the skill fail to load. -->


<process>

<step_dispatch>
Classify `$ARGUMENTS` and route:

| Pattern | Mode |
|---|---|
| empty | **batch** — run latest `.prompts/.batch.json` |
| digits only or digits with spaces/dashes (e.g. `001`, `1 2 3`, `001-003`) | **prompts** — run those specific prompts |
| anything else (free text) | **direct** — execute task in current context |

If pattern is ambiguous (single word that could be a partial filename), prefer **prompts** mode and let `/run-prompt`'s name matching resolve it.

**Migration hint for bare integers:** If a bare integer is given but `.prompts/` doesn't exist (or contains no matching prompt for that number), suggest the user likely meant an issue number and point them at `/play <N>` — the old `/do <issue-number>` workflow moved to `/play`. Print:

```
No prompt 0NN/NN found in .prompts/. If you meant issue #NN,
run `/cacack:play NN` first to plan, then `/cacack:do` to execute.
```

**Worktree note:** the cycle always runs inside a dedicated git worktree — unconditional and self-contained, not gated on CLAUDE.md. **batch** and **prompts** modes expect to already be in the worktree `/play` created — they inherit it via the working directory and must NOT create a fresh one (a new worktree branches off clean default and would orphan the `.prompts/` batch). If `git rev-parse --show-toplevel` is not under `/.claude/worktrees/`, you are resuming outside that worktree — proceed, but note the run isn't isolated from simultaneous work. **direct** mode is a cycle entry point and creates its own worktree (see `<step_direct>`).
</step_dispatch>

<step_batch_or_prompts>
For **batch** and **prompts** modes, before delegating, offer the user a dispatch choice via `AskUserQuestion`:

- **Subagent dispatch (default)** — invoke `/cacack:run-prompt` via the Skill tool. Each prompt runs in fresh context via `Agent`/Task. Best for: large batches, parallel groups, when current context is already loaded.
- **Inline execution** — read each prompt's content and execute it in the current session context (no `Task` calls). Best for: small batches (1-3 prompts), when the user wants to watch the work happen live, or when keeping planning + implementation in one context is valuable.

Present subagent dispatch as the first option (labeled "(Recommended)"). If the batch contains parallel groups, always recommend subagent dispatch (inline can't run prompts in parallel within a single message in a useful way).

**If user picks subagent dispatch:** Invoke `/cacack:run-prompt` via the Skill tool, passing `$ARGUMENTS` through. `/run-prompt` handles DAG execution: parallel groups dispatch all `Agent` calls in a single message; sequential groups run in order; archives completed prompts to `.prompts/completed/`; updates `.batch.json` progress so interrupted runs can resume.

**If user picks inline execution:** For each prompt in the batch (respecting batch ordering — sequential groups stay sequential; parallel groups degrade to sequential since the current context can't truly run prompts in parallel):
1. Read the prompt file from `.prompts/{folder}/{folder}.md`
2. Execute its `<objective>`, `<requirements>`, `<implementation>`, and `<output>` instructions directly in this context
3. Write the prompt's required `SUMMARY.md` in its folder
4. Archive the folder to `.prompts/completed/` and update `.batch.json`'s `completed` array
5. Stop if any prompt fails — progress is preserved

**Terminal-state batch:** If `.batch.json` exists but every entry is already in `completed`, skip the dispatch choice and surface to the user: "Latest batch is already complete — start a new `/play` or pass a free-text task to run something."
</step_batch_or_prompts>

<step_direct>
For **direct** mode (free-text task), execute in current context:

0. **Ensure worktree isolation.** Direct mode is a cycle entry point (it skips `/play`), so isolate it the same way. Run `git rev-parse --show-toplevel`; if the path is not under `/.claude/worktrees/`, call `EnterWorktree` with a slug derived from the task before making any edits, silently. Skip if already in a worktree (e.g. invoked after `/play` — no-op), or if the command fails (not a git repo) — note it in one line and proceed. This is unconditional and self-contained — calling `EnterWorktree` here is itself the directive; do **not** gate it on CLAUDE.md.
1. Quick codebase scan to understand the area (use Glob/Grep, not full exploration)
2. Create a TodoWrite list with the major steps
3. Implement, marking todos complete as you go
4. Verify with whatever check the project supports (lint, tests, type-check)

> Note: this step uses `TodoWrite`, `Glob`, `Grep`, `Read`, `Edit`, `Write`, `Bash`, and `EnterWorktree`. They aren't listed in `allowed-tools` because the skill intentionally has no tool restriction — see the comment at the top of this file. If `allowed-tools` is ever added, include all of the above.

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
- **batch / prompts mode (subagent dispatch)**: per-prompt SUMMARY.md displayed inline; `.prompts/completed/` updated; `.batch.json` progress recorded
- **batch / prompts mode (inline execution)**: same artifacts as subagent dispatch (SUMMARY.md, archive, batch metadata), produced by current-context work instead of `Task` calls
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
- Batch/prompts mode offers dispatch choice (subagent vs inline) with a sensible default
- Subagent dispatch delegates to `/run-prompt` (no duplicated execution logic)
- Inline dispatch produces the same artifacts (SUMMARY.md, archive, batch metadata) without `Task` calls
- Direct mode produces implementation + verification, not just a plan
- `/ship` offered but not auto-invoked
- If task expands beyond the chosen mode's fit, redirect rather than push through
</success_criteria>
