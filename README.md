# claude-code-plugins

My personal Claude Code plugin collection.

## Usage

Add this marketplace to your Claude Code instance:

```bash
/plugin marketplace add https://github.com/cacack/claude-code-plugins
```

Or add it locally for development:

```bash
/plugin marketplace add /Users/chris/devel/home/claude-code-plugins
```

## Available Resources

This marketplace contains a curated collection of:

### Commands
- `ship` - Intelligently commit and ship changes using basic or advanced workflow
- `create-prompt` - Expert prompt engineer that creates optimized, XML-structured prompts with intelligent depth selection
- `run-prompt` - Delegate one or more prompts to fresh sub-task contexts with parallel or sequential execution
- `whats-next` - Analyze the current conversation and create a handoff document for continuing work in a fresh context
- `debug` - Apply expert debugging methodology to investigate a specific issue
- `create-meta-prompt` - Generate optimized prompts for Claude-to-Claude pipelines
- `hello` - Example command demonstrating basic command structure

#### Decision-Making Frameworks (consider/)
- `consider/10-10-10` - Evaluate decisions across three time horizons (10 minutes, 10 months, 10 years)
- `consider/5-whys` - Root cause analysis by asking "why" five times
- `consider/eisenhower-matrix` - Prioritize tasks by urgency and importance
- `consider/first-principles` - Break down problems to fundamental truths
- `consider/inversion` - Think backwards by considering what to avoid
- `consider/occams-razor` - Favor simpler explanations and solutions
- `consider/one-thing` - Identify the single most important action
- `consider/opportunity-cost` - Evaluate what you give up by choosing something
- `consider/pareto` - Apply 80/20 principle to find highest-leverage actions
- `consider/second-order` - Analyze downstream consequences beyond immediate effects
- `consider/swot` - Assess Strengths, Weaknesses, Opportunities, and Threats
- `consider/via-negativa` - Improve by removing rather than adding

### Agents
- `example-agent` - Demonstration agent showing agent structure

### Skills
- `create-meta-prompts` - Autonomous workflow for creating optimized meta-prompts with reference patterns
- `debug-like-expert` - Deep analysis debugging mode for complex issues with methodical investigation protocols

## Repository Structure

```
├── .claude-plugin/
│   └── marketplace.json       # Marketplace configuration
├── agents/                    # Custom agent definitions
│   └── *.md
├── commands/                  # Custom slash commands
│   └── *.md
└── skills/                    # Autonomous workflows
    └── */
```

## Adding New Resources

1. Add command files to `commands/` directory
2. Add agent definitions to `agents/` directory
3. Add skills to `skills/` directory
4. Commit and push changes

## References

- [Plugin Marketplaces Documentation](https://code.claude.com/docs/en/plugin-marketplaces)
- [Claude Code Documentation](https://code.claude.com/docs)
