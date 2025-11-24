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
- `create-meta-prompt` - Generate optimized prompts for Claude-to-Claude pipelines
- `create-prompt` - Expert prompt engineer that creates optimized, XML-structured prompts with intelligent depth selection
- `debug` - Apply expert debugging methodology to investigate a specific issue
- `run-prompt` - Delegate one or more prompts to fresh sub-task contexts with parallel or sequential execution
- `ship` - Intelligently commit and ship changes using basic or advanced workflow
- `whats-next` - Analyze the current conversation and create a handoff document for continuing work in a fresh context

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

### Skills
- `create-meta-prompts` - Autonomous workflow for creating optimized meta-prompts with reference patterns
- `debug-like-expert` - Deep analysis debugging mode for complex issues with methodical investigation protocols

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details on contributing to this repo.


## Attribution

Many resources in this collection are adapted from [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources) by glittercowboy. These include:
- All `consider:*` decision-making framework commands
- `create-prompt` and `run-prompt` commands for prompt workflow
- `whats-next` command for context handoff
- `debug` command and `debug-like-expert` skill for systematic debugging

## References

- [Plugin Marketplaces Documentation](https://code.claude.com/docs/en/plugin-marketplaces)
- [Claude Code Documentation](https://code.claude.com/docs)
- [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources) - Source of many resources in this collection
