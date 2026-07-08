# claude-code-plugins

My personal Claude Code plugin collection.

## Installation

```bash
# Add marketplace
claude plugin marketplace add cacack/claude-code-plugins

# Then install plugins
claude plugin install cacack
```

## Available Resources

### Skills

#### Development Workflow (play → do → panel → ship → merge)
The cycle runs inside a dedicated git worktree (`.claude/worktrees/`) so simultaneous parallel cycles never pollute each other — `/play` (or `/do` in direct mode) creates it; the rest inherit it; `/merge` tears it down.
- `play` - Plan the work: fetch a GitHub/GitLab issue (or take a free-text task), explore, design, approve via plan mode, then either execute inline or emit a DAG of execution prompts to `.prompts/` for `/do`. Creates the cycle's worktree
- `do` - Execute the work: run the latest `/play` batch (no args), run specific prompts by number, or execute a free-text task directly
- `ship` - Ship the work: preflight checks, issue compliance verification, documentation review, and PR/MR creation (`--quick` for fast path)
- `merge` - Land a green PR/MR with semi-linear history (rebase, then merge commit) and clean up the local clone: remove the cycle's worktree, return to and pull the default branch, delete the merged branch locally and remotely, and prune stale refs
- `deliver-milestone` - Drive a whole milestone/epic to done across every open issue (implement → panel review → address findings → ship → optional CodeRabbit → merge). Routes by agency: a fully-autonomous run has Claude author and launch a built-in dynamic Workflow; a checkpointed run uses an interactive orchestrator that calls `/play`, `/do`, `/panel-review`, `/ship` with approval pauses
- `debug-like-expert` - Deep analysis debugging mode for complex issues with methodical investigation protocols
- `security-review` - Comprehensive security analysis of changes, context, or entire repository

#### Prompt Engineering & Workflows
- `create-meta-prompts` - Create optimized prompts for Claude-to-Claude pipelines with research, planning, and execution stages
- `create-prompt` - Expert prompt engineer that creates optimized, XML-structured prompts with intelligent depth selection
- `run-prompt` - Delegate one or more prompts to fresh sub-task contexts with parallel or sequential execution

#### Context & Planning
- `add-to-todos` - Add items to your todo list with context from conversation
- `check-todos` - Review and manage your todo list
- `park` - Park current session context or capture cross-project ideas for later pickup
- `whats-next` - Discover and pick up work from handoffs, todos, GitHub/GitLab issues, or ideas (prioritized by readiness, with milestone-scoped issues ranked above general ones)
- `history` - Read Claude Code conversation history from `~/.claude/history.jsonl` and present recent sessions (date, project, topic, session ID) as a scannable table, with a `claude --resume` tip
- `create-plans` - Create detailed project plans with milestones, phases, and checkpoints

#### Engineering Canon
- `instill-principles` - Install or re-sync the engineering canon (9 durable engineering principles + 6 agent operating rules) into a repo's `.claude/rules/` or your user profile's always-on context. Audits the target for overlap, merges without duplicating, and writes a managed block you re-sync as the canon evolves. See [docs/engineering-principles.md](plugins/cacack/docs/engineering-principles.md)

#### Extension Creation
- `create-agent-skills` - Comprehensive workflow for building agent skills with references, templates, and workflows
- `create-hooks` - Build custom hooks with examples and troubleshooting guides
- `create-slash-commands` - Build slash commands with argument handling and tool restrictions
- `create-subagents` - Design and implement specialized subagents with orchestration patterns
- `create-claudemd` - Create, author, or migrate `CLAUDE.md` and `.claude/rules/` files following Anthropic best practices (create / rules / migrate modes). Pairs with `audit-claudemd` for the audit side

#### Extension Maintenance
- `audit-skill` - Audit and validate skill structure and quality
- `audit-slash-command` - Audit and validate slash command implementation
- `audit-subagent` - Audit and validate subagent definitions
- `audit-claudemd` - Audit a `CLAUDE.md` or `.claude/rules/` file/dir for conciseness, stale references, scope, and path-scoping (drives the `claudemd-auditor` agent)
- `audit-docs` - Audit project documentation for dead links, orphaned files, drift/staleness, and duplicated facts (DRY) — the runtime enforcement of the `documentation-standards` link-don't-duplicate discipline (drives the `docs-auditor` agent)
- `heal-skill` - Self-improvement workflow for skills

