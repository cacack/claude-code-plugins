---
name: audit-prompt
description: Review prompt files for clarity, structure, and effectiveness with constructive suggestions rather than strict compliance checks
argument-hint: <prompt-path>
allowed-tools: Task
---

<objective>
Invoke the prompt-auditor subagent to review the prompt at $ARGUMENTS for clarity, structure, and effectiveness.

Unlike other auditors, this provides constructive suggestions rather than compliance checks. It acts as a peer reviewer to help make prompts more likely to produce good results.
</objective>

<process>
1. Invoke prompt-auditor subagent
2. Pass prompt path: $ARGUMENTS
3. Subagent will review against prompt construction best practices
4. Review suggestions with file:line locations, broken reference checks, and improvement opportunities
</process>

<success_criteria>
- Subagent invoked successfully
- Arguments passed correctly to subagent
</success_criteria>
