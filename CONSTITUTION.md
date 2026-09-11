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

Each criterion names the check that settles it. Run them all:

```bash
make constitution-check
```

**C1 — The collection stays in use.**
*Judgement call, reported but not scored.* Invocation frequency lives in the
maintainer's local Claude Code history, not in this repository, and every in-repo
proxy for it is dishonest — a stable skill needs no commits. The check reports how
many skills have had no commit in 365 days as supporting evidence; the ruling is
made at each refresh. A criterion that cannot be mechanised is allowed to say so
rather than be forced into a false metric.

**C2 — A new skill can be added without restructuring existing ones.**
No skill added in the last 90 days changed more than **20 lines** of any existing
file outside its own directory, excluding the shared registry files every addition
must touch (`README.md`, `marketplace.json`, the owning `plugin.json`). Edits under
that line are cross-references, which are healthy; above it is rework, which is the
coupling this criterion exists to catch. The 20 is a judgement — move it here, in
the open, rather than in the script.

**C3 — Every resource validates cleanly.**
`claude plugin validate` exits clean for every plugin, with **zero warnings**. A
tolerated warning trains everyone to ignore warnings, which is how a real one hides.

**C4 — The marketplace stays coherent.**
Three things hold: every directory under `plugins/` is registered in
`marketplace.json` and every entry resolves to a directory; each plugin's version
matches its marketplace entry; and no plugin hard-dispatches another plugin's agent
(CLAUDE.md structure rule 7 — cross-plugin references stay descriptive).

*Replaces "one marketplace, one plugin", which the five-plugin split (`a8540c8`)
made false. Coherence in a multi-plugin marketplace is about boundaries holding,
not about there being one of everything.*

**C5 — CLAUDE.md stays within its line ceiling.**
`wc -l CLAUDE.md` is **250 or fewer**. Context is scarce; the entry point is the
file that costs every session.

---

*Last refreshed: 2026-05-16. Success Criteria rewritten as executable checks
2026-09-11, after the first `panel-product` run found two of them false — one of
which had been false since the day this document was written, because nothing
verified it. If a criterion here cannot be settled by a command, it says so.*
