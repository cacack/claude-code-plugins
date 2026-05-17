---
name: play
description: Plan the work — fetch issue (or take free-text task), explore, design, get plan approval via plan mode, then emit a DAG of execution prompts for /do to run
argument-hint: <issue-number | issue-url | task-description>
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash(gh issue:*)
  - Bash(glab issue:*)
  - Bash(git status:*)
  - Bash(git branch:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(ls:*)
  - Bash(mkdir:*)
  - Bash(find:*)
  - WebFetch
  - EnterPlanMode
  - ExitPlanMode
  - AskUserQuestion
  - TodoWrite
---

<objective>
Plan the work stage of the play → do → ship pipeline.

Fetch the issue (or accept a free-text task), explore the codebase, design an implementation approach, get user approval via plan mode, then materialize a DAG of execution prompts under `.prompts/` for `/do` to dispatch.

This separation lets planning happen in this conversation while execution happens in fresh subagent contexts.
</objective>

<context>
Repository: !`git remote -v | head -1`
Branch: !`git branch --show-current`
Working dir: !`git status --short`
Recent commits: !`git log --oneline -5`
GitHub CLI: !`which gh >/dev/null 2>&1 && echo "available" || echo "missing"`
GitLab CLI: !`which glab >/dev/null 2>&1 && echo "available" || echo "missing"`
Prompts dir: !`[ -d .prompts ] && echo "exists" || echo "missing"`
Next prompt number: !`ls -d .prompts/*/ 2>/dev/null | grep -v completed | wc -l | awk '{print $1+1}'`
</context>

<process>

<step_1_input>
Classify `$ARGUMENTS`:

- Empty → ask user for issue number/URL or task description
- Number, `#NN`, or `github.com/.../issues/NN` URL → **issue mode**
- `gitlab.com/.../-/issues/NN` URL → **issue mode (gitlab)**
- Free text → **task mode** (use description directly)

For issue mode, fetch via the available CLI:
- GitHub: `gh issue view <num> --json title,body,labels,comments`
- GitLab: `glab issue view <num>`
- If neither CLI is available, ask the user to paste the issue body or install the CLI.

On fetch failure (invalid number, auth, network), present the error and ask for a description instead.
</step_1_input>

<step_2_understand>
Extract from the issue or task:
- Title / one-line summary
- Acceptance criteria (explicit or implied)
- Constraints, dependencies, related issues
- Out-of-scope items
</step_2_understand>

<step_3_explore>
Scan the codebase to identify:
- Files the work will touch
- Existing patterns and conventions to follow
- Tests and docs that may need updating
- Hidden coupling that affects sequencing

Use Glob + Grep; do not read every file. The goal is enough context to plan, not to implement.
</step_3_explore>

<step_4_build_vs_reuse>
Before drafting the plan, ask: *what existing stdlib/library functionality can be leveraged, and what is truly domain-specific?* Document both sides — this often shrinks the plan significantly.
</step_4_build_vs_reuse>

<step_5_plan_mode>
Enter plan mode with `EnterPlanMode`. The plan file should follow the structure in `<plan_structure>` below. When the plan is complete, call `ExitPlanMode` for native approval UX.

If the user rejects or asks for changes, iterate in plan mode until approved.
</step_5_plan_mode>

<step_6_emit_prompts>
After plan approval, materialize the plan as a DAG of prompts under `.prompts/`:

1. **Compute topic slug** — kebab-case identifier from the issue title or task (e.g., `42-add-auth`, `bump-deps`)
2. **Compute next number** — see context block
3. **Partition plan steps into execution groups** — group steps that can run in parallel (independent file sets, no ordering constraint) and serialize between groups that depend on each other
4. **Create one subdirectory per prompt**: `.prompts/{NNN}-{step-slug}-{purpose}/`
   - `purpose` is one of `research`, `plan`, `do` (most /play prompts are `do`)
5. **Write each prompt** as `.prompts/{NNN}-{step-slug}-{purpose}/{NNN}-{step-slug}-{purpose}.md` using `<prompt_template>`
6. **Write `.prompts/.batch.json`** in execution_groups format (see `<batch_format>`)
7. **Display summary**:

   ```
   Plan approved. Emitted {N} prompts in {M} groups:

   Group 1 [parallel]: 001-research-auth, 002-research-db
   Group 2 [sequential]: 003-design-architecture
   Group 3 [parallel]: 004-implement-auth, 005-implement-db

   Next: run `/cacack:do` to execute the batch.
   ```

If the plan is a single step, emit a single prompt and a one-group batch.
</step_6_emit_prompts>

</process>

<plan_structure>
Use this structure when writing the plan in plan mode:

```markdown
## Issue / Task
[#NN](url) — Title  *(or one-line task description)*

## Key Requirements
- ...

## Affected Areas
- `path/to/file` — what changes

## Build vs Reuse
- Leveraging: [stdlib/library] — what it handles
- Must build: [component] — why

## Implementation Plan
1. **Step name** *(parallel-safe / depends on N)*
   - Files: `...`
   - Details: ...
2. **Step name** *(parallel-safe / depends on 1)*
   - ...

## Testing Plan
- [ ] ...

## Documentation Impact
- [ ] README.md / CHANGELOG.md / FEATURES.md / IDEAS.md — what changes

## Open Questions
- ...
```

The parallel-safe / depends-on N annotations are what drive the execution_groups partitioning in step 6.
</plan_structure>

<prompt_template>
Each emitted prompt file uses XML structure (matches the create-meta-prompts contract so /run-prompt and /do can execute it):

```xml
<objective>
[Concrete goal from the plan step]
Why it matters: [link back to the issue/task]
</objective>

<context>
Issue/task: [reference]
@[files identified during exploration]
[Any cross-prompt dependencies — e.g., "depends on output of 001-research-auth/SUMMARY.md"]
</context>

<requirements>
[Acceptance criteria specific to this step]
[Patterns to follow from codebase exploration]
</requirements>

<implementation>
[Approach decided during planning]
[What to avoid based on existing code]
</implementation>

<output>
Files to create/modify:
- `path` — what changes

Must also write SUMMARY.md in this prompt's folder with:
- One-liner outcome
- Files changed
- Decisions made / open questions
- Next step
</output>

<verification>
- [Specific check]
- [How to confirm success]
</verification>

<success_criteria>
[Measurable, tied to issue acceptance criteria]
</success_criteria>
```
</prompt_template>

<batch_format>
`.prompts/.batch.json` uses the execution_groups format that `/run-prompt` consumes:

```json
{
  "created": "<ISO-8601 timestamp>",
  "source": "/play <input>",
  "execution": [
    {"strategy": "parallel", "prompts": ["001-research-auth", "002-research-db"]},
    {"strategy": "sequential", "prompts": ["003-design-architecture"]},
    {"strategy": "parallel", "prompts": ["004-implement-auth", "005-implement-db"]}
  ],
  "completed": []
}
```

Notes:
- `prompts` entries are folder names (no `.md`); `/run-prompt` resolves the inner file
- Use `parallel` only when prompts touch disjoint files and have no ordering dependency
- A single-step plan still emits a valid batch with one group containing one prompt
- Flag in the source string when worktree isolation should be considered (e.g., `"isolation": "worktree"` at root) — `/run-prompt` and `/do` will honor it
</batch_format>

<success_criteria>
- Issue fetched cleanly (or task description accepted) — errors surfaced, not silently retried
- Codebase exploration produced concrete affected-area list before planning
- Build-vs-Reuse check happened explicitly
- Plan approved via `ExitPlanMode`, not via inline markdown + "ready?"
- Prompts emitted as subdirectories matching the create-meta-prompts format
- `.batch.json` written with execution_groups reflecting actual step dependencies
- Final message points the user to `/cacack:do` to execute
- No implementation happens in this skill — that's `/do`'s job
</success_criteria>

<examples>

```bash
# GitHub issue
/play 42
→ Fetches #42, plans, approves via plan mode, emits .prompts/001-42-* batch

# GitLab issue via URL
/play https://gitlab.com/owner/repo/-/issues/7
→ Same flow, via glab

# Free-text task (non-trivial enough to want planning)
/play "split auth middleware into oauth and session modules"
→ Plans, emits prompts; user runs /do to execute

# Trivial task — wrong tool, suggest /do directly
/play "fix typo in README"
→ Notes that /do "fix typo in README" is the right path; offers to proceed anyway
```

</examples>