---
description: Execute work with selectable rigor level - vibe, delegate, or speckit
argument-hint: <issue-number-or-task-description>
---
# Note: No allowed-tools restriction - this is an orchestration command
# that delegates to other workflows requiring varied tool access.

<objective>
Execute work on `$ARGUMENTS` with user-selected rigor level.
Bridges the gap between quick implementation and structured planning.
</objective>

<context>
Repository: ! `git remote -v | head -1`
Branch: ! `git branch --show-current`
Git status: ! `git status --short`
GitHub CLI: ! `which gh >/dev/null 2>&1 && echo "available" || echo "NOT INSTALLED"`
</context>

<process>

## 1. Parse Input

Determine task type from `$ARGUMENTS`:
- **Issue reference**: `#42`, `42`, or full URL → fetch issue details
- **Task description**: Free text → use as-is

**Issue detection regex**: `^#?\d+$` or contains `github.com/.*/issues/\d+`

If issue reference detected:
1. Verify GitHub CLI is available (check context above)
2. If not available, inform user: "GitHub CLI not installed. Install with `brew install gh` or provide task description instead."
3. Fetch issue:
   ```bash
   gh issue view [number] --json title,body,labels
   ```
4. If fetch fails (invalid number, network error, auth issue), present error and ask for task description instead

## 2. Present Rigor Options

```
Task: [issue title or task description]

Choose your approach:

1. Vibe it    - Implement now, iterate as we go
2. Delegate  - Create prompts for /run-prompt execution
3. Speckit   - Full spec, plan, and task breakdown

Pick (1-3): _
```

## 3. Execute Selected Approach

### Option 1: Vibe It

Light, iterative implementation in current session.

1. Quick codebase scan to understand relevant areas
2. Create simple todo list with major steps
3. Start implementing immediately
4. Iterate based on what we discover
5. When done, offer `/ship`

**Characteristics:**
- Minimal upfront planning
- Learn by doing
- Good for well-understood changes
- Good for small-to-medium tasks

### Option 2: Delegate

Create structured prompts for parallel/sequential execution.

1. Analyze task and break into discrete steps
2. Identify dependencies between steps:
   - **Parallel**: Steps touch different files, no shared state
   - **Sequential**: Steps depend on prior step output
3. Create prompt files in `./prompts/` directory
4. Each prompt is self-contained with context
5. Present execution options

**Prompt structure:**
```xml
<objective>
[Clear goal for this step]
</objective>

<context>
[Relevant files and background]
@[file references]
</context>

<requirements>
[Specific requirements]
</requirements>

<verification>
[How to confirm success]
</verification>
```

### Option 3: Speckit

Maximum rigor with full specification workflow.

1. **Specification phase:**
   - Deep requirements analysis
   - Edge case identification
   - Acceptance criteria definition
   - Create `SPEC-[task].md`

2. **Planning phase:**
   - Enter plan mode with EnterPlanMode
   - Detailed implementation design
   - File-by-file change breakdown
   - Risk assessment

3. **Task breakdown:**
   - Create granular todo list
   - Each task is atomic and testable
   - Dependencies clearly marked

4. **Execution:**
   - Work through tasks systematically
   - Verify each step before proceeding
   - Document decisions as we go

**Characteristics:**
- Maximum upfront investment
- Good for complex/risky changes
- Good for unfamiliar codebases
- Creates documentation as side effect

</process>

<output>
**Vibe option produces:**
- Completed implementation
- Updated todo list showing progress

**Delegate option produces:**
- `./prompts/NNN-[task]-[step].md` files
- Execution recommendation (parallel/sequential)

**Speckit option produces:**
- `SPEC-[task].md` specification document
- Implementation plan (via EnterPlanMode)
- Granular todo list
</output>

<verification>
**Before completing Delegate option, verify:**
- [ ] All prompt files created in `./prompts/`
- [ ] Each prompt has objective, context, requirements, verification sections
- [ ] File references (@paths) point to existing files
- [ ] Dependencies between steps are correctly identified
- [ ] Execution strategy (parallel/sequential) is appropriate

**Before completing Speckit option, verify:**
- [ ] SPEC file captures all requirements
- [ ] Plan addresses all spec items
- [ ] Todo list covers full implementation
</verification>

<decision_help>

When to suggest each approach:

| Signal | Suggested Approach |
|--------|-------------------|
| "quick", "simple", "small" in task | Vibe it |
| Familiar codebase, clear requirements | Vibe it |
| Multi-step task, wants delegation | Delegate |
| Complex task, multiple files | Delegate or Speckit |
| "careful", "thorough", "spec" in task | Speckit |
| Unfamiliar codebase, unclear scope | Speckit |
| Breaking changes, architectural | Speckit |

**Examples of approach selection:**

1. `/do "fix typo in README"` → Suggest **Vibe** (simple, single file)
2. `/do 42` (issue: "Add user authentication") → Suggest **Speckit** (complex, architectural)
3. `/do "refactor API client into separate modules"` → Suggest **Delegate** (multi-step, parallelizable)
4. `/do "update dependencies and fix breaking changes"` → Suggest **Speckit** (risky, needs analysis)

</decision_help>

<success_criteria>
- User clearly understands the three options
- Selected approach is executed appropriately:
  - **Vibe**: Implementation starts within 2-3 messages
  - **Delegate**: All prompts created, validated, and ready to run
  - **Speckit**: Specification and plan approved before any implementation
- Error cases handled gracefully (missing gh CLI, invalid issue, network failure)
</success_criteria>

<examples>

```bash
# From issue number
/do 42
→ Fetches issue #42, presents rigor options

# From issue with hash
/do #42
→ Same as above

# From description
/do "add retry logic to API client"
→ Uses description directly, presents rigor options

# Full GitHub URL
/do https://github.com/owner/repo/issues/123
→ Fetches issue from URL, presents rigor options
```

</examples>
