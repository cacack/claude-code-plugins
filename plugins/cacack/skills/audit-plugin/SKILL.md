---
name: audit-plugin
description: Audit plugin structure for directory layout, plugin.json/marketplace.json validity, version sync, and resource integrity
argument-hint: <plugin-directory-path>
---

<objective>
Invoke the plugin-auditor subagent to audit the plugin at $ARGUMENTS for structural correctness, metadata validity, version synchronization, and resource integrity.

This ensures plugins follow the official Claude Code plugin architecture with correct directory layout, valid metadata files, and properly discoverable resources.
</objective>

<process>
1. Invoke plugin-auditor subagent
2. Pass plugin directory path: $ARGUMENTS
3. Subagent will validate structure, metadata, versions, and resources
4. Review detailed findings with file:line locations, resource summary, and recommendations
</process>

<success_criteria>
- Subagent invoked successfully
- Arguments passed correctly to subagent
</success_criteria>
