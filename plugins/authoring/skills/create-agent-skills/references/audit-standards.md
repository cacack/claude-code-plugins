<overview>
This reference documents the authoritative sources used for skill auditing standards, when they were last reviewed, and how to distinguish Anthropic **requirements** from this repo's **conventions**.

**Last comprehensive review**: 2026-06-25
**Next recommended review**: 2026-09-25 (quarterly cadence)
</overview>

<authoritative_sources>
**Anthropic official sources** (requirements — must follow):

1. **Skill authoring best practices** — https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
   - Conciseness, degrees of freedom, progressive disclosure, evaluation-driven development
   - Description field quality, naming conventions (gerund form recommended)
   - Anti-patterns, feedback loops, common patterns

2. **Claude Code skills documentation** — https://code.claude.com/docs/en/skills
   - Frontmatter reference (all supported fields)
   - String substitutions ($ARGUMENTS, ${CLAUDE_SKILL_DIR}, etc.)
   - context: fork, agent, disable-model-invocation, user-invocable, hooks
   - Discovery mechanics, context budget (2% of context window, 16K char fallback)

3. **Claude Code plugins documentation** — https://code.claude.com/docs/en/plugins
   - Plugin architecture, directory structure
   - How skills are packaged and distributed

4. **Anthropic skills repository** — https://github.com/anthropics/skills
   - Official example skills (use markdown headings, not XML)
   - Template and naming patterns; Agent Skills open standard (agentskills.io)

**This repo's conventions** (preferences — should follow):

5. **Repo CLAUDE.md** — `/CLAUDE.md` and the "Important Distinction" note therein
   - Confirms the XML structure / required-tags / verb-noun conventions below are *this repo's recommendations*, not Anthropic requirements

6. **create-agent-skills references** — this skill's `references/` directory
   - XML structure preference (repo convention)
   - Required XML tags: objective, quick_start, success_criteria (repo convention)
   - Progressive disclosure patterns

7. **Handyman Principle** — [`../../../docs/handyman-principle.md`](../../../docs/handyman-principle.md)
   - Context is scarce; favor focused, specialized skills over kitchen-sink ones
</authoritative_sources>

<requirements_vs_conventions>
**Anthropic requirements** (flag as critical when violated):
- YAML name: max 64 chars, lowercase-with-hyphens, no reserved words
- YAML description: max 1024 chars, non-empty, no XML tags, third person
- Progressive disclosure: SKILL.md < 500 lines
- One-level-deep references
- Forward-slash paths (not backslash)
- Consistent terminology
- MCP tool fully-qualified references (ServerName:tool_name)

**Repo conventions** (flag as recommendations when violated):
- Pure XML body structure (Anthropic's own skills use markdown headings)
- Required XML tags: objective, quick_start, success_criteria
- Verb-noun naming (Anthropic recommends gerund form)
- Constraint strength (MUST/NEVER/ALWAYS)

**Shared alignment** (both agree):
- Conciseness (only add what Claude doesn't already know)
- Description quality (what it does AND when to use it)
- Third-person descriptions
- Degrees of freedom matching the task
- Testing across models
- allowed-tools for least privilege
</requirements_vs_conventions>

<review_cadence>
**Quarterly review process**:

1. Fetch the latest from every authoritative source listed above
2. Compare against current auditor rules and reference files
3. Document any changes found in this file's change log
4. Update the auditor agents and reference files as needed
5. Bump the plugin version (both `plugin.json` and `marketplace.json`)

**What to look for**:
- New frontmatter fields added to Claude Code
- Changes to YAML validation rules
- New best practices or anti-patterns
- Deprecations or removed features
- Changes to context budget or discovery mechanics
- New string substitutions or features
</review_cadence>

<change_log>
**2026-06-25 — Imported into the cacack plugin**
Ported from the team-plugins `create-agent-skills` skill during a cross-repo comparison, adapted to this repo's conventions (the XML/required-tags/verb-noun stance is documented as *this repo's recommendation* in CLAUDE.md, not an Anthropic requirement). Replaced team-specific source paths with this repo's CLAUDE.md, references, and the Handyman Principle doc.

Standing facts captured from the most recent authoritative review:
- XML structure is a repo convention, not an Anthropic requirement (Anthropic's own skills use markdown headings)
- Gerund naming convention is recommended by Anthropic (processing-pdfs vs process-pdfs); this repo's verb-noun naming is an accepted alternative
- Description budget: 2% of the context window, 16K-character fallback
- MCP tools should use fully-qualified ServerName:tool_name references
- Skills follow the Agent Skills open standard (agentskills.io)
- Hooks span ~30 events across 4 handler types (command, prompt, http, agent); see `create-hooks`
- Subagent modern frontmatter (disallowedTools, permissionMode, maxTurns, skills, memory, background, isolation, mcpServers, hooks); plugin agents silently ignore hooks/mcpServers/permissionMode — see `create-subagents`
</change_log>
