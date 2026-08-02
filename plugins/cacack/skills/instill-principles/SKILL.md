---
name: instill-principles
description: >-
  Install or re-sync a canon profile — the durable principles and agent operating rules, in an
  engineering wording or a universal one — into a repo's (or your user profile's) always-on Claude Code context.
  Audits the target's existing CLAUDE.md and .claude/rules for overlap, merges without duplicating,
  migrates a pre-profile install in place, and writes a managed block you can re-sync as the canon evolves.
  Use when setting up a repo's principles, adopting the canon for a non-developer, or refreshing it after a plugin update.
  Triggers include "instill principles", "install the engineering principles", "adopt the engineering canon", "sync engineering-kit",
  "install the universal canon", "set up working-with-claude rules", "set up ground rules for working with Claude".
---

# Instill Principles

Plant a canon **profile** in a location Claude Code **always** loads, so the principles are ambient — present every session, not waiting to be invoked.

The canon ships as two self-contained profile payloads. [`principles/PROFILES.md`](../../principles/PROFILES.md) is the contract: the registry of payload and target paths, the marker format and how to match it, and the migration rule. **Read it before writing anything** — it is the single source of truth for every string and path below, and this skill deliberately does not restate them.

This skill is a **copier**. It reads exactly one payload and writes it verbatim into a managed block. It never assembles, templates, edits, or blends the canon.

## The boundary — read this first

This skill is the **installer**, not the ambient mechanism. The ambient mechanism is the file it writes — an always-loaded `.claude/rules/` file (or a CLAUDE.md section). A Claude Code plugin cannot inject always-on context directly, by design; a checked-in file is how principles stay active, and the right trade: visible, version-controlled, reviewable in a PR, and shared with the team — never hidden behind a hook.

Two hard rules:

- **Own only your block.** The skill manages the content between its `BEGIN`/`END` markers and nothing else. It never edits, reflows, or deletes hand-written content outside the markers.
- **Never duplicate.** If the target already states a principle (e.g. the team hand-wrote "Simple is better than complex"), surface the overlap and let the person decide — do not write the same idea twice in two voices. This applies to the sibling profile too: the profiles are two wordings of one canon, so a person gets one of them, never both.

## Choose a profile and a scope

Two independent inputs. Ask for whichever isn't obvious from the request.

| Profile | For | Default when |
|---------|-----|--------------|
| **`engineering`** | Someone writing and shipping code. Names refactors, modules, APIs, and issue delivery. | The target is a code repo — assume this without asking. |
| **`universal`** | Someone doing non-code work with Claude — writing, research, ops, analysis. Same ideas, generalized wording. | Never assume. At user scope, **ask** — that is exactly the case where a non-developer is being set up. |

| Scope | For | Default |
|-------|-----|---------|
| **Repo** | The principles apply to this codebase and ship to the team via version control. | Yes |
| **User** | The person wants the canon active across *all* their work on this machine ("in everything"). | Ask if ambiguous. |

Profile × scope resolves to a payload path and a target path via the registry table in `PROFILES.md`. Take them from there; never invent a path.

If the repo has no `.claude/` directory and the team prefers a single file, offer the fallback: a managed section in the repo-root `CLAUDE.md` instead. `PROFILES.md` covers it — same markers, same rules, same invariant.

## Workflow

### 1. Confirm profile, scope, and target

Resolve the profile and scope, then look up the profile's row in the `PROFILES.md` registry. It has **three** target columns, and the selection rule is a fact about the filesystem, not a preference:

- User scope → **User target**.
- Repo scope, `.claude/` exists → **Repo target**.
- Repo scope, no `.claude/` → **Repo target, no `.claude/`** — the repo-root `CLAUDE.md`.

State the resolution back in one line before touching anything — e.g. "Installing the `engineering` profile at user scope → `~/.claude/rules/engineering-kit.md`."

This resolves where a block would go **today**. It does not tell you where an existing block already *is* — a repo that took the fallback and later gained a `.claude/` resolves differently than it did on the previous run. Step 3 searches for existing blocks by location; never substitute this resolution for that search.

### 2. Read the contract and the payload

