# Handoff: `/do` Command Enhancement

**From**: gedcom-go session (2024-12-20)
**Status**: Idea captured, ready for implementation

## Context

While working on gedcom-go documentation cleanup, we identified improvements for the plugin commands workflow.

## The Idea

Enhance the `/play → /do → /ship` flow with:

### 1. `/do` as a "rigor selector"

```
/do [issue-or-task]

→ "Choose your approach:"

  1. 🎸 Vibe it - Implement now in this session (light, iterative)

  2. 📋 Delegate - Create prompts for /run-prompt (structured handoff)

  3. 🏗️ Speckit - Full spec → plan → tasks workflow (maximum rigor)
```

### 2. Modular command structure

```
commands/
├── _modules/                    # Reusable snippets
│   ├── docs-check.md           # Documentation update check logic
│   ├── git-context.md          # Common git context gathering
│   └── commit-message.md       # Conventional commit logic
├── play.md                      # Full planning workflow
├── plan.md                      # Wrapper → delegates to /play
├── do.md                        # Rigor selector (new)
├── ship.md                      # Enhanced with docs-check
└── docs-check.md               # Standalone docs check
```

### 3. `/ship` enhancement

Add pre-ship documentation check:
- Detect FEATURES.md, README.md, IDEAS.md
- If source files changed, prompt about doc updates
- Check if README highlights need updating

### 4. `/play` enhancement

Add "Documentation Impact" section to output:
```markdown
## Documentation Impact
- [ ] FEATURES.md - [needs update if adding new capability]
- [ ] README.md highlights - [check if major feature]
- [ ] IDEAS.md - [remove if implementing from ideas]
```

### 5. Wrapper commands for aliases

- `/plan` → wraps `/play`
- Use pattern: "Execute /other-command $ARGUMENTS"

## Additional Discovery

Need a **cross-project capture** command:

**`/park`** - Quickly capture idea in another project without losing current context
```
/park ~/path/to/other-project "Brief description"
```

## Next Steps

1. Create GitHub issue or add to IDEAS.md in this repo
2. Implement `/do` command
3. Enhance `/ship` with docs-check
4. Enhance `/play` with documentation impact
5. Create `/park` command for cross-project capture
