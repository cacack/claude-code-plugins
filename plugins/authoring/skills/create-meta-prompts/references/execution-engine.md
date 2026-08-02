# Execution Engine

Detailed documentation for prompt execution modes, dependency detection, validation, and failure handling.

## Execution Modes

### Single Prompt

Straightforward execution of one prompt.

1. Read prompt file contents
2. Spawn Task agent with subagent_type="general-purpose"
3. Include in task prompt:
   - The complete prompt contents
   - Output location: `.prompts/{number}-{topic}-{purpose}/{topic}-{purpose}.md`
4. Wait for completion
5. Validate output (see validation section)
6. Archive prompt to `completed/` subfolder
7. Report results with next-step options

### Sequential Execution

For chained prompts where each depends on previous output.

1. Build execution queue from dependency order
2. For each prompt in queue:
   a. Read prompt file
   b. Spawn Task agent
   c. Wait for completion
   d. Validate output
   e. If validation fails → stop, report failure, offer recovery options
   f. If success → archive prompt, continue to next
3. Report consolidated results

**Progress reporting:**
```
Executing 1/3: 001-auth-research... ✓
Executing 2/3: 002-auth-plan... ✓
Executing 3/3: 003-auth-implement... (running)
```

### Parallel Execution

For independent prompts with no dependencies.

1. Read all prompt files
2. **CRITICAL**: Spawn ALL Task agents in a SINGLE message
   - This is required for true parallel execution
   - Each task includes its output location
3. Wait for all to complete
4. Validate all outputs
5. Archive all prompts
6. Report consolidated results (successes and failures)

**Failure handling for parallel:**
Unlike sequential, parallel continues even if some fail:
- Collect all results
- Archive successful prompts
- Report failures with details
- Offer to retry failed prompts

### Mixed Dependencies

For complex DAGs (e.g., two parallel research → one plan).

1. Analyze dependency graph from @ references
2. Group into execution layers:
   - Layer 1: No dependencies (run parallel)
   - Layer 2: Depends only on layer 1 (run after layer 1 completes)
   - Layer 3: Depends on layer 2, etc.
3. Execute each layer:
   - Parallel within layer
   - Sequential between layers
