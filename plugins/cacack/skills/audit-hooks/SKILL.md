---
name: audit-hooks
description: Audit hooks.json configuration for correctness, security, event types, matchers, and best practices
argument-hint: <hooks-json-path>
---

<objective>
Invoke the hooks-auditor subagent to audit the hooks configuration at $ARGUMENTS for correctness, security, and best practices compliance.

This ensures hook configurations use valid event types, proper matchers, safe execution patterns, and appropriate blocking behavior.
</objective>

<process>
1. Invoke hooks-auditor subagent
2. Pass hooks.json path: $ARGUMENTS
3. Subagent will read hook best practices and evaluate the configuration
4. Review detailed findings with file:line locations, security assessment, and recommendations
</process>

<success_criteria>
- Subagent invoked successfully
- Arguments passed correctly to subagent
</success_criteria>
