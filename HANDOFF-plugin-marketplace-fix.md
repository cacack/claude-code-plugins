# HANDOFF: Plugin Marketplace Not Showing Plugins

## Problem

The marketplace installs successfully but shows no plugins available:
- `/plugin marketplace add https://github.com/cacack/claude-code-plugins` succeeds
- But no plugins appear in "Installed" or available for installation

## Current State (v1.5.3)

```
repo-root/
├── .claude-plugin/
│   ├── marketplace.json   # source: "./"
│   └── plugin.json        # hooks: "../hooks/hooks.json"
├── commands/
├── agents/
├── skills/
└── hooks/
```

## What Was Tried

1. **Original structure**: `source: "./"` with plugin.json in `.claude-plugin/` - didn't work
2. **Changed to `source: "../"`** - rejected by schema ("must start with ./")
3. **Moved plugin.json to repo root** with `source: "./"` - marketplace added but still no plugins
4. **Restored canonical structure** per docs - still no plugins

## Key Uncertainty

The documentation research was inconsistent about path resolution:
- Does `source: "./"` resolve relative to marketplace.json location or repo root?
- Where exactly should plugin.json be for a single-plugin marketplace?
- How does Claude Code discover resources (commands/, agents/, etc.)?

## Required Research

Before making more changes, need authoritative answers:

1. **Find working examples**: Look for existing public marketplace repos that actually work
2. **Test locally**: Use `/plugin validate .` or similar to validate structure
3. **Understand path resolution**:
   - What is `source` relative to?
   - Where does Claude Code look for plugin.json given a source path?
   - How are resource directories discovered?

## Questions to Answer

1. For a single-plugin marketplace where the entire repo IS the plugin:
   - What should `source` be?
   - Where should plugin.json live?

2. Is there a validation command to check if structure is correct?

3. Are there working public marketplace examples to reference?

## Files Modified in This Session

- `.claude-plugin/marketplace.json` - source path changes
- `.claude-plugin/plugin.json` - moved back here, hooks path updated
- `CLAUDE.md` - added structure rules and path resolution docs
- Deleted `plugin.json` from repo root

## To Resume

1. Research working marketplace examples
2. Validate current structure with Claude Code tooling if available
3. Test incrementally with validation before shipping
