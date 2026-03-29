---
name: audit-claudemd
description: Audit CLAUDE.md files for conciseness, stale references, clarity, scope, and effectiveness as Claude Code project instructions
argument-hint: <claudemd-path>
---

<objective>
Invoke the claudemd-auditor subagent to audit the CLAUDE.md file at $ARGUMENTS for conciseness, accuracy, and effectiveness.

This ensures CLAUDE.md files follow the Handyman Principle (context is scarce), contain accurate references, and provide clear, actionable project instructions.
</objective>

<process>
1. Invoke claudemd-auditor subagent
2. Pass CLAUDE.md path: $ARGUMENTS
3. Subagent will verify file/path references, assess conciseness, and evaluate clarity
4. Review detailed findings with file:line locations, reference accuracy, and recommendations
</process>

<success_criteria>
- Subagent invoked successfully
- Arguments passed correctly to subagent
</success_criteria>