From `${CLAUDE_PLUGIN_ROOT}/principles/PROFILES.md`, read four sections: **The profiles** (registry), **Marker format**, **Legacy migration**, and **The invariant**. Those are the whole installer-facing contract. The **idea→variant map** and **Maintaining the map** that follow are maintainer bookkeeping for keeping the two payloads in sync — roughly half the file, and nothing an install needs. Skip them.

Then read the **one** payload file for the selected profile, and the plugin's `plugin.json` for the current `version` — it stamps the managed block.

### 3. Classify the install — migration first

Before deciding fresh-install vs. re-sync, work through these in order. Match blocks on their ID exactly as `PROFILES.md` describes; **never** match on the version stamp — a stale stamp is the normal case, not an error.

**Search every registry location for the scope, not the one target step 1 resolved.** All three columns, both profile rows — for repo scope that is `.claude/rules/engineering-kit.md`, `.claude/rules/working-with-claude.md`, and the repo-root `CLAUDE.md`. A block does not move when the filesystem changes underneath it: a repo that installed via the fallback and later gained a `.claude/` still has its block in `CLAUDE.md`, and resolving "the target" to `.claude/rules/` would look straight past it and call the install fresh. Directory state decides where a block *goes*; only a search decides where one *is*.

1. **Legacy block?** Look in the **legacy locations** listed under *Where to look for one* in `PROFILES.md` — the scope's **engineering** target, plus the repo-root `CLAUDE.md` at repo scope. Look there **whichever profile was selected**: a legacy block is an `engineering` block that predates the naming, so it lives in engineering's locations, never in the selected profile's. Checking "the target" resolved in step 1 is wrong and silently defeats this step for every `universal` install.
   - Selected profile is `engineering` → this is a **migration**. Continue.
   - Selected profile is `universal` → this is the cross-profile case below; the legacy block counts as the engineering block. Stop and ask.
2. **A canon block for the *other* profile anywhere in the scope?** Same location search as above, matching the **sibling's** `canon:<profile>` ID — not the target the registry resolves for it, and not any canon block. Both halves matter:
   - **Search, don't resolve.** A sibling installed via the fallback and since orphaned by a new `.claude/` sits in `CLAUDE.md`, not at its resolved path. Resolving would look past it and let a second profile land — the exact case this guard exists for.
   - **Match the ID, not the file.** In a fallback repo both profiles share `CLAUDE.md`, so "this file holds a canon block" is true during an ordinary same-profile re-sync. Firing on that turns every fallback re-sync into a bogus conflict prompt. Only a block carrying the *sibling's* ID is a conflict.

   If one exists, this is the **cross-profile guard** — see below. Stop and ask; do not proceed to write.
3. **A canon block for the selected profile anywhere in the scope?** → **re-sync**, *in the file where the block actually lives* — which may not be the target step 1 resolved. A `canon:engineering` block in `CLAUDE.md` is re-synced in `CLAUDE.md`, even once `.claude/rules/` exists; writing the "correct" target instead leaves the old block live and duplicates the canon. Moving a block between targets is a migration the person must approve, never a side effect of a re-sync — if you believe it belongs elsewhere now, say so in step 5 and let them decide.
4. **Otherwise** → **fresh install**, at the step-1 target.

**The cross-profile guard.** Installing `universal` where `engineering` already lives at the same scope (or the reverse) would put both wordings of the same idea into one session — the override violation `PROFILES.md` forbids. Explain what is already installed and where, then require an explicit decision: *switch* (remove the existing block, then install the requested one) or *cancel*. There is no "add it anyway" — never write the second block.

On *switch*, remove the block and its markers and nothing else. If that leaves the vacated file with no content of its own, say so and offer to delete it — never delete it unasked.

**A switch decision is not a write authorization.** It settles *which* profile the person wants, nothing more. Resume at step 3 for the requested profile — a legacy block or an orphaned block of its own may still be waiting, and switching must not swallow the migration that would have handled it — then run steps 4 and 5 as normal. The person approves the literal block before it lands, on this path exactly as on every other; ambient context is the last place to skip that.

The guard is scope-local by design. A block at the *other* scope is not blocked; see step 4.

### 4. Audit the target for overlap and conflicts