4. Stop if any dependency fails (downstream prompts can't run)

**Example:**
```
Layer 1 (parallel): 001-api-research, 002-db-research
Layer 2 (after layer 1): 003-architecture-plan
Layer 3 (after layer 2): 004-implement
```

## Dependency Detection

### Automatic Detection

Scan prompt contents for @ references to determine dependencies:

1. Parse each prompt for `@.prompts/{number}-{topic}/` patterns
2. Build dependency graph
3. Detect cycles (error if found)
4. Determine execution order

**Inference rules:**
If no explicit @ references found, infer from purpose:
- Research prompts: No dependencies (can parallel)
- Plan prompts: Depend on same-topic research
- Do prompts: Depend on same-topic plan

Override with explicit references when present.

### Missing Dependencies

If a prompt references output that doesn't exist:

1. Check if it's another prompt in this session (will be created)
2. Check if it exists in `.prompts/*/` (already completed)
3. If truly missing:
   - Warn user: "002-auth-plan references auth-research.md which doesn't exist"
   - Offer: Create the missing research prompt first? / Continue anyway? / Cancel?

## Validation

### Output Validation

After each prompt completes, verify success:

1. **File exists**: Check output file was created
2. **Not empty**: File has content (> 100 chars)
3. **Metadata present** (for research/plan): Check for required XML tags
   - `<confidence>`
   - `<dependencies>`
   - `<open_questions>`
   - `<assumptions>`
4. **SUMMARY.md exists**: Check SUMMARY.md was created
5. **SUMMARY.md complete**: Has required sections (Key Findings, Decisions Needed, Blockers, Next Step)
6. **One-liner is substantive**: Not generic like "Research completed"

### Validation Failure

If validation fails:
- Report what's missing
- Offer options:
  - Retry the prompt
  - Continue anyway (for non-critical issues)
  - Stop and investigate

## Failure Handling

### Sequential Failure

Stop the chain immediately:
```
✗ Failed at 2/3: 002-auth-plan

Completed:
- 001-auth-research ✓ (archived)

Failed:
- 002-auth-plan: Output file not created

Not started:
- 003-auth-implement

What's next?
1. Retry 002-auth-plan
2. View error details
3. Stop here (keep completed work)
4. Other
```

### Parallel Failure

Continue others, report all results:
```
Parallel execution completed with errors:

✓ 001-api-research (archived)
✗ 002-db-research: Validation failed - missing <confidence> tag
✓ 003-ui-research (archived)

What's next?
1. Retry failed prompt (002)
2. View error details
3. Continue without 002
4. Other
```

## Archiving

### Archive Timing

- **Sequential**: Archive each prompt directory immediately after successful completion
  - Provides clear state if execution stops mid-chain
- **Parallel**: Archive all at end after collecting results
  - Keeps prompts available for potential retry

### Archive Operation

Move entire prompt directory to `.prompts/completed/`:
```bash
mkdir -p .prompts/completed
mv .prompts/{number}-{topic}-{purpose}/ .prompts/completed/
```

This keeps all artifacts together (prompt, output, SUMMARY.md) and makes it immediately clear which prompts are pending vs completed by listing `.prompts/` contents.

## Result Presentation

### Single Result

```
✓ Executed: 001-auth-research
✓ Archived to: .prompts/completed/001-auth-research/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Auth Research Summary

**JWT with jose library and httpOnly cookies recommended**

## Key Findings
• jose outperforms jsonwebtoken with better TypeScript support
• httpOnly cookies required (localStorage is XSS vulnerable)
• Refresh rotation is OWASP standard

## Decisions Needed
None - ready for planning

## Blockers
None

## Next Step
Create auth-plan.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What's next?
1. Create planning prompt (auth-plan)
2. View full research output
3. Done
4. Other
```

Display the actual SUMMARY.md content inline so user sees findings without opening files.

### Chain Result

```
✓ Chain completed: auth workflow

Results:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
001-auth-research
**JWT with jose library and httpOnly cookies recommended**
Decisions: None • Blockers: None

002-auth-plan
**4-phase implementation: types → JWT core → refresh → tests**
Decisions: Approve 15-min token expiry • Blockers: None

003-auth-implement
**JWT middleware complete with 6 files created**
Decisions: Review before Phase 2 • Blockers: None
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All directories archived to .prompts/completed/
Full summaries in .prompts/completed/*/SUMMARY.md

What's next?
1. Review implementation
2. Run tests
3. Create new prompt chain
4. Other
```

For chains, show condensed one-liner from each SUMMARY.md with decisions/blockers flagged.

## Special Cases

### Re-running Completed Prompts

If user wants to re-run an already-completed prompt:

1. Check if prompt directory is in `.prompts/completed/`
2. Move entire directory back to `.prompts/`
3. Optionally backup existing output: `{output}.bak`
4. Execute normally

### Output Conflicts

If output file already exists:

1. For re-runs: Backup existing → `{filename}.bak`
2. For new runs: Should not happen (unique numbering)
3. If conflict detected: Ask user - Overwrite? / Rename? / Cancel?

### Commit Handling

After successful execution:

1. Do NOT auto-commit (user controls git workflow)
2. Mention what files were created/modified
3. User can commit when ready

Exception: If user explicitly requests commit, stage and commit:
- Output files created
- Prompts archived
- Any implementation changes (for Do prompts)

### Recursive Prompts

If a prompt's output includes instructions to create more prompts:

1. This is advanced usage - don't auto-detect
2. Present the output to user
3. User can invoke skill again to create follow-up prompts
4. Maintains user control over prompt creation