#### Shipping & Quality
- `preflight-checks` - Run project-defined code quality checks (make lint/test/security) before shipping
- `issue-compliance` - Verify staged changes satisfy linked issue requirements with coverage scoring
- `docs-analyzer` - Semantic analysis of code changes to identify documentation that needs updating
- `documentation-standards` - The canonical project-documentation standard (types, locations, organization, formatting): a lean OSS-style root over a structured `docs/` reference layer, with templates for each doc type (architecture, ADR, design, guide, policy, runbook, reference). Consult it, scaffold a repo's doc set, or check existing docs against it. Pairs with `audit-docs` (drift/dead links), `docs-analyzer` (code-driven updates), and `create-claudemd` (CLAUDE.md authoring)
- `panel-review` - Multi-persona code review of a diff. Spawns 5 reviewer subagents (Skeptic, Maintainer, Performance Engineer, Caller, Security Reviewer) in parallel against a branch, PR, or commit range
- `panel-engineering` - Multi-persona engineering-health review of the whole repo (quarterly). Spawns 5 senior personas (Architect, Security Posture, Operations/SRE, Developer Experience, Maintainability) in parallel against a captured snapshot, produces per-persona reports plus synthesis and proposed-issue drafts, optionally files the issues
- `constitution` - Author or refresh a project's `CONSTITUTION.md` (mission, audience, principles, non-goals, success criteria). Auto-detects bootstrap vs refresh mode; in refresh mode produces a drift report before updating. Required input for `panel-product`
- `panel-product` - Multi-persona strategic-alignment review against `CONSTITUTION.md` (quarterly). Spawns 5 senior personas (Mission Steward, Market Strategist, Roadmap Reviewer, Audience Advocate, Trust Auditor) in parallel, then a closing adversarial Rude Q&A foil pass (`rude-qa` agent) pressure-tests the synthesis for survival; produces per-persona reports plus synthesis, a foil report, and proposed-issue drafts, optionally files the issues. Requires `CONSTITUTION.md` — run `constitution` first if absent (`--no-foil` skips the foil pass)
- `pressure-test` - Pressure-test a strategy, pitch, proposal, or roadmap against the adversarial questioning of the `rude-qa` agent before you bring it to decision-makers — 5 Whys, gap analysis, speed/cost/risk, pre-mortem, a hostile-question rehearsal, and a sharpened ask plus a Monday action

#### Decision-Making Frameworks (consider/)
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

#### Domain Expertise
- `expertise/iphone-apps` - Comprehensive iPhone app development expertise (SwiftUI, App Store, testing, CI/CD)
- `expertise/macos-apps` - Complete macOS app development knowledge (AppKit, document apps, system APIs)

#### Internal (non-user-invocable)
- `shared-modules/commit-message` - Reusable logic for generating conventional commit messages
- `shared-modules/docs-check` - Reusable logic for checking if documentation needs updates
- `shared-modules/git-context` - Reusable logic for gathering git repository context

### Agents
- `shipper` - Expert shipping orchestrator for rigorous code delivery (preflight, issue compliance, docs review)
- `skill-auditor` - Specialized agent for auditing skill quality and structure
- `slash-command-auditor` - Specialized agent for auditing slash command implementations
- `subagent-auditor` - Specialized agent for auditing subagent definitions

Reviewer subagents (invoked in parallel by the `panel-review` skill):
- `reviewer-skeptic` - Adversarial bug-hunter focused on edge cases and error-handling gaps
- `reviewer-maintainer` - Reviews internal naming, structure, test adequacy, convention drift
- `reviewer-performance` - Spots hot-path costs: complexity, allocations, lock contention, leaks
- `reviewer-ergonomics` - Caller-perspective review of public APIs, contracts, error messages, breaking changes
- `reviewer-security` - Diff-focused security review for injection, auth gaps, secrets, unsafe defaults

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

### Hooks

- `ship-version-validation` - Enforces version bump checking before `/ship` by prompting Claude to read CLAUDE.md for project-specific versioning requirements

### Scripts

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
