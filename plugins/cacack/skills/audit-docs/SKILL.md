---
name: audit-docs
description: Audit project documentation for dead links, orphaned files, drift/staleness, and duplicated facts (DRY). Use when checking docs for broken cross-references, unreachable files, stale content, or knowledge repeated instead of linked. For document types, placement, and formatting use documentation-standards instead; for code-change-driven doc updates use docs-analyzer.
argument-hint: [path]
allowed-tools: Task
---

<objective>
Invoke the docs-auditor subagent to audit the documentation at $ARGUMENTS — a file, a directory, or the whole repo — for drift and linkage health.

This is the runtime enforcement of the `documentation-standards` "single source of truth / link, don't duplicate" discipline: it verifies cross-references resolve, every doc is reachable, content still matches reality, and facts live in one home rather than being copied. Structure, placement, and formatting are NOT its job — those belong to `/cacack:documentation-standards`.
</objective>

<process>
1. Invoke the docs-auditor subagent
2. Pass the target path: $ARGUMENTS. A file or directory scopes the audit to that target; empty audits the whole documentation surface (root markdown + any `docs/` tree + `.claude/`)
3. Subagent inventories the docs in scope, builds the link graph, resolves relative links, computes reachability, samples for drift against the current date, and scans for duplicated facts
4. Review detailed findings with file:line locations, severity, and concrete fixes
</process>

<success_criteria>
- Subagent invoked successfully
- Arguments passed correctly to subagent (empty defaults to repo-wide)
- Audit covers dead links, orphans, drift/staleness, and duplicated facts
- Structure/placement/formatting deferred to documentation-standards
</success_criteria>
