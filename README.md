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

This marketplace contains a curated collection of:

### Commands

#### Prompt Engineering & Workflows
- `create-meta-prompt` - Generate optimized prompts for Claude-to-Claude pipelines
- `create-prompt` - Expert prompt engineer that creates optimized, XML-structured prompts with intelligent depth selection
- `run-prompt` - Delegate one or more prompts to fresh sub-task contexts with parallel or sequential execution

#### Context & Planning
- `add-to-todos` - Add items to your todo list
- `check-todos` - Review and manage your todo list
- `park` - Park current session context or capture cross-project ideas for later pickup
- `whats-next` - Discover and pick up work from handoffs, todos, issues, or ideas (prioritized by readiness)

#### Development Workflow
- `debug` - Apply expert debugging methodology to investigate a specific issue
- `do` - Execute work with selectable rigor level (vibe, delegate, or speckit)
- `play` - Review a GitHub/GitLab issue, plan the work, and present for approval before implementation
- `security-review` - Comprehensive security analysis of changes, context, or entire repository
- `ship` - Ship changes with preflight checks, issue compliance verification, and documentation review (`--quick` for fast path)

#### Extension Creation
- `create-agent-skill` - Create new agent skills with structured references and workflows
- `create-hook` - Create custom hooks for Claude Code
- `create-slash-command` - Create new slash commands
- `create-subagent` - Create specialized subagent definitions

#### Extension Maintenance
- `audit-skill` - Audit and validate skill structure and quality
- `audit-slash-command` - Audit and validate slash command implementation
- `audit-subagent` - Audit and validate subagent definitions
- `heal-skill` - Self-improvement workflow for skills

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

### Agents
- `shipper` - Expert shipping orchestrator for rigorous code delivery (preflight, issue compliance, docs review)
- `skill-auditor` - Specialized agent for auditing skill quality and structure
- `slash-command-auditor` - Specialized agent for auditing slash command implementations
- `subagent-auditor` - Specialized agent for auditing subagent definitions

### Hooks

- `ship-version-validation` - Enforces version bump checking before `/ship` by prompting Claude to read CLAUDE.md for project-specific versioning requirements

### Scripts

Standalone utilities in `scripts/` directory (not plugin resources):

- `ccstatusline-usage.sh` - Claude Code usage monitor for [ccstatusline](https://github.com/sirmalloc/ccstatusline). Displays 5-hour session and 7-day weekly utilization as progress bars. Run `make install` to symlink to `~/.local/bin/`, then configure as a custom-command widget.

### Skills

#### Meta Skills (Creating Extensions)
- `create-agent-skills` - Comprehensive workflow for building agent skills with references, templates, and workflows
- `create-hooks` - Build custom hooks with examples and troubleshooting guides
- `create-plans` - Create detailed project plans with milestones, phases, and checkpoints
- `create-slash-commands` - Build slash commands with argument handling and tool restrictions
- `create-subagents` - Design and implement specialized subagents with orchestration patterns

#### Shipping & Quality
- `preflight-checks` - Run project-defined code quality checks (make lint/test/security) before shipping
- `issue-compliance` - Verify staged changes satisfy linked issue requirements with coverage scoring
- `docs-analyzer` - Semantic analysis of code changes to identify documentation that needs updating

#### Core Skills
- `create-meta-prompts` - Autonomous workflow for creating optimized meta-prompts with reference patterns
- `debug-like-expert` - Deep analysis debugging mode for complex issues with methodical investigation protocols

#### Domain Expertise
- `expertise/iphone-apps` - Comprehensive iPhone app development expertise (SwiftUI, App Store, testing, CI/CD)
- `expertise/macos-apps` - Complete macOS app development knowledge (AppKit, document apps, system APIs)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details on contributing to this repo.


## Attribution

The majority of resources in this collection are adapted from [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources) by glittercowboy. This includes:
- All decision-making framework commands (`consider:*`)
- Prompt engineering workflows (`create-prompt`, `run-prompt`, `create-meta-prompt`)
- Context management (`whats-next`, `add-to-todos`, `check-todos`)
- Debugging tools (`debug` command and `debug-like-expert` skill)
- Extension creation tools (all `create-*` and `audit-*` commands)
- All agent definitions
- All skills including meta skills and domain expertise

## References

- [Plugin Marketplaces Documentation](https://code.claude.com/docs/en/plugin-marketplaces)
- [Claude Code Documentation](https://code.claude.com/docs)
- [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources) - Source of many resources in this collection
