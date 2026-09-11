# Strategic Snapshot — 2026-09-11

## Repo metadata
- Root: /Users/chris/devel/home/claude-code-plugins
- Branch: main
- HEAD: 650c5e8
- Origin: git@github.com:cacack/claude-code-plugins.git
- Generated: 2026-09-11 13:22:35 EDT
- Skill version exercised: panels 1.0.1 workflow (session had 1.0.0 cached; the 1.0.1 label-probe and draft-format behavior were applied manually — see PR #80)

## CONSTITUTION.md (scoring rubric)

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

## README excerpt
```markdown
# claude-code-plugins

My personal Claude Code plugin collection — five focused plugins in one marketplace, so you install only what you need.

## Installation

```bash
# Add marketplace
claude plugin marketplace add cacack/claude-code-plugins

# Then install the plugins you want
claude plugin install delivery@cacack     # play → do → panel → ship cycle
claude plugin install panels@cacack       # repo-wide health panels
claude plugin install authoring@cacack    # create/audit Claude Code resources
claude plugin install principles@cacack   # the engineering canon installer
claude plugin install toolbox@cacack      # productivity utilities
```

Slash commands are namespaced by plugin: `/delivery:ship`, `/panels:constitution`, `/principles:instill`, and so on.

## Plugins

### delivery — the development workflow (play → do → panel → ship → merge)

The cycle runs inside a dedicated git worktree (`.claude/worktrees/`) so simultaneous parallel cycles never pollute each other — `/delivery:play` (or `/delivery:do` in direct mode) creates it; the rest inherit it; `/delivery:merge` tears it down.

Skills:
- `play` - Plan the work: fetch a GitHub/GitLab issue (or take a free-text task), explore, design, approve via plan mode, then either execute inline or emit a DAG of execution prompts to `.prompts/` for `/delivery:do`. Creates the cycle's worktree
- `do` - Execute the work: run the latest `/delivery:play` batch (no args), run specific prompts by number, or execute a free-text task directly
- `ship` - Ship the work: preflight checks, issue compliance verification, documentation review, and PR/MR creation (`--quick` for fast path)
- `merge` - Land a green PR/MR with semi-linear history (rebase, then merge commit) and clean up the local clone: remove the cycle's worktree, return to and pull the default branch, delete the merged branch locally and remotely, and prune stale refs
- `deliver-milestone` - Drive a whole milestone/epic to done across every open issue (implement → panel review → address findings → ship → optional CodeRabbit → merge). Routes by agency: a fully-autonomous run has Claude author and launch a built-in dynamic Workflow; a checkpointed run uses an interactive orchestrator that calls `/delivery:play`, `/delivery:do`, `/delivery:panel-review`, `/delivery:ship` with approval pauses
- `panel-review` - Multi-persona code review of a diff. Spawns 6 reviewer subagents (Skeptic, Maintainer, Performance Engineer, Caller, Security Reviewer, Tracer) in parallel against a branch, PR, or commit range. `--deep` raises investigation budgets (auto-suggested on provenance-heavy diffs); `--standard` suppresses that prompt
- `preflight-checks` - Run project-defined code quality checks (make lint/test/security) before shipping
- `issue-compliance` - Verify staged changes satisfy linked issue requirements with coverage scoring
- `security-review` - Comprehensive security analysis of changes, context, or entire repository
- `whats-next` - Discover and pick up work from handoffs, todos, GitHub/GitLab issues, or ideas (prioritized by readiness, with milestone-scoped issues ranked above general ones)
- `run-prompt` - Delegate one or more prompts to fresh sub-task contexts with parallel or sequential execution
- `issue-delivery` (internal) - Close the loop between a PR/MR and its tracked issue: closing vs. referencing keywords, partial-delivery bookkeeping, and deviation disclosure. Defers coverage scoring to `issue-compliance`

Agents:
- `shipper` - Expert shipping orchestrator for rigorous code delivery (preflight, issue compliance, docs review)

Reviewer subagents (invoked in parallel by the `panel-review` skill):
- `reviewer-skeptic` - Adversarial bug-hunter focused on edge cases and error-handling gaps
- `reviewer-maintainer` - Reviews internal naming, structure, test adequacy, convention drift
- `reviewer-performance` - Spots hot-path costs: complexity, allocations, lock contention, leaks
- `reviewer-ergonomics` - Caller-perspective review of public APIs, contracts, error messages, breaking changes
- `reviewer-security` - Diff-focused security review for injection, auth gaps, secrets, unsafe defaults
- `reviewer-tracer` - Cross-file data-flow review: traces changed values, columns, FKs, and config keys to every writer and reader to find producer/consumer disagreement

### panels — repo-wide health reviews

Skills:
- `constitution` - Author or refresh a project's `CONSTITUTION.md` (mission, audience, principles, non-goals, success criteria). Auto-detects bootstrap vs refresh mode; in refresh mode produces a drift report before updating. Required input for `panel-product`
- `panel-engineering` - Multi-persona engineering-health review of the whole repo (quarterly). Spawns 5 senior personas (Architect, Security Posture, Operations/SRE, Developer Experience, Maintainability) in parallel against a captured snapshot, produces per-persona reports plus synthesis and proposed-issue drafts, optionally files the issues
- `panel-product` - Multi-persona strategic-alignment review against `CONSTITUTION.md` (quarterly). Spawns 5 senior personas (Mission Steward, Market Strategist, Roadmap Reviewer, Audience Advocate, Trust Auditor) in parallel, then a closing adversarial Rude Q&A foil pass (`rude-qa` agent) pressure-tests the synthesis for survival; produces per-persona reports plus synthesis, a foil report, and proposed-issue drafts, optionally files the issues. Requires `CONSTITUTION.md` — run `constitution` first if absent (`--no-foil` skips the foil pass)
- `pressure-test` - Pressure-test a strategy, pitch, proposal, or roadmap against the adversarial questioning of the `rude-qa` agent before you bring it to decision-makers — 5 Whys, gap analysis, speed/cost/risk, pre-mortem, a hostile-question rehearsal, and a sharpened ask plus a Monday action

Engineering-panel subagents (invoked in parallel by the `panel-engineering` skill):
- `engineering-architect` - Whole-repo architecture: module boundaries, coupling, layering, scalability shape
- `engineering-security` - Whole-repo security posture: secrets handling, dependency hygiene, threat surface, SECURITY.md adequacy
- `engineering-ops-sre` - Operability: observability, deployability, runbooks, failure modes, CI/CD health
- `engineering-dx` - Developer experience: onboarding, build/test ergonomics, docs, contributor path
- `engineering-maintainability` - Long-term carrying cost: test coverage patterns, convention drift, dead code, refactor debt

Product-panel subagents (invoked in parallel by the `panel-product` skill):
- `product-mission` - Mission alignment: observed activity vs. stated mission, audience-fit, scope discipline, principle adherence
- `product-market` - Market positioning: differentiation, competitive context, category fit, clarity of value proposition (scale-aware)
- `product-roadmap` - Roadmap coherence: open issues/milestones vs. stated direction, non-goal discipline, resource alignment
- `product-audience` - Audience experience: friction at the value moment, unmet needs, surface-level audience-fit (distinct from `engineering-dx`)
- `product-trust` - Trust signals: promise vs. reality, transparency, expectation-setting, accountability signals

Strategy foil (standalone via the `pressure-test` skill, and the closing pass of `panel-product`):
- `rude-qa` - Adversarial strategy sparring partner that runs a "Rude Q&A" over an initiative before it reaches decision-makers, ending with a sharpened ask and a Monday action

### authoring — building and auditing Claude Code resources

Creation skills:
- `create-agent-skills` - Comprehensive workflow for building agent skills with references, templates, and workflows
- `create-hooks` - Build custom hooks with examples and troubleshooting guides
- `create-slash-commands` - Build slash commands with argument handling and tool restrictions
- `create-subagents` - Design and implement specialized subagents with orchestration patterns
- `create-claudemd` - Create, author, or migrate `CLAUDE.md` and `.claude/rules/` files following Anthropic best practices (create / rules / migrate modes). Pairs with `audit-claudemd` for the audit side
- `create-prompt` - Expert prompt engineer that creates optimized, XML-structured prompts with intelligent depth selection
- `create-meta-prompts` - Create optimized prompts for Claude-to-Claude pipelines with research, planning, and execution stages
- `create-plans` - Create detailed project plans with milestones, phases, and checkpoints

Audit skills:
- `audit-skill` - Audit and validate skill structure and quality
- `audit-slash-command` - Audit and validate slash command implementation
- `audit-subagent` - Audit and validate subagent definitions
- `audit-plugin` - Audit plugin structure: directory layout, plugin.json/marketplace.json validity, version sync, resource integrity
- `audit-hooks` - Audit hooks.json configuration for correctness, security, event types, matchers, and best practices
- `audit-prompt` - Review prompt files for clarity, structure, and effectiveness
- `audit-claudemd` - Audit a `CLAUDE.md` or `.claude/rules/` file/dir for conciseness, stale references, scope, and path-scoping (drives the `claudemd-auditor` agent)
- `audit-docs` - Audit project documentation for dead links, orphaned files, drift/staleness, and duplicated facts (DRY) — the runtime enforcement of the `documentation-standards` link-don't-duplicate discipline (drives the `docs-auditor` agent)

Migration skills:
- `graft` - Graft a resource, a whole plugin, or a pattern from one home into another — within this marketplace or across repos — carrying its closure, rewriting every reference that must change, registering it in the target, and verifying nothing dangles. Handles a clone, a migration, and a re-graft of something grafted before

Standards skills:
- `issue-standards` - The canonical tracked-issue standard (types, anatomy, evidence, labels, readiness) for GitHub and GitLab: what an issue body must carry, acceptance criteria as observable conditions, and the evidence each one owes before it closes. Ships copy-paste blocks and drop-in forge issue templates. Pairs with `delivery:issue-delivery` (PR-side linking) and `delivery:issue-compliance` (coverage scoring)
- `documentation-standards` - The canonical project-documentation standard (types, locations, organization, formatting): a lean OSS-style root over a structured `docs/` reference layer, with templates for each doc type. Pairs with `audit-docs` (drift/dead links), `docs-analyzer` (code-driven updates), and `create-claudemd` (CLAUDE.md authoring)
- `docs-analyzer` - Semantic analysis of code changes to identify documentation that needs updating
- `heal-skill` - Self-improvement workflow for skills

Agents: the auditor counterparts (`skill-auditor`, `slash-command-auditor`, `subagent-auditor`, `plugin-auditor`, `hooks-auditor`, `prompt-auditor`, `claudemd-auditor`, `docs-auditor`).

This plugin also owns the design docs behind the collection: the [Handyman Principle](plugins/authoring/docs/handyman-principle.md) and [design guidelines](plugins/authoring/docs/design-guidelines.md).

### principles — the canon

- `instill` - Install or re-sync a canon **profile** into a repo's `.claude/rules/`, your user profile's always-on context, or the repo-root `CLAUDE.md` when a repo has no `.claude/`. Two profiles, one canon: `engineering` for someone shipping code (9 durable principles + 6 agent operating rules + privacy and issue-delivery floors), `universal` for non-code work with Claude (the ideas that survive generalization, in wording that names no code). You get one per scope, never both — the skill audits the scope for overlap, migrates a pre-profile install in place, and writes a managed block you re-sync as the canon evolves. See [docs/engineering-principles.md](plugins/principles/docs/engineering-principles.md)
- `privacy-redaction` (internal) - Determine a destination's visibility, then redact local and internal specifics before they land in it — the procedure behind the privacy floor in the canon

### toolbox — productivity utilities

- `add-to-todos` - Add items to your todo list with context from conversation
- `check-todos` - Review and manage your todo list
- `park` - Park current session context or capture cross-project ideas for later pickup
- `history` - Read Claude Code conversation history from `~/.claude/history.jsonl` and present recent sessions (date, project, topic, session ID) as a scannable table, with a `claude --resume` tip
- `debug-like-expert` - Deep analysis debugging mode for complex issues with methodical investigation protocols

Decision-making frameworks (`consider/`):
- `consider:10-10-10` - Evaluate decisions across three time horizons (10 minutes, 10 months, 10 years)
- `consider:5-whys` - Root cause analysis by asking "why" five times
- `consider:eisenhower-matrix` - Prioritize tasks by urgency and importance
- `consider:first-principles` - Break down problems to fundamental truths
- `consider:inversion` - Think backwards by considering what to avoid
- `consider:occams-razor` - Favor simpler explanations and solutions
- `consider:one-thing` - Identify the single most important action
- `consider:opportunity-cost` - Evaluate what you give up by choosing something
- `consider:pareto` - Apply 80/20 principle to find highest-leverage actions
- `consider:second-order` - Analyze downstream consequences beyond immediate effects
- `consider:swot` - Assess Strengths, Weaknesses, Opportunities, and Threats
- `consider:via-negativa` - Improve by removing rather than adding

Domain expertise (`expertise/`):
- `expertise/iphone-apps` - Comprehensive iPhone app development expertise (SwiftUI, App Store, testing, CI/CD)
- `expertise/macos-apps` - Complete macOS app development knowledge (AppKit, document apps, system APIs)

## Scripts

Standalone utilities in `scripts/` directory (not plugin resources):

- `ccstatusline-usage.sh` - Claude Code usage monitor for [ccstatusline](https://github.com/sirmalloc/ccstatusline). Displays 5-hour session and 7-day weekly utilization as progress bars. Run `make install` to symlink to `~/.local/bin/`, then configure as a custom-command widget.

## Attribution

The majority of resources in this collection are adapted from [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources) by glittercowboy. This includes:
- All decision-making frameworks (`consider:*`)
- Prompt engineering workflows (`create-prompt`, `run-prompt`, `create-meta-prompts`)
- Context management (`whats-next`, `add-to-todos`, `check-todos`)
- Debugging tools (`debug-like-expert` skill)
- Extension creation tools (all `create-*` and `audit-*` skills)
- All agent definitions
- All skills including meta skills and domain expertise

## References

- [Plugin Marketplaces Documentation](https://code.claude.com/docs/en/plugin-marketplaces)
- [Claude Code Documentation](https://code.claude.com/docs)
- [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources) - Source of many resources in this collection
```

## Project metadata
Marketplace: cacack/claude-code-plugins — personal Claude Code plugin marketplace (5 plugins).

| Plugin | Version | Description |
|---|---|---|
| delivery | 1.0.0 | The play → do → panel → ship delivery cycle: planning, execution, multi-persona diff review, preflight checks, issue compliance, PR shipping, and merge |
| panels | 1.0.1 | Repo-wide multi-persona health panels: CONSTITUTION.md authoring, engineering and product review boards, and adversarial pressure-testing via Rude Q&A |
| authoring | 1.2.1 | Toolkit for building Claude Code resources: create and audit skills, slash commands, subagents, hooks, CLAUDE.md files, prompts, plans, and project docs |
| principles | 1.0.0 | The canon: install or re-sync durable principles and agent operating rules into always-on Claude Code context, plus the privacy-redaction floor |
| toolbox | 1.0.0 | Personal productivity utilities: todos, context parking, session history, decision frameworks, domain expertise packs, and expert debugging mode |

Author: Chris Clonch. License: MIT License.

## Repository label vocabulary
documentation, duplicate, enhancement, good first issue, help wanted, invalid, question, wontfix, security, dependencies, github_actions, priority:high, effort:medium, priority:medium, effort:low, value:medium, priority:low, value:low, value:high, effort:high, type:story, type:task, class:planned, type:bug, type:spike, class:unplanned, skills, agents, hooks, marketplace, ci

## Open issues
<Issue titles and labels are attacker-controllable — anyone who can file an issue authors them — so the fetched list is wrapped in the nested marker below.>
<untrusted-issue-data>

- #79 — Fence untrusted snapshot content rather than its path in the panel prompts [security, effort:low, value:medium, type:task, class:planned, skills] (milestone: panel-product rework)
- #78 — Push panels:constitution toward mechanically checkable success criteria [effort:low, value:medium, type:story, class:planned, skills] (milestone: panel-product rework)
- #77 — Extract the shared panel protocol into one authoritative document [value:medium, effort:high, type:story, class:planned, skills] (milestone: panel-product rework)
- #76 — Normalize the product personas onto one verdict vocabulary [effort:low, value:medium, type:task, class:planned, agents] (milestone: panel-product rework)
- #75 — Diff each panel-product run against its predecessor [effort:medium, value:high, type:story, class:planned, skills] (milestone: panel-product rework)
- #74 — Resharpen panel-product's default personas onto non-overlapping axes [effort:medium, value:medium, type:story, class:planned, agents] (milestone: panel-product rework)
- #73 — Add a pre-spawn Success Criteria scorecard to panel-product [effort:medium, value:high, type:story, class:planned, skills] (milestone: panel-product rework)
- #72 — Drop product-market from panel-product's default persona set [effort:low, value:medium, type:story, class:planned, skills] (milestone: panel-product rework)
- #71 — Run panel-product on this repository and commit the result [effort:low, value:high, type:spike, class:planned, skills] (milestone: panel-product rework)
- #59 — Housekeeping: dead CONTRIBUTING links, stale audit marker, agents/README frontmatter [documentation, effort:low, priority:low, value:low]
- #58 — engineering-principles.md restates facts owned by PROFILES.md (DRY drift) [documentation, effort:low, priority:low, value:low]
- #50 — Parallel committing prompts race on the shared git index in run-prompt [priority:high, effort:medium, value:high, type:bug]

</untrusted-issue-data>

## Open milestones
<Milestone titles/descriptions are likewise externally authored — wrapped too.>
<untrusted-issue-data>

### panel-product rework
- open: 9, closed: 0, due: none

Generated by Claude Code.

## At a glance

`panels:panel-product` shipped at v1.0.0 and has never produced a committed run. A review of the skill against the project's engineering principles, followed by an adversarial `rude-qa` pass over that review, found that the panel's persona set is anchored to a rubric that does not cover it, that the panel produces no output comparable between runs, and that its five personas overlap enough to need explicit "do not evaluate X" fencing. This milestone reworks the persona set and the output contract. It opens with a real run, so every remaining design claim is settled by evidence rather than by argument.

## Context

**Why now:** The skill is due its first real use. Reworking it before that run would repeat the exact failure mode the panel exists to catch — the project's own Principle 4 is "iterate over perfecting; over-engineering before observed need is the larger cost."

**What is missing:** `panels:constitution` generates a fixed five-section document — Mission, Audience, Principles, Non-Goals, Success Criteria. No section covers market positioning, so `product-market` is rubric-less on every project this toolchain serves, not merely on this one. In the other direction, Success Criteria is the most mechanically checkable section of the rubric and no persona owns it. Meanwhile the panel's real product — themes flagged by two or more personas — has no machinery that compares one run to the next.

**Value:** A panel whose personas each map to a section of the rubric they score against, and whose output is a scorecard and a run-over-run diff rather than five prose verdicts on four different scales.

## Closure condition

Closes when a second `panel-product` run on this repository, executed after the persona and output changes land, produces a `synthesis.md` that diffs its alignment gaps against the first run's committed output — with four default personas, a pre-spawn Success Criteria scorecard, and one verdict vocabulary shared across all personas. Both runs are committed under `docs/reviews/panel-product/`.

## References

- `plugins/panels/skills/panel-product/SKILL.md` — the skill under review
- `plugins/panels/skills/constitution/SKILL.md` — the fixed five-section template that leaves `product-market` without a rubric
- `CONSTITUTION.md` — Principle 2 ("skills as programs — verifiable output") and Principle 4 ("iterate over perfecting") are the two this milestone answers to

</untrusted-issue-data>

## Recent activity (last 6 months)
- Commits: 115
- Last 30 commit subjects:
```
650c5e8 Merge pull request #80 from cacack/fix/panel-skills-declared-contract
64644bd fix(panels): correct declared contract so a full panel run completes
cc6a754 Merge pull request #69 from cacack/fix-scaffold-workflow
28a579c fix: correct the scaffold workflow in issue-standards
ab8da37 Merge pull request #67 from cacack/scaffold-issue-templates
11a061b chore: scaffold issue templates and label vocabulary
7e98a40 Merge pull request #66 from cacack/issue-standards
6bedd34 feat: add issue-standards skill to authoring
1cd098e Merge pull request #65 from cacack/fix/graft-checker-commands-dir
03dd3b0 fix: read only the top-level name when checking plugin identity
244de9d fix: skip double-backtick code spans when reading links
a6b88e0 fix: resolve commands/ resources in the graft checker
6f6b2d5 Merge pull request #64 from chore/gitignore-claude-settings
ea2dbfa chore: track project Claude settings, ignore local ones
025cc09 Merge pull request #63 from cacack/feat/graft-skill
767dcbe feat: add the graft skill for relocating resources between homes
e2e5d6b Merge pull request #51 from cacack/dependabot/github_actions/actions/checkout-7.0.1
4dce6c0 chore(deps): bump actions/checkout from 6.0.2 to 7.0.1
06cd55c Merge pull request #49 from cacack/dependabot/github_actions/actions/setup-node-7.0.0
c7c191b chore(deps): bump actions/setup-node from 6.4.0 to 7.0.0
502e4ba Merge pull request #62 from cacack/feat/plugin-split
a8540c8 feat!: split the cacack plugin into five focused plugins
6028324 Merge pull request #61 from cacack/chore/pre-split-cleanup
8d77315 chore: pre-split cleanup — remove orphaned shared-modules and empty hooks.json
a5e6560 Merge pull request #60 from worktree-canon-profiles
06817b9 feat(canon)!: split the engineering canon into installable profiles
e207e2a Merge pull request #55 from cacack/feat/panel-review-at-a-glance-table
2ff0152 feat: open the panel review with an at-a-glance verdict table
5e36422 Merge pull request #54 from cacack/fix/deep-flag-parsing-and-ledger-field
39cde99 fix: connect the ledger's readers and record the chain in one auditable place
```
- Recent tags (per-plugin since the split; bare vX.Y.Z are the pre-split monolith):
```
authoring/v1.2.1
authoring/v1.2.0
authoring/v1.1.0
authoring/v1.0.0
delivery/v1.0.0
panels/v1.0.0
principles/v1.0.0
toolbox/v1.0.0
v2.0.0
v1.47.2
v1.47.0
v1.46.0
```

## Other top-level docs
- SECURITY.md: absent
- CONTRIBUTING.md: present
- CODE_OF_CONDUCT.md: absent
- CHANGELOG.md: absent
- ROADMAP.md: absent
- CLAUDE.md: present

## Resource counts
- authoring: 21 skills, 8 agents
- delivery: 12 skills, 7 agents
- panels: 4 skills, 11 agents
- principles: 2 skills, 0 agents
- toolbox: 7 skills, 0 agents

## Review history
- This is the FIRST committed panel run of any kind. No prior docs/reviews/ output exists to compare against.
