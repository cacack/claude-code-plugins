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

#### Development Workflow
- `do` - Execute work with selectable rigor level (vibe, delegate, or speckit)
- `play` - Review a GitHub/GitLab issue, plan the work, and present for approval before implementation
- `ship` - Ship changes with preflight checks, issue compliance verification, and documentation review (`--quick` for fast path)
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
- `whats-next` - Discover and pick up work from handoffs, todos, issues, or ideas (prioritized by readiness)
- `create-plans` - Create detailed project plans with milestones, phases, and checkpoints

#### Extension Creation
- `create-agent-skills` - Comprehensive workflow for building agent skills with references, templates, and workflows
- `create-hooks` - Build custom hooks with examples and troubleshooting guides
- `create-slash-commands` - Build slash commands with argument handling and tool restrictions
- `create-subagents` - Design and implement specialized subagents with orchestration patterns

#### Extension Maintenance
- `audit-skill` - Audit and validate skill structure and quality
- `audit-slash-command` - Audit and validate slash command implementation
- `audit-subagent` - Audit and validate subagent definitions
- `heal-skill` - Self-improvement workflow for skills

#### Shipping & Quality
- `preflight-checks` - Run project-defined code quality checks (make lint/test/security) before shipping
- `issue-compliance` - Verify staged changes satisfy linked issue requirements with coverage scoring
- `docs-analyzer` - Semantic analysis of code changes to identify documentation that needs updating
- `panel-review` - Multi-persona code review of a diff. Spawns 5 reviewer subagents (Skeptic, Maintainer, Performance Engineer, Caller, Security Reviewer) in parallel against a branch, PR, or commit range

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
