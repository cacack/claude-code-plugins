# Meta-Prompting Plugin

Create optimized prompts for Claude-to-Claude pipelines with improved dependency detection and structured outputs.

This plugin is ported from [TÂCHES Claude Code Resources](https://github.com/glittercowboy/taches-cc-resources).

## The Problem

Complex tasks benefit from staged workflows: research first, then plan, then implement. But manually crafting prompts that produce structured outputs for subsequent prompts is tedious. Each stage needs metadata (confidence, dependencies, open questions) that the next stage can parse.

## The Solution

The meta-prompting system separates analysis from execution. Describe what you want in natural language, Claude generates a rigorous prompt, then runs it in a fresh sub-agent context. It enables staged workflows with structured outputs (research.md, plan.md) that subsequent prompts can parse, plus automatic dependency detection for chaining research → plan → implement sequences.

## Commands

### `/create-meta-prompt [description]`

Describe your task. Claude creates a prompt optimized for its purpose.

**What it does:**
1. Determines purpose: Do (execute), Plan (strategize), or Research (gather info)
2. Detects existing research/plan files to chain from
3. Creates prompt with purpose-specific structure
4. Saves to `.prompts/{number}-{topic}-{purpose}/`
5. Runs with dependency-aware execution

**Usage:**
```bash
# Research task
/create-meta-prompt research authentication options for the app

# Planning task
/create-meta-prompt plan the auth implementation approach

# Implementation task
/create-meta-prompt implement JWT authentication
```

### `/run-prompt [prompt-number(s)-or-name] [--parallel|--sequential]`

Delegate one or more prompts from `./prompts/` to fresh sub-task contexts.

**Usage:**
```bash
# Run most recent prompt
/run-prompt

# Run specific prompt
/run-prompt 005

# Run multiple prompts sequentially (default)
/run-prompt 005 006 007

# Run multiple prompts in parallel
/run-prompt 005 006 007 --parallel
```

## Example Workflow

**Full research → plan → implement chain:**

```bash
# Step 1: Research
/create-meta-prompt research authentication libraries for Node.js
# Claude asks clarifying questions, creates and runs research prompt
# Output: .prompts/001-auth-research/auth-research.md

# Step 2: Plan
/create-meta-prompt plan the auth implementation
# Claude detects existing research, references it in the plan
# Output: .prompts/002-auth-plan/auth-plan.md

# Step 3: Implement
/create-meta-prompt implement the auth system
# Claude detects plan, follows it for implementation
# Implementation complete
```

## File Structure

```
meta-prompting/
├── plugin.json
├── README.md
├── commands/
│   ├── create-meta-prompt.md
│   └── run-prompt.md
└── skills/
    └── create-meta-prompts/
        ├── SKILL.md
        └── references/
            ├── do-patterns.md
            ├── plan-patterns.md
            ├── research-patterns.md
            ├── question-bank.md
            └── intelligence-rules.md
```

**Generated prompts structure:**
```
.prompts/
├── 001-auth-research/
│   ├── completed/
│   │   └── 001-auth-research.md    # Prompt (archived after run)
│   └── auth-research.md            # Output
├── 002-auth-plan/
│   ├── completed/
│   │   └── 002-auth-plan.md
│   └── auth-plan.md
└── 003-auth-implement/
    └── 003-auth-implement.md       # Prompt
```

## Why This Works

**Structured outputs for chaining:**
- Research and plan outputs include XML metadata
- `<confidence>`, `<dependencies>`, `<open_questions>`, `<assumptions>`
- Subsequent prompts can parse and act on this structure

**Automatic dependency detection:**
- Scans for existing research/plan files
- Suggests relevant files to chain from
- Executes in correct order (sequential/parallel/mixed)

**Clear provenance:**
- Each prompt gets its own folder
- Outputs stay with their prompts
- Completed prompts archived separately

## Credits

Original work by TÂCHES: https://github.com/glittercowboy/taches-cc-resources
