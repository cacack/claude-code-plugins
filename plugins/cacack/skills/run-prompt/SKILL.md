---
name: run-prompt
description: Delegate one or more prompts to fresh sub-task contexts with parallel or sequential execution
argument-hint: <prompt-number(s)-or-name> [--parallel|--sequential]
---

<objective>
Execute one or more prompts from `.prompts/` as delegated sub-tasks with fresh context. Supports single prompt execution, parallel execution of multiple independent prompts, and sequential execution of dependent prompts.
</objective>

<input>
The user will specify which prompt(s) to run via $ARGUMENTS, which can be:

**Empty arguments (most common after /play):**

- If `.prompts/.batch.json` exists and has incomplete prompts → execute the batch's DAG (preferred)
- Otherwise → fall back to the most recently created prompt (legacy single-prompt mode)
- If both are absent → report no prompts found

**Single prompt:**

- A prompt number (e.g., "001", "5", "42")
- A partial filename or folder name (e.g., "user-auth", "dashboard")

**Multiple prompts:**

- Multiple numbers (e.g., "005 006 007")
- With execution flag: "005 006 007 --parallel" or "005 006 007 --sequential"
- If no flag specified with multiple prompts, default to --sequential for safety
  </input>

<process>
<step1_parse_arguments>
Parse $ARGUMENTS to extract:
- Prompt numbers/names (all arguments that are not flags)
- Execution strategy flag (--parallel or --sequential)

<examples>
- (empty) → Detect `.batch.json`; if present and has incomplete prompts, dispatch DAG; else fall back to last-single
- "005" → Single prompt: 005
- "005 006 007" → Multiple prompts: [005, 006, 007], strategy: from .batch.json or sequential (default)
- "005 006 007 --parallel" → Multiple prompts: [005, 006, 007], strategy: parallel (explicit)
- "005 006 007 --sequential" → Multiple prompts: [005, 006, 007], strategy: sequential (explicit)
</examples>
</step1_parse_arguments>

<step1_5_check_batch_metadata>
If no explicit strategy flag provided, check for `.prompts/.batch.json`:

1. Read `.prompts/.batch.json` if it exists
2. Determine format type:
   - **Simple format**: Has `strategy` field → use as default execution strategy
   - **Execution groups format**: Has `execution` array → use layered execution
3. If not found, default to `sequential` for safety

**Entry format:** Prompts in the `prompts` and `completed` arrays are referenced by **basename** — either the folder name (subdirectory layout, e.g. `"001-auth-research"`) or the filename without/with `.md` (flat-file layout, e.g. `"005-feature"`). The resolver (`step2_resolve_files`) accepts all three forms. When writing back to `completed`, preserve the form that was used in `prompts`.

**Simple format (subdirectory layout, preferred):**
```json
{
  "created": "2025-01-02T10:30:00Z",
  "strategy": "sequential",
  "source": "/play #42",
  "prompts": ["001-setup-database", "002-create-api", "003-add-tests"],
  "completed": ["001-setup-database"]
}
```

**Execution groups format:**
```json
{
  "created": "2025-01-02T10:30:00Z",
  "source": "/play #42",
  "execution": [
    {"strategy": "parallel", "prompts": ["001-api-research", "002-db-research"]},
    {"strategy": "sequential", "prompts": ["003-architecture-plan"]},
    {"strategy": "parallel", "prompts": ["004-implement-api", "005-implement-db"]}
  ],
  "completed": ["001-api-research", "002-db-research"]
}
```
</step1_5_check_batch_metadata>

<step2_resolve_files>
**Empty / "last":** First check for `.prompts/.batch.json` per step1_5 (DAG dispatch path). Only if no batch exists, fall back to most-recent single prompt — search both layouts and prefer the more recent:
- Subdirectory: `ls -td .prompts/*/ 2>/dev/null | grep -v completed | head -1`
- Flat file: `ls -t .prompts/*.md 2>/dev/null | head -1`

**Number (e.g., "5", "42"):** Find a matching prompt across both layouts using the zero-padded prefix:
- Subdirectory match: `.prompts/005-*/` → inner file `.prompts/005-*/005-*.md`
- Flat-file match: `.prompts/005-*.md`

**Text (e.g., "user-auth"):** Same dual search by substring in folder/file name.

**Basename entry from .batch.json (e.g., "001-auth-research"):** Resolve to either the subdirectory's inner file or a flat `.md` of the same basename.

<matching_rules>
- If exactly one match found: Use that file
- If multiple matches found: List them and ask user to choose
- If no matches found: Report error and list available prompts
</matching_rules>
</step2_resolve_files>

<step3_execute>
<archiving_logic>
Before archiving, determine the prompt structure:
- **Flat file**: Prompt is directly in `.prompts/` (e.g., `.prompts/005-feature.md`)
  - Archive: Move file to `.prompts/completed/005-feature.md`
- **Subdirectory (pipeline)**: Prompt is in a subdirectory (e.g., `.prompts/001-auth-research/001-auth-research.md`)
  - Archive: Move entire subdirectory to `.prompts/completed/001-auth-research/`

Detection: If the prompt file's parent directory is NOT `.prompts/` itself, it's a pipeline subdirectory.
</archiving_logic>

<single_prompt>

1. Read the complete contents of the prompt file
2. Delegate as sub-task using Task tool with subagent_type="general-purpose"
3. Wait for completion
4. Ensure `.prompts/completed/` directory exists (use Bash tool: `mkdir -p .prompts/completed`)
5. Archive using appropriate method:
   - Flat file: `mv .prompts/005-feature.md .prompts/completed/`
   - Subdirectory: `mv .prompts/001-auth-research/ .prompts/completed/`