Read **every file in the scope's rules directory** — `.claude/rules/` at repo scope, `~/.claude/rules/` at user scope — not just the target, plus the repo's `CLAUDE.md` and both profiles' target files at *both* scopes. Overlap comes from hand-written neighbours as readily as from a sibling profile or the same profile one scope up.

Non-target rules files are the likeliest source and the easiest to miss: they carry no markers, so the skill will never own them, never remove them, and will happily write a second copy of what they already say. **Anyone migrating from a pre-2.0.0 install is the standard case here** — the privacy and issue-delivery sections are new to the payload, and a hand-written `privacy.md` or `issue-delivery.md` sitting alongside the target is exactly the duplication *Never duplicate* forbids. Surface it by name in step 5.

Look for:

- **Already covered** — a principle the team has already written in their own words. Note it; don't restate it.
- **Conflicts** — existing guidance that contradicts the canon (e.g. a rule encouraging clever one-liners vs. "Explicit over implicit"). Flag each one explicitly and let the person decide which wins.
- **An existing managed block** — from a previous run, or a legacy block from before profiles existed.
- **A canon block at the other scope** — a user-scope block when installing at repo scope, or the reverse. Per `PROFILES.md` this is surfaced, not blocked: name what is installed where, say which block is the narrower one, and proceed. It must never happen silently.

### 5. Propose the merge

Show exactly what will be written — the full managed block — plus a short list of: overlaps you're deferring to existing content, and any conflicts needing a decision. Get explicit approval before writing.

**If this is a migration, say so first, in its own sentence**: name the legacy block and its version stamp, and state that it will be replaced in place by a `canon:engineering` block at the current version, in the same file and the same position. The person must be approving a migration, not discovering one afterwards.

### 6. Write the managed block

Wrap the payload — unchanged, exactly as read — in the markers defined in `PROFILES.md`, substituting the profile key and the version from `plugin.json`. Then:

- **Fresh install:** create the target (and `.claude/rules/` if needed) and write the block. For the CLAUDE.md fallback, append the block; don't disturb existing sections.
- **Re-sync:** replace the content **between** the existing markers in place, and re-emit the BEGIN marker so the version stamp refreshes. Leave everything outside untouched.
- **Migration:** replace the legacy block — both markers *and* their content — with the new block in one edit, in the same file and the same position. Never append, never leave the old marker behind, never write-then-delete in two steps.

Then check the invariant from `PROFILES.md` by **re-scanning this scope's registry locations** and counting markers:

- **Repo scope:** `.claude/rules/engineering-kit.md`, `.claude/rules/working-with-claude.md`, and the repo-root `CLAUDE.md` — three files, both profile rows.
- **User scope:** `~/.claude/rules/engineering-kit.md` and `~/.claude/rules/working-with-claude.md`. Two files. The `CLAUDE.md` fallback is repo-scope only, so it is **not** part of a user-scope count.

It holds only if exactly one `canon:` block exists across that scope's files, and no legacy marker survives anywhere in them.

**Count one scope, never both.** A block at the *other* scope is permitted and was already surfaced in step 4 — folding it into this count would fail a legitimate install and tell the person they created a bug they did not create.

Scan all of them, not the file you just wrote. Every way this invariant has been broken looks identical from inside the written file and only shows up from outside it: a legacy block left in `CLAUDE.md` while a fresh one lands in `.claude/rules/`, a pre-existing `canon:engineering` in `CLAUDE.md` that a re-resolved target hid, a sibling profile in the other target. A per-file check passes all three. If the count is wrong, you have created the bug the invariant exists to catch — stop and report rather than patching over it.

### 7. Confirm and explain re-sync

Confirm the profile, the path written, and that it will load automatically next session. Tell the person how to refresh later: after a `/plugin update`, re-run this skill to re-sync the block to the new canon version — same profile, same file, stamp refreshed. Switching profiles later is not a second install: it removes the existing block and writes the other one.

## Notes

- **Keep it lean.** The canon is short on purpose — it is meant to be internalized, not skimmed as a checklist. Do not pad it or add local principles inside the managed block; team-specific guidance goes in the team's own CLAUDE.md, outside the markers.
- **Provenance lives in the plugin docs**, not in the injected block — the [Standards Traceability table](../../docs/engineering-principles.md#standards-traceability) cites every source. The block carries only a one-line pointer back here.
