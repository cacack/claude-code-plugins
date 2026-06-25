---
name: instill-principles
description: >-
  Install or re-sync the engineering-kit canon — the durable engineering principles and agent operating rules —
  into a repo's (or your user profile's) always-on Claude Code context.
  Audits the target's existing CLAUDE.md and .claude/rules for overlap, merges without duplicating,
  and writes a managed block you can re-sync as the canon evolves.
  Use when setting up a repo's principles, adopting the engineering canon, or refreshing it after a plugin update.
  Triggers include "instill principles", "install the engineering principles", "adopt the engineering canon", "sync engineering-kit".
---

# Instill Principles

Plant the engineering-kit canon in a location Claude Code **always** loads, so the principles are ambient — present every session, not waiting to be invoked.

The canon is two files shipped with this plugin:

- `${CLAUDE_PLUGIN_ROOT}/principles/engineering.md` — 9 durable engineering principles.
- `${CLAUDE_PLUGIN_ROOT}/principles/agent-operating.md` — 6 agent operating rules.

These are the single source of truth. This skill copies them into the target; it never rewrites the canon.

## The boundary — read this first

This skill is the **installer**, not the ambient mechanism. The ambient mechanism is the file it writes — an always-loaded `.claude/rules/` file (or a CLAUDE.md section). A Claude Code plugin cannot inject always-on context directly, by design; a checked-in file is how principles stay active, and the right trade: visible, version-controlled, reviewable in a PR, and shared with the team — never hidden behind a hook.

Two hard rules:

- **Own only your block.** The skill manages the content between its `BEGIN`/`END` markers and nothing else. It never edits, reflows, or deletes hand-written content outside the markers.
- **Never duplicate.** If the target already states a principle (e.g. the team hand-wrote "Simple is better than complex"), surface the overlap and let the person decide — do not write the same idea twice in two voices.

## Choose a scope

Ask which the person wants if it isn't obvious from the request; default to **repo**.

| Scope | Target file | Use when |
|-------|-------------|----------|
| **Repo** (default) | `.claude/rules/engineering-kit.md` | The principles should apply to this codebase and be shared with the team via version control. |
| **User** | `~/.claude/rules/engineering-kit.md` | The person wants the canon active across *all* their repos on this machine ("in everything"). |

If the repo has no `.claude/` directory and the team prefers a single file, offer the fallback: a managed section appended to the repo-root `CLAUDE.md` instead. Same markers, same rules.

## Workflow

### 1. Confirm scope and target

Resolve the scope above to a concrete target path. State it back in one line before touching anything.

### 2. Read the canon

Read both payload files from `${CLAUDE_PLUGIN_ROOT}/principles/`. Read the plugin's `plugin.json` for the current `version` — it stamps the managed block.

### 3. Audit the target for overlap and conflicts

Read the target file (if it exists) **and** the repo's `CLAUDE.md` and any other `.claude/rules/` files. Look for:

- **Already covered** — a principle the team has already written in their own words. Note it; don't restate it.
- **Conflicts** — existing guidance that contradicts the canon (e.g. a rule encouraging clever one-liners vs. "Explicit over implicit"). Flag each one explicitly and let the person decide which wins.
- **An existing managed block** from a previous run — this is a re-sync, not a fresh install.

### 4. Propose the merge

Show exactly what will be written — the full managed block — plus a short list of: overlaps you're deferring to existing content, and any conflicts needing a decision. Get explicit approval before writing.

### 5. Write the managed block

Assemble the block from the two canon files, wrapped in markers, and write it to the target:

```markdown
<!-- BEGIN engineering-kit:instill-principles v<VERSION> — managed block. Re-sync with the instill-principles skill; edit above or below, not inside. Source: https://github.com/cacack/claude-code-plugins (cacack plugin). -->

<contents of engineering.md>

<contents of agent-operating.md>

<!-- END engineering-kit:instill-principles -->
```

- **Fresh install:** create the target (and `.claude/rules/` if needed) and write the block. For the CLAUDE.md fallback, append the block; don't disturb existing sections.
- **Re-sync:** replace the content **between** the existing markers in place. Leave everything outside untouched.

### 6. Confirm and explain re-sync

Confirm the path written and that it will load automatically next session. Tell the person how to refresh later: after a `/plugin update`, re-run this skill to re-sync the block to the new canon version.

## Notes

- **Keep it lean.** The canon is short on purpose — it is meant to be internalized, not skimmed as a checklist. Do not pad it or add local principles inside the managed block; team-specific guidance goes in the team's own CLAUDE.md, outside the markers.
- **Provenance lives in the plugin docs**, not in the injected block — the [Standards Traceability table](../../docs/engineering-principles.md#standards-traceability) cites every source. The block carries only a one-line pointer back here.