6. Update `.prompts/.batch.json` if it exists (add prompt filename to `completed` array)
7. Return results
   </single_prompt>

<parallel_execution>

1. Read all prompt files
2. **Spawn all Task tools in a SINGLE MESSAGE** (this is critical for parallel execution):
   <example>
   Use Task tool for prompt 005
   Use Task tool for prompt 006
   Use Task tool for prompt 007
   (All in one message with multiple tool calls)
   </example>
3. Wait for ALL to complete
4. Ensure `.prompts/completed/` directory exists (use Bash tool: `mkdir -p .prompts/completed`)
5. Archive all prompts using appropriate method for each (flat file vs subdirectory)
6. Update `.prompts/.batch.json` if it exists (add all prompt filenames to `completed` array)
7. Return consolidated results
   </parallel_execution>

<sequential_execution>

1. Ensure `.prompts/completed/` directory exists (use Bash tool: `mkdir -p .prompts/completed`)
2. For each prompt in order:
   a. Read prompt file
   b. Spawn Task tool for prompt
   c. Wait for completion
   d. Archive using appropriate method (flat file vs subdirectory)
   e. **Update `.prompts/.batch.json`** - add prompt filename to `completed` array
   f. If prompt failed, stop and report error (batch progress is preserved)
3. Return consolidated results
    </sequential_execution>

<execution_groups>
When `.batch.json` contains an `execution` array, execute layer by layer:

1. Ensure `.prompts/completed/` directory exists
2. Identify current layer (first layer with incomplete prompts)
3. For each layer in order:
   a. Get prompts in this layer that aren't in `completed` array
   b. If layer strategy is "parallel":
      - **Spawn all Task tools in a SINGLE MESSAGE**
      - Wait for ALL to complete
   c. If layer strategy is "sequential":
      - Execute prompts one at a time, waiting for each
   d. After each prompt completes:
      - Archive using appropriate method (flat file vs subdirectory)
      - Update `completed` array in `.batch.json`
   e. If any prompt fails, stop and report error (progress preserved)
   f. Once layer complete, proceed to next layer
4. Return consolidated results showing layer-by-layer progress

**Example execution flow for groups:**
```
Layer 1 [parallel]: 001-api-research, 002-db-research
  → Spawn both Task tools in single message
  → Wait for both to complete
  → Archive both, update completed array

Layer 2 [sequential]: 003-architecture-plan
  → Execute single prompt
  → Archive, update completed array

Layer 3 [parallel]: 004-implement-api, 005-implement-db
  → Spawn both Task tools in single message
  → Wait for both to complete
  → Archive both, update completed array
```
</execution_groups>

<batch_metadata_update>
When updating `.prompts/.batch.json`, read the current file, add the completed prompt's basename to the `completed` array, and write it back. Use the same form (folder name vs `.md` filename) as the corresponding entry in the `prompts` array — do not mix forms within one batch. This enables `/whats-next` to show accurate progress and resume from the correct point if interrupted.
</batch_metadata_update>
    </step3_execute>
    </process>

<context_strategy>
By delegating to a sub-task, the actual implementation work happens in fresh context while the main conversation stays lean for orchestration and iteration.
</context_strategy>

<output>
<single_prompt_flat_file>
✓ Executed: .prompts/005-implement-feature.md
✓ Archived to: .prompts/completed/005-implement-feature.md

<results>
[Summary of what the sub-task accomplished]
</results>
</single_prompt_flat_file>

<single_prompt_subdirectory>
✓ Executed: .prompts/001-auth-research/001-auth-research.md
✓ Archived directory to: .prompts/completed/001-auth-research/

<results>
[Summary of what the sub-task accomplished]
</results>
</single_prompt_subdirectory>

<parallel_output>
✓ Executed in PARALLEL:

- .prompts/005-implement-auth.md
- .prompts/006-implement-api.md
- .prompts/007-implement-ui.md

✓ All archived to .prompts/completed/

<results>
[Consolidated summary of all sub-task results]
</results>
</parallel_output>

<sequential_output>
✓ Executed SEQUENTIALLY:

1. .prompts/005-setup-database.md → Success
2. .prompts/006-create-migrations.md → Success
3. .prompts/007-seed-data.md → Success

✓ All archived to .prompts/completed/

<results>
[Consolidated summary showing progression through each step]
</results>
</sequential_output>

<layered_output_subdirectories>
✓ Executed in LAYERS:

Layer 1 [parallel]:
  ✓ .prompts/001-api-research/ → Success
  ✓ .prompts/002-db-research/ → Success

Layer 2 [sequential]:
  ✓ .prompts/003-architecture-plan/ → Success

Layer 3 [parallel]:
  ✓ .prompts/004-implement-api/ → Success
  ✓ .prompts/005-implement-db/ → Success

✓ All 5 prompt directories archived to .prompts/completed/

<results>
[Consolidated summary showing layer-by-layer results]
</results>
</layered_output_subdirectories>
</output>

<critical_notes>

- For parallel execution: ALL Task tool calls MUST be in a single message
- For sequential execution: Wait for each Task to complete before starting next
- For layered execution: Complete each layer before starting the next; within each layer, respect its strategy
- Archive prompts only after successful completion
- If any prompt fails, stop execution and report error (progress is preserved in `.batch.json`)
- Provide clear, consolidated results for multiple prompt execution
- **Batch metadata**: Update `.prompts/.batch.json` after each prompt completes to enable resume via `/whats-next`
- **Format detection**: Check for `execution` array (layered) vs `strategy` field (simple)
- **Strategy precedence**: Explicit flag (--parallel/--sequential) > .batch.json > sequential default
  - Note: Explicit flags override simple format only; execution groups always use their defined layers
  </critical_notes>
