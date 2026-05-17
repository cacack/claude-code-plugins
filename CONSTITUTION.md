# Constitution

> The mission, principles, and non-goals of cacack/claude-code-plugins. When in conflict with this document, future decisions should align here or explicitly update it.

## Mission

A personal Claude Code plugin marketplace housing skills, subagents, and hooks that scaffold the maintainer's development workflows. The collection prioritizes focused, specialized resources that compose into agentic systems — small skills that do one thing well, externalizing context to files rather than assuming Claude remembers.

## Audience

**This is for:** Chris Clonch, the maintainer, as primary user; secondarily, other developers comfortable with Claude Code who treat this as a reference implementation for plugin patterns.

**This is not for:** beginners new to Claude Code, enterprise teams expecting supported tooling, or anyone who needs Anthropic-blessed canonical patterns (use `anthropics/claude-plugins-official` for that).

## Principles

When in doubt, prefer:

1. **Specialization over generalization** — small, focused skills/agents that do one thing well, over monolithic tools that try to handle everything.
2. **Skills as programs** — invoke real tools and produce verifiable output, rather than asking Claude to "think about it."
3. **External memory over implicit context** — externalize state to files (snapshots, drafts, reports); don't assume Claude carries context across turns or sessions.
4. **Iterate over perfecting** — ship simple solutions, evolve them with usage; over-engineering before observed need is the larger cost.
5. **Match official conventions where they exist; document where we differ** — Anthropic's patterns are the default; our additions (XML structure, verb-noun naming, etc.) are recommendations explicitly distinguished from requirements.

## Non-Goals

This project is explicitly **not** trying to:

- Become a commercial or supported product
- Serve as authoritative Claude Code documentation (Anthropic's docs are authoritative)
- Compete with or replace `anthropics/claude-plugins-official`
- Optimize for first-time Claude Code users
- Maintain backwards-compatibility shims for deprecated skill formats

## Success Criteria

We'll know this is working if:

- Skills in the collection get invoked by the maintainer with reasonable frequency
- New skills can be added in a session without restructuring existing ones
- All resources validate cleanly against `claude plugin validate`
- Marketplace stays coherent: one marketplace, one plugin, consistent conventions across resources
- The repo's CLAUDE.md stays under ~250 lines (context-scarcity discipline)

---

*Last refreshed: 2026-05-16*
