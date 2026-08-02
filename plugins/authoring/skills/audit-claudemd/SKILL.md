---
name: audit-claudemd
description: Audit CLAUDE.md or .claude/rules/ files for conciseness, stale references, clarity, scope, path-scoping, and effectiveness as Claude Code project instructions. For CREATING or migrating these files, use create-claudemd instead.
argument-hint: <claudemd-or-rules-path>
allowed-tools: Task
---

<objective>
Invoke the claudemd-auditor subagent to audit the file or directory at $ARGUMENTS — a CLAUDE.md file, a `.claude/rules/` file, or a `.claude/rules/` directory — for conciseness, accuracy, and effectiveness.

This ensures these files follow the Handyman Principle (context is scarce), contain accurate references, apply path-scoping appropriately, and provide clear, actionable project instructions. (To author or migrate these files rather than audit them, use `/authoring:create-claudemd`.)
</objective>

<process>
1. Invoke claudemd-auditor subagent
2. Pass the target path: $ARGUMENTS (CLAUDE.md file, rules file, or rules directory)
3. Subagent verifies file/path references, assesses conciseness, evaluates clarity, and — for rules files — checks path-scoping, per-file focus, and overlap
4. Review detailed findings with file:line locations, reference accuracy, and recommendations
</process>

<success_criteria>
- Subagent invoked successfully
- Arguments passed correctly to subagent
</success_criteria>
